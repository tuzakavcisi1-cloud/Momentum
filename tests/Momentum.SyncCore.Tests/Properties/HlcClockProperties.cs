using CsCheck;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

/// <summary>
/// P12 (ADR 0002 K2-A2/A3, K2-H): HLC clock laws — Tick/Receive strictly increase Local; Receive(m) is
/// &gt;= m; counter overflow carries into WallMs (Tick and all three Receive branches).
/// </summary>
public sealed class HlcClockProperties
{
    private sealed record ClockAction(bool IsTick, long TimeOffset, long MsgWallOffset, uint MsgCounter, int MsgClient);

    private static readonly Gen<ClockAction> GenAction =
        from isTick in Gen.Bool
        from timeOffset in Gen.Long[-100_000, 100_000]
        from msgWallOffset in Gen.Long[-200_000, 200_000]
        from msgCounter in Gen.UInt[0u, 1_000u]
        from msgClient in Gen.Int[0, 5]
        select new ClockAction(isTick, timeOffset, msgWallOffset, msgCounter, msgClient);

    [Fact]
    public void P12_tick_and_receive_are_monotone_and_receive_dominates_message()
    {
        GenAction.Array[1, 25].Sample(
            actions =>
            {
                var time = new ManualTimeProvider(Scenario.BaseWall);
                var clock = new HlcClock(time, Ids.Client(0));
                var previous = clock.Local;

                foreach (var action in actions)
                {
                    time.SetUnixMs(Scenario.BaseWall + action.TimeOffset);
                    Hlc next;
                    if (action.IsTick)
                    {
                        next = clock.Tick();
                    }
                    else
                    {
                        var message = new Hlc(Scenario.BaseWall + action.MsgWallOffset, action.MsgCounter, Ids.Client(action.MsgClient));
                        next = clock.Receive(message);
                        (next.CompareTo(message) >= 0).ShouldBeTrue();
                    }

                    (next.CompareTo(previous) > 0).ShouldBeTrue();
                    previous = next;
                }
            },
            iter: PropertyConfig.Iter);
    }

    [Fact]
    public void P12_tick_counter_overflow_carries_into_wall()
    {
        var time = new ManualTimeProvider(1000);
        var clock = ClockWithLocal(time, 1000, uint.MaxValue);

        time.SetUnixMs(1000); // wall not greater than Local.WallMs, Local.Counter == MaxValue
        clock.Tick().ShouldBe(new Hlc(1001, 0, Ids.Client(0)));
    }

    [Fact]
    public void P12_receive_counter_overflow_carries_into_wall_all_branches()
    {
        // branch 1: w' == Local.WallMs == m.WallMs, max counter overflows.
        var t1 = new ManualTimeProvider(1000);
        var c1 = ClockWithLocal(t1, 1000, uint.MaxValue);
        t1.SetUnixMs(1000);
        c1.Receive(new Hlc(1000, 5, Ids.Client(2))).ShouldBe(new Hlc(1001, 0, Ids.Client(0)));

        // branch 2: w' == Local.WallMs (only), Local.Counter == MaxValue.
        var t2 = new ManualTimeProvider(1000);
        var c2 = ClockWithLocal(t2, 1000, uint.MaxValue);
        t2.SetUnixMs(1000);
        c2.Receive(new Hlc(500, 3, Ids.Client(2))).ShouldBe(new Hlc(1001, 0, Ids.Client(0)));

        // branch 3: w' == m.WallMs (only), m.Counter == MaxValue.
        var t3 = new ManualTimeProvider(1000);
        var c3 = new HlcClock(t3, Ids.Client(0));
        t3.SetUnixMs(1000);
        c3.Tick(); // Local = (1000, 0)
        t3.SetUnixMs(1500);
        c3.Receive(new Hlc(2000, uint.MaxValue, Ids.Client(2))).ShouldBe(new Hlc(2001, 0, Ids.Client(0)));
    }

    // Drives a fresh clock's Local to (wall, counter) via a single receive (counter >= 1).
    private static HlcClock ClockWithLocal(ManualTimeProvider time, long wall, uint counter)
    {
        time.SetUnixMs(wall);
        var clock = new HlcClock(time, Ids.Client(0));
        clock.Receive(new Hlc(wall, counter - 1, Ids.Client(9)));
        return clock;
    }
}
