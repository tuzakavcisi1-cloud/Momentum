namespace Momentum.Domain.Sync;

/// <summary>
/// IS-EMRI-o85-B (GOREV slice-3a D2 desenin birebir tekrari): pure, IO-less projection from
/// <see cref="EntityState"/> to the materialized "projects" row shape. Project's registry has no
/// int/date/Guid scalar (only name/color/isDeleted/pos), so <see cref="MalformedFields"/> is always
/// empty for this entity type -- TaskListProjection'daki ayni gerekcenin tekrari.
/// 🔴 `members` (OrSet) OKUNMAZ: paylasim DILIM 3'un isi; `task_tags`in muadili `project_members`
/// O DILIMDE acilir -- bugun acmak, ekrani ve akisi olmayan bir tablo dogurur. Veri kaybi yok:
/// `members` yazimlari `sync_orset_tags`e zaten dusuyor (registry degismedi, yalniz materyalizasyon
/// bu alani atliyor).
/// </summary>
public sealed record ProjectProjection(
    Guid EntityId, string? Name, string? Color, bool IsDeleted, string? Pos,
    bool HasDeleteEditConflict, IReadOnlyList<string> MalformedFields)
{
    public static ProjectProjection From(Guid entityId, EntityState state)
    {
        ArgumentNullException.ThrowIfNull(state);
        var malformed = new List<string>();

        var name = ProjectionFields.ReadText(state.Fields, "name");
        var color = ProjectionFields.ReadText(state.Fields, "color");
        // CHANNEL WARNING (mutant-16'nin muadili): pos bir Fractional -- YALNIZ state.Orders'ta yasar.
        // state.Fields'ten okumak (savunma amacli TryGetValue ile bile) sonsuza dek sessizce NULL doner.
        var pos = ProjectionFields.ReadText(state.Orders, "pos");

        return new ProjectProjection(
            entityId, name, color, state.IsDeleted, pos, state.HasDeleteEditConflict, ProjectionFields.FinalizeMalformed(malformed));
    }
}
