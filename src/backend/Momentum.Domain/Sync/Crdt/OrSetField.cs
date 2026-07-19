namespace Momentum.Domain.Sync;

/// <summary>
/// Add-wins OR-Set (ADR 0002 K2-C2). An element is present iff it has at least one non-cancelled
/// add-tag. A remove cancels ONLY the tags it observed (never a concurrent unseen add); cancellation
/// is PERMANENT (tombstone), so a later add of an already-cancelled tag is born dead. Its stamp still
/// counts toward the set-activity max (the C4 derivation). Supports gcHorizon compaction with
/// composed remove-remap (Y2). Cap is admission-control enforced by ingest, not here.
/// </summary>
public sealed class OrSetField
{
    private sealed class ElementState
    {
        // Every add-tag ever seen (including born-dead), tag -> stamp. Membership is via Cancelled.
        public Dictionary<Guid, Hlc> Adds { get; } = [];

        // Permanent tombstones (tag ids that were cancelled by some remove).
        public HashSet<Guid> Cancelled { get; } = [];

        // Compaction remap oldTag -> canonicalTag; resolved transitively (composed).
        public Dictionary<Guid, Guid> Remap { get; } = [];

        // Remove stamps retained for the C4 delete/edit activity max.
        public List<Hlc> RemoveStamps { get; } = [];
    }

    private readonly Dictionary<string, ElementState> _elements = new(StringComparer.Ordinal);

    private ElementState GetOrCreate(string element)
    {
        if (!_elements.TryGetValue(element, out var state))
        {
            state = new ElementState();
            _elements[element] = state;
        }

        return state;
    }

    private static Guid ResolveRemap(ElementState element, Guid tag)
    {
        // Follow the remap chain to the live canonical tag (transitive/composed).
        while (element.Remap.TryGetValue(tag, out var next))
        {
            tag = next;
        }

        return tag;
    }

    private static bool IsActive(ElementState element, Guid tag) =>
        element.Adds.ContainsKey(tag) && !element.Cancelled.Contains(tag);

    /// <summary>Records an add (idempotent per tag, max-join — ADR 0002 ERRATA E-1). Membership depends
    /// on the tombstone set.</summary>
    public void ApplyAdd(SetAdd add)
    {
        ArgumentNullException.ThrowIfNull(add);
        var element = GetOrCreate(add.Element);
        MergeStamp(element.Adds, add.Tag, add.Hlc); // max-join; born-dead if already cancelled
    }

    /// <summary>
    /// ERRATA E-1: a CvRDT merge must be a semilattice JOIN (idempotent + commutative + associative).
    /// "First stamp wins" (the original bug) and "last stamp wins" are both idempotent but NOT
    /// commutative — two different ingest orders keep two different stamps, and since
    /// <see cref="MaxStamp"/> feeds the DERIVED K2-C4 conflict flag, that flag flipped 1/0 depending on
    /// order even though set MEMBERSHIP itself converged. The fix: keep the stamp with the greater full
    /// <see cref="Hlc.CompareTo"/> — never just <c>WallMs</c> (equal-WallMs collisions at the clamp
    /// ceiling are exactly where the bug lived). Shared by <see cref="ApplyAdd"/> (live) and
    /// <see cref="LoadTag"/> (hydrate) so the rule is IDENTICAL in both paths — <see cref="LoadTag"/>
    /// must not simply call <see cref="ApplyAdd"/>, or a mutation that breaks one collapses into the
    /// other and loses distinguishability (GOREV slice-2c D2 UYGULAMA PİNİ).
    /// </summary>
    private static void MergeStamp(Dictionary<Guid, Hlc> adds, Guid tag, Hlc candidate)
    {
        if (!adds.TryGetValue(tag, out var existing) || candidate.CompareTo(existing) > 0)
        {
            adds[tag] = candidate;
        }
    }

    /// <summary>Cancels the observed tags permanently (tombstone), remapping compacted tags first.</summary>
    public void ApplyRemove(SetRemove remove)
    {
        ArgumentNullException.ThrowIfNull(remove);
        var element = GetOrCreate(remove.Element);
        element.RemoveStamps.Add(remove.Hlc);
        foreach (var observed in remove.Observed)
        {
            var canonical = ResolveRemap(element, observed);
            element.Cancelled.Add(canonical); // permanent, even if the tag was never seen
        }
    }

    /// <summary>
    /// gcHorizon compaction (K2-C2): each element's below-horizon non-cancelled add-tags collapse to a
    /// single canonical tag (highest <c>(Hlc, Tag-hex)</c>). Cancelled and above-horizon tags are kept.
    /// Removed tags are remapped to the canonical so later removes still land (composed transitively).
    /// <para>
    /// D6 PIN (GOREV slice-2c): <c>canonical</c> MUST be the arg-max of <c>belowActive</c> (by
    /// <see cref="Hlc.CompareTo"/>, tag-hex only as the final tiebreak) so that <see cref="MaxStamp"/> is
    /// PRESERVED across compaction — every dropped tag's stamp is, by construction, ≤ the canonical's.
    /// If the canonical selection rule ever changes (e.g. tag-hex-first, or "first below-horizon tag"),
    /// <see cref="MaxStamp"/> would silently drop a stamp and the derived K2-C4 conflict flag would
    /// regress with NO test failing here — this invariant is what stands between that and silence
    /// (see the companion unit test asserting MaxStamp is unchanged before/after compaction).
    /// </para>
    /// </summary>
    public void CompactBelow(Hlc horizon)
    {
        foreach (var element in _elements.Values)
        {
            var belowActive = new List<Guid>();
            foreach (var (tag, hlc) in element.Adds)
            {
                if (!element.Cancelled.Contains(tag) && hlc.CompareTo(horizon) < 0)
                {
                    belowActive.Add(tag);
                }
            }

            if (belowActive.Count < 1)
            {
                continue;
            }

            var canonical = belowActive[0];
            foreach (var tag in belowActive)
            {
                if (IsHigher(element, tag, canonical))
                {
                    canonical = tag;
                }
            }

            foreach (var tag in belowActive)
            {
                if (tag == canonical)
                {
                    continue;
                }

                element.Adds.Remove(tag);
                element.Remap[tag] = canonical; // existing X->tag entries now compose to X->canonical
            }
        }
    }

    // Higher by (Hlc, Tag-hex) with Hlc ordinal on the ClientId (canonical-tag selection rule).
    private static bool IsHigher(ElementState element, Guid candidate, Guid current)
    {
        var c = element.Adds[candidate].CompareTo(element.Adds[current]);
        if (c != 0)
        {
            return c > 0;
        }

        return string.CompareOrdinal(candidate.ToString("N"), current.ToString("N")) > 0;
    }

    public bool Contains(string element)
    {
        if (!_elements.TryGetValue(element, out var state))
        {
            return false;
        }

        foreach (var tag in state.Adds.Keys)
        {
            if (!state.Cancelled.Contains(tag))
            {
                return true;
            }
        }

        return false;
    }

    /// <summary>Present elements (>= 1 non-cancelled add-tag) — the observational membership.</summary>
    public IReadOnlySet<string> PresentElements()
    {
        var present = new HashSet<string>(StringComparer.Ordinal);
        foreach (var element in _elements.Keys)
        {
            if (Contains(element))
            {
                present.Add(element);
            }
        }

        return present;
    }

    public int ActiveTagCount(string element)
    {
        if (!_elements.TryGetValue(element, out var state))
        {
            return 0;
        }

        var count = 0;
        foreach (var tag in state.Adds.Keys)
        {
            if (!state.Cancelled.Contains(tag))
            {
                count++;
            }
        }

        return count;
    }

    /// <summary>A tag that would become a genuinely-new-active member (not already active, not tombstoned).</summary>
    public bool IsNewActiveTag(string element, Guid tag)
    {
        if (!_elements.TryGetValue(element, out var state))
        {
            return true;
        }

        return !state.Cancelled.Contains(tag) && !state.Adds.ContainsKey(tag);
    }

    /// <summary>Max stamp over all adds (including born-dead) and removes, for the C4 activity max.</summary>
    public Hlc? MaxStamp()
    {
        Hlc? max = null;
        foreach (var element in _elements.Values)
        {
            foreach (var hlc in element.Adds.Values)
            {
                if (max is null || hlc.CompareTo(max.Value) > 0)
                {
                    max = hlc;
                }
            }

            foreach (var hlc in element.RemoveStamps)
            {
                if (max is null || hlc.CompareTo(max.Value) > 0)
                {
                    max = hlc;
                }
            }
        }

        return max;
    }

    // --- slice-2b1 D0 (ADDITIVE): hydrate from / dump to persistence rows --------------------------

    /// <summary>
    /// Restore a persisted tag row: <paramref name="hlc"/>=null means a tombstone-only marker. Uses the
    /// SAME max-join as <see cref="ApplyAdd"/> (<see cref="MergeStamp"/>, ADR 0002 ERRATA E-1) — a
    /// hydrate path that just overwrote with "last row wins" would contradict the live-apply rule.
    /// NOTE (D2, GOREV slice-2c): this is an API-CONTRACT gate, not a production-path gate — the
    /// persisted PK is (entity_type, entity_id, set_name, element, add_tag), so production hydrate
    /// (<c>SyncRowHydration</c>) calls this AT MOST ONCE per (element, tag); the max-join only becomes
    /// observable if a caller invokes it twice for the same key (exactly what the D2 unit test does).
    /// </summary>
    public void LoadTag(string element, Guid tag, Hlc? hlc, bool cancelled)
    {
        var state = GetOrCreate(element);
        if (hlc is { } stamp)
        {
            MergeStamp(state.Adds, tag, stamp);
        }

        if (cancelled)
        {
            state.Cancelled.Add(tag);
        }
    }

    /// <summary>Restore a persisted remove stamp (C4 activity max).</summary>
    public void LoadRemoveStamp(string element, Hlc hlc) => GetOrCreate(element).RemoveStamps.Add(hlc);

    /// <summary>Reads the resulting state of a tag (for delta persistence). <c>hlc</c>=null for a tombstone-only tag.</summary>
    public bool TryGetTag(string element, Guid tag, out Hlc? hlc, out bool cancelled)
    {
        hlc = null;
        cancelled = false;
        if (!_elements.TryGetValue(element, out var state) || (!state.Adds.ContainsKey(tag) && !state.Cancelled.Contains(tag)))
        {
            return false;
        }

        hlc = state.Adds.TryGetValue(tag, out var stamp) ? stamp : null;
        cancelled = state.Cancelled.Contains(tag);
        return true;
    }

    /// <summary>All tag rows (adds and tombstone-only) for dump; <c>Hlc</c>=null means tombstone-only.</summary>
    public IEnumerable<(string Element, Guid Tag, Hlc? Hlc, bool Cancelled)> DumpTags()
    {
        foreach (var (element, state) in _elements)
        {
            var tags = new HashSet<Guid>(state.Adds.Keys);
            tags.UnionWith(state.Cancelled);
            foreach (var tag in tags)
            {
                yield return (element, tag, state.Adds.TryGetValue(tag, out var stamp) ? stamp : null, state.Cancelled.Contains(tag));
            }
        }
    }

    public IEnumerable<(string Element, Hlc Hlc)> DumpRemoveStamps()
    {
        foreach (var (element, state) in _elements)
        {
            foreach (var hlc in state.RemoveStamps)
            {
                yield return (element, hlc);
            }
        }
    }
}
