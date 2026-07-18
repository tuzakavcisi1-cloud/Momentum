using CsCheck;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

public sealed class ClampAndResyncProperties
{
    /// <summary>P5 (ADR 0002 K2-A4/1): clamp bound, within-skew inputs unchanged, absurd detection.</summary>
    [Fact]
    public void P5_clamp_bounds_and_absurd_detection()
    {
        (from wall in Gen.Long[0, 3_000_000_000_000]
         from counter in Gen.UInt[0u, 100u]
         from client in Gen.Int[0, 5]
         from receive in Gen.Long[1_000_000_000_000, 2_000_000_000_000]
         select (wall, counter, client, receive))
            .Sample(
                t =>
                {
                    var hlc = new Hlc(t.wall, t.counter, Ids.Client(t.client));
                    var clamped = HlcClamp.Clamp(hlc, t.receive);
                    var ceiling = t.receive + HlcClamp.MaxForwardSkewMs;

                    clamped.WallMs.ShouldBeLessThanOrEqualTo(ceiling);
                    if (t.wall <= ceiling)
                    {
                        clamped.ShouldBe(hlc); // within skew -> unchanged
                    }
                    else
                    {
                        clamped.WallMs.ShouldBe(ceiling);
                        clamped.Counter.ShouldBe(hlc.Counter);
                        clamped.ClientId.ShouldBe(hlc.ClientId);
                    }

                    HlcClamp.IsAbsurd(hlc, t.receive).ShouldBe(t.wall > t.receive + HlcClamp.AbsurdForwardMs);
                },
                iter: PropertyConfig.Iter);
    }

    /// <summary>P5: an op carrying an absurd HLC is rejected and leaves state unchanged.</summary>
    [Fact]
    public void P5_absurd_op_rejected_state_unchanged()
    {
        var state = new SyncState();
        var ingest = new SyncIngest(state, new ClientClockStore());
        const long receive = Scenario.BaseWall;
        var before = ProdProjector.Project(state);

        var op = Build.Op(1, 0, 0, "Task", Build.H(receive, 0, 0),
            fields: Build.Fields(("title", "x", Build.H(receive + HlcClamp.AbsurdForwardMs + 5_000, 0, 0))));

        ingest.Ingest(op, receive).Code.ShouldBe(IngestResultCode.RejectedAbsurdHlc);
        ProdProjector.Project(state).ShouldBe(before);
    }

    /// <summary>P11 (ADR 0002 K2-H7a): resync trigger and the (horizon,0) sentinel ordering.</summary>
    [Fact]
    public void P11_resync_trigger_and_horizon_sentinel()
    {
        (from x1 in Gen.ULong
         from s1 in Gen.Long[0, long.MaxValue]
         from x2 in Gen.ULong
         from s2 in Gen.Long[0, long.MaxValue]
         select (x1, s1, x2, s2))
            .Sample(
                t =>
                {
                    var since = new SyncCursor(t.x1, t.s1);
                    var gcHorizon = new SyncCursor(t.x2, t.s2);
                    ResyncPolicy.ShouldResync(since, gcHorizon).ShouldBe(since < gcHorizon);
                },
                iter: PropertyConfig.Iter);

        Gen.ULong.Sample(
            xid =>
            {
                var sentinel = SyncCursor.AtHorizon(xid);
                sentinel.Seq.ShouldBe(0);
                (sentinel < new SyncCursor(xid, 1)).ShouldBeTrue(); // sentinel < real row (server_seq >= 1)
            },
            iter: PropertyConfig.Iter);
    }
}
