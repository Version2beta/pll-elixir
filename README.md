# pll-elixir


The Rate, Pacer and complete Follower are implemented in this source checkout.
Version `0.1.0`.

This library helps audio/video, sensor, packet and device-buffer applications
pace units on their own timeline or learn the relationship to another clock.
A rational **Pacer** issues numbered slots without accumulated rounding drift.
A type-II, second-order phase-locked **Follower** estimates remote-clock phase
and frequency, filters delivery jitter, and maps ticks to local nanoseconds.
They work separately or together: follower trim can steer a pacer.


## Provenance, parity and non-goals

Source: Go `github.com/version2beta/pll`, revision
[`971282632129110794c9d6edd22026e9de2359be`](https://github.com/version2beta/pll/tree/971282632129110794c9d6edd22026e9de2359be). Basis: full `SPEC.md` and `README.md`, public
`rate.go`, `pacer.go`, `span.go`, `follower.go`, errors/status/package comments,
and rate/pacer/follower examples, boundary and differential-model tests.
The original is provenance, not a runtime dependency.

Functional equivalence means exact pacer results and equivalent follower
equations, state transitions, error categories and atomic failures on the shared
domain. It does not require Go ABI, duration formatting, writable span fields,
iterator protocol, zero-value controller structs, sentinel-error matching,
internal layouts, Go-specific fast paths, or mutating Go-style receivers.
There is **no transplanted claim** about Go benchmark times, zero allocations,
race-detector or simulator results, or real-time scheduler performance.

This is a library, not a sleeping rate limiter, token bucket, scheduler,
PTP/NTP/system-clock servo, counter-unwrapper, device driver, payload queue or
transport. The checkout includes a throughput harness and a bounded local pacing
demonstration, documented below. These are separate from the pure library;
full Go command parity and a simulator product are not included.
No GenServer, Agent, Task, supervision tree or application-start callback is
needed to use the core. Caller-owned OTP integration is an adapter concern.

## Requirements and installation

Requires Elixir >=1.15 and Erlang/OTP >=26, binary64 floats and arbitrary-precision
integers. No runtime or test dependencies. Runtime compatibility checks are listed
in the repository release record; a lower bound is not proof of every runtime pair.

After publication, add this dependency to your project's `mix.exs`:

```elixir
{:pll, "~> 0.1.0"}
```

Then run `mix deps.get`. The Hex package contains the library, not the repository's
benchmark or pacing scripts. The library starts no processes or application callbacks.

## First useful example

All times are **integer nanoseconds**, never floating seconds or implicit clocks.
Every state transition returns a new value; callers must retain it.

```elixir
alias PLL.{Pacer, Rate}

{:ok, rate} = Rate.units_per_second(48_000, 1)
{:ok, p0} = Pacer.new(rate)
{:ok, p1, a} = Pacer.due(p0, 0, 4096)
{:ok, p2, b} = Pacer.due(p1, 10_000_000, 4096)
{:ok, p3, c} = Pacer.due(p2, 25_000_000, 4096)
[{0, 1}, {1, 480}, {481, 720}] =
  Enum.map([a, b, c], fn span -> {span.first, span.count} end)
{:ok, {1201, 25_020_834}} = Pacer.next_due(p3)
```

At 10 ms slot 480 is exactly due; zero was already consumed. At 25 ms slot
1200 is due. The ceiling of `1201*10^9/48000` is 25,020,834 ns. A late call
produces backlog, not silent loss. The caller chooses processing, caps or skips.
Calling due again on p0 instead of p3 intentionally replays the original
schedule: immutability does not enforce single consumption for the caller.

## Public API

`ns` below means integer nanoseconds, `ticks` a signed integer counter.
Opaque states/values are structs, never PIDs. First/count and observation fields
are readable; callers must not manually alter structs or private fields.
No bang-constructor, async, blocking or implicit-clock API is included.

| Function / value | Return shape and meaning |
| --- | --- |
| `PLL.Rate.units_per_second(num, den)` | `{:ok, rate}` or error; gcd-reduced exact fraction. |
| `PLL.Rate.bits_per_second(bits, bits_per_unit)` | Same fraction bits/bits_per_unit. |
| `%PLL.Rate{}` | Invalid zero sentinel; num and den getters return 0. Construct valid values through factories. |
| `PLL.Rate.num(rate)`, `PLL.Rate.den(rate)` | Reduced integer terms. |
| `PLL.Rate.to_string(rate)` | `"48000 units/s"`, `"30000/1001 units/s"`, or `"invalid rate"`; also the String.Chars protocol. |
| `PLL.Pacer.new(rate)` | `{:ok, pacer}` or error; cursor/trim start at 0. |
| `PLL.Pacer.due(pacer, now_ns, max_count)` | `{:ok, next_pacer, span}` or error. |
| `PLL.Pacer.claim(pacer, n)` | `{:ok, next_pacer, span}` or error. |
| `PLL.Pacer.skip(pacer, now_ns, keep)` | `{:ok, next_pacer, skipped_count}` or error. |
| `PLL.Pacer.next_due(pacer)` | `{:ok, {cursor_slot, first_due_ns}}` or error. |
| `PLL.Pacer.set_trim(pacer, ppt)` | `{:ok, next_pacer}` or error. |
| `PLL.Pacer.trim(pacer)` | Integer ppt, no tagged wrapper. |
| `%PLL.Span{}` | Empty zero span (`first == count == 0`); other manual construction unsupported. |
| `span.first`, `span.count` | Read-only-by-contract issued extent. |
| `PLL.Span.time(span, i)` | Floored ns at relative index i; raises `Enum.OutOfBoundsError` for integer i < 0 or i >= count. |
| `PLL.Span.all(span)` | Fresh lazy Enumerable of `{slot, ns}` tuples; early termination avoids computing the rest. |
| `PLL.FollowerConfig.default(nominal)` | Config struct, exact defaults below; no nominal validation yet. |
| `%PLL.FollowerConfig{...}` | All ten fields below; omitted nominal is `%PLL.Rate{}`, omitted float fields are 0.0, omitted integer fields are 0 (an invalid zero config). Construct via default and struct update. No hidden config source. |
| `PLL.Follower.new(config)` | `{:ok, follower}` or error; validates all fields. Initially unanchored. |
| `PLL.Follower.observe(follower, local_ns, remote)` | `{:ok, next_follower, observation}` or error. |
| `PLL.Follower.local(follower, remote)` | `{:ok, local_ns}` or error. |
| `PLL.Follower.remote(follower, local_ns)` | `{:ok, remote_ticks}` or error. |
| `PLL.Follower.offset(follower)` | Binary64 fractional rate offset y, no tagged wrapper. |
| `PLL.Follower.trim(follower)` | Integer pacer-compatible ppt, no tagged wrapper. |
| `PLL.Follower.jitter(follower)` | Integer RMS error ns, no tagged wrapper. |
| `PLL.Follower.state(follower, now_ns)` | `{:ok, :acquiring | :locked | :holdover}` or error for invalid input. |
| `PLL.Follower.reset(follower)` | Fresh unanchored follower retaining config; direct state return, no error. |
| `%PLL.Observation{status: status, error_ns: ns}` | Observation value; error_ns is phase error, not an error result. |
| `PLL.Status.to_string(status)` | Status spelling described below. |
| `PLL.State.to_string(state)` | State spelling described below. |
| `PLL.Error.message(error)` | Stable human-readable error string described below. |

Observation statuses are atoms `:anchored`, `:accepted`, `:pending`, `:rejected`,
`:stepped`. States are `:acquiring`, `:locked`, `:holdover`. The status/state
string functions accept these atoms and return lowercase names. For Go string
compatibility they also accept byte integers: known status codes 1..5 map in
that order, state codes 0..2 map in that order; unknown codes yield `"Status(9)"`
or `"State(9)"` (including `"Status(0)"`). The library never emits unknown
statuses. Unsupported terms/codes outside 0..255 raise ArgumentError.
No mutable numeric enum objects are required.

### Types, bounds and errors

Despite BEAM big integers, deliberately retain compatibility envelopes.
`U=2^64-1`, `Imin=-2^63`, `Imax=2^63-1`. Rate terms and slot/count/cap/keep
arguments are integers in 0..U; valid rate terms and claim/cap counts are
positive. Pacer time inputs first fit signed 64-bit ns, then must be
nonnegative. Follower local/now inputs and remote ticks fit signed 64-bit and
may be negative. Config durations fit signed 64-bit; step_after and lock_count
also use signed 64-bit (the 64-bit Go baseline, not platform-dependent
Go int). Trim input fits signed 64-bit, then lies strictly between ±10^12.
Integer intermediate arithmetic is unbounded and must not overflow or wrap.

All fallible functions in the table return only `{:error, error}` on failure,
where error is `%PLL.Error{code: code, field: field, reason: reason}`. No
replacement state or partial value is returned on failure; the caller retains
the original immutable supplied state. Successful transformations put the new
state **before** the output value, consistently. set_trim returns only state
because it has no separate value. Queries never return a replacement state.
state/2 is tagged because its now argument needs boundary validation; getters
without scalar input and reset are direct returns.

| code | field/reason | Error.message |
| --- | --- | --- |
| `:invalid_rate` | nil/nil | `pll: invalid rate` |
| `:invalid_argument` | nil/nil | `pll: invalid argument` |
| `:overflow` | nil/nil | `pll: overflow` |
| `:order` | nil/nil | `pll: reading out of order` |
| `:not_anchored` | nil/nil | `pll: follower has no reading yet` |
| `:config` | snake-case field atom / reason string below | `pll: FollowerConfig.<field> <reason>` |

For scalar inputs to fallible functions, wrong types return invalid_argument;
integers outside their input envelopes return overflow before semantic checks.
Zero within-envelope rate terms return invalid_rate. Negative within-signed-
envelope pacer time, zero claim/cap, or out-of-open-interval trim returns
invalid_argument. Negative unsigned arguments are outside the envelope, not
wrapped. Validate **all scalar argument types/envelopes left-to-right before
any semantic checks**. Thus Rate.units_per_second(0,U+1) and
Pacer.due(p,-1,U+1) return overflow; a first scalar wrong type takes priority
over a later out-of-envelope integer. Then apply semantic checks. Struct/state
of the wrong kind is programmer misuse and raises ArgumentError, rather than fabricating a
controller. Span.time's non-integer index raises ArgumentError; integer invalid
indexes raise Enum.OutOfBoundsError rather than returning tagged results.

Config validation traverses fields in the table order, checking field type,
then envelope, then semantic rule. Wrong types and semantic violations return
`:config` with that field's listed reason; an integer beyond its envelope
returns `:overflow`. The three float fields require floats, not integers.
Elixir normally cannot construct NaN/Infinity float terms; there is no string
parser or nonfinite sentinel API. Nonfinite floating values, if supported by a
supported runtime boundary, must be rejected with the field's config
reason. Valid extreme finite inputs must still work without leaking arithmetic
exceptions from overflowing intermediate gain products.

**Every failure preserves supplied state and issued spans**, whether a tagged
error or a documented argument/index exception. Pending/rejected observations
are successful transitions: their order/window/outlier metadata can change.
No hidden process or mutable store can change old snapshots. Match error codes
and fields rather than parsing messages. Go's nil/zero error outputs are adapted
to the absence of a success tuple; do not return both a value and an error.

## Exact pacer contract

The nominal rate is reduced num/den units per second. Slots start at zero and
the cursor marks the next neither issued nor skipped. On one retained state
chain the cursor never decreases. Slot U is **never issued or skipped**, though
cursor U is allowed, so first+count<=U. A segment has start S, integer ns anchor
A and trim q ppt:

```text
T(s) = A + (s-S) * den * 10^21 / (num * (10^12 + q)), s >= S
initially S=0, A=0, q=0
```

Use exact integer/rational arithmetic even with 64-bit rate terms, huge slot
indexes and q=±(10^12-1). Period reduction/representation is private; no Go fast
path is required. Span.time is floor(T). Due compares exact T<=now, not its
floor: at period 8/3 ns slot 1 has time 2 but first becomes due at 3. Above
10^9 units/s, several slots can share a ns; times stay non-decreasing.

* **due:** negative now or zero cap is invalid. Find exact largest due slot L,
  capped at U. If none at/after cursor is due, return empty span at first=cursor
  and unchanged logical state. If cursor U itself is due, overflow. Otherwise
  issue cursor..min(L,U-1), at most max_count, oldest first, and advance.
  Earlier now values are allowed and may still drain their due backlog.
* **claim:** zero n invalid. Overflow if n>U-cursor or the last slot's **floor**
  exceeds Imax; otherwise issue/advance, whether due or not.
* **skip:** D is how many slots due could issue ignoring its cap, excluding U.
  Advance by D-min(D,keep), returning that count. keep=0 skips all available due
  slots. Negative now invalid; cursor U with that slot due overflows even if
  keep would retain it. For k>0, skip(now,k) then due(now,k) on the returned
  state yields newest k available due slots (or fewer if fewer available).
  For k=0 do not subsequently call due with a zero cap.
* **next_due:** cursor and ceil(T(cursor)); overflow for cursor U or a ceiling
  beyond Imax. A floor may fit even when its ceiling does not.
* **set_trim:** reject q<=-10^12 or q>=10^12. If unchanged, true no-op with no
  re-anchoring, even if cursor time cannot fit. Otherwise new S=cursor,
  A=floor(T_old(cursor)), q=new trim; overflow if A>Imax. Anchoring at floor
  moves phase earlier by less than 1 ns, preserves non-decreasing times and
  prevents accumulating fractional anchors. Previously issued spans keep their
  original segment timing; changing a later pacer never changes them.

An issued span covers first..first+count-1 and carries timing independently of
the pacer's lifetime. Treat it as read-only. Empty spans enumerate zero tuples
and have no valid time index. Manually altered/forged structs have no timing
guarantees. Issuing a span must not materialize its potentially enormous slots.

### More hand-checkable pacing examples

```elixir
alias PLL.{Pacer, Rate, Span}

{:ok, rate} = Rate.units_per_second(60_000, 2002)
{30_000, 1001, "30000/1001 units/s"} =
  {Rate.num(rate), Rate.den(rate), Rate.to_string(rate)}
{:ok, p0} = Pacer.new(rate)
{:ok, _p1, span} = Pacer.claim(p0, 4)
[{0, 0}, {1, 33_366_666}, {2, 66_733_333}, {3, 100_100_000}] = Enum.to_list(Span.all(span))
{:ok, byte_rate} = Rate.bits_per_second(50_000_000, 8)
{:ok, bytes0} = Pacer.new(byte_rate)
{starts, _bytes3} = Enum.map_reduce([1500, 400, 1500], bytes0, fn n, p ->
  {:ok, next, s} = Pacer.claim(p, n)
  {Span.time(s, 0), next}
end)
[0, 240_000, 304_000] = starts
{:ok, rate} = Rate.units_per_second(1000, 1)
{:ok, p0} = Pacer.new(rate)
{:ok, p1, 8} = Pacer.skip(p0, 10_000_000, 3)
{:ok, p2, old} = Pacer.due(p1, 10_000_000, 3)
[{8, 8_000_000}, {9, 9_000_000}, {10, 10_000_000}] = Enum.to_list(Span.all(old))
{:ok, p3} = Pacer.set_trim(p2, -500_000_000_000)
{:ok, _p4, slow} = Pacer.claim(p3, 3)
[{11, 11_000_000}, {12, 13_000_000}, {13, 15_000_000}] = Enum.to_list(Span.all(slow))
10_000_000 = Span.time(old, 2)
```

Boundary fixture: rate `(2_000_000_000,U)` has period Imax+1/2 ns. After
claiming slot 0, next_due overflows; due(Imax,1) is empty at first=1; claim(1)
succeeds with time Imax. At rate `(U,1)`, claim(U) reaches cursor U; due(0,1)
is empty but due(10^9,1), skip(10^9,0), claim(1) and next_due all overflow.
These must remain cheap span operations, not enumerate enormous lists.

## Follower configuration (all defaults and validation)

Start with `PLL.FollowerConfig.default(rate)`, then `%{cfg | window_ns: ...}`.
The config is immutable; changing a separate config value cannot reconfigure
an existing follower. Construct a new follower to change settings. Table order
is validation order. Reasons are exact strings; port field spellings
replace Go's CamelCase in errors.

| Elixir field (Go field) | Type | Default | Invalid when / config reason |
| --- | --- | --- | --- |
| `nominal` (`Nominal`) | Rate | supplied rate | invalid/zero rate: `must be a valid Rate` |
| `bandwidth_hz` (`Bandwidth`) | float | 0.1 | nonfinite or <=0: `must be finite and > 0` |
| `damping` (`Damping`) | float | sqrt(2)/2 | nonfinite or <=0: `must be finite and > 0` |
| `max_offset_ppm` (`MaxOffsetPPM`) | float | 500.0 | nonfinite, <=0 or >=1000000: `must be finite, > 0 and < 1000000` |
| `window_ns` (`Window`) | integer | 0 | <0: `must be >= 0` |
| `outlier_threshold_ns` (`OutlierThreshold`) | integer | 5_000_000 | <=0: `must be > 0` |
| `step_after` (`StepAfter`) | integer | 3 | <1: `must be >= 1` |
| `lock_threshold_ns` (`LockThreshold`) | integer | 100_000 | <0: `must be >= 0` |
| `lock_count` (`LockCount`) | integer | 8 | <1: `must be >= 1` |
| `holdover_after_ns` (`HoldoverAfter`) | integer | 5_000_000_000 | <=0: `must be > 0` |

Defaults target low-jitter readings. A suggested, never automatic, network
profile from Go uses bandwidth 0.005 Hz, window 1_000_000_000 ns, lock threshold
2_000_000 ns and outlier threshold 20_000_000 ns, other defaults unchanged.
This trades settling speed for filtering; source simulator measured lock times
and accuracy are not promises about this port.

## Follower state machine and numerical contract

Local ns uses a caller-chosen origin, possibly negative; remote ticks are
already unwrapped signed integers. Nominal period `Pn=float(den)*1e9/float(num)`
is binary64 ns. Retain integer local anchor I0 plus binary64 fraction frac,
remote anchor R0 and rate offset y. Initially unanchored, y=0, jitter=0,
acquiring. This is an immutable state value, not an autonomous process.

```text
predicted(r) = I0 + frac + (r-R0)*Pn/(1+y)
e = local - predicted(r)            # positive means arrived late
remote speed = nominal * (1+y)
```

For a difference fitting signed 64-bit, subtract integers first, then convert
the difference to float. Preserve small differences at huge absolute times.
If it exceeds signed 64-bit, use `float(a)-float(b)` as Go does, not wrapping or
converting absolute anchors for ordinary small displacements. Converting
large differences beyond 2^53 can lose low bits. Rebase on every loop update
with integer plus fractional local anchors, avoiding loss solely from uptime.

### observe, in order

1. After the first reading, local must be >= the last successful reading's
   local and remote strictly greater than its remote. Otherwise return order.
   Previous includes pending/rejected/stepped, not failed calls.
2. First reading (also after reset) anchors exactly to `(local,remote)`, y=0,
   clears histories and returns anchored with error_ns=0.
3. With window_ns=0, feed each later reading. With window_ns>0, the first later
   reading opens a window at its local time and becomes candidate; return
   pending with error_ns=0. Within its half-open window, replace candidate only
   for a **strictly smaller signed** phase error, not smaller absolute error.
   Ties keep the earlier candidate. Mapping stays fixed while window is open.
4. On elapsed local >= window_ns, feed the old candidate, return that result,
   then open a new window with the triggering reading. Compute its candidate
   error against mapping **after** flush. Compare elapsed time exactly even
   across signed-time extremes; do not overflow start+window. No timer or flush
   API exists: the final pending candidate waits for another boundary reading.
   Returned error and last accepted time refer to the candidate, not necessarily
   the input which caused the flush.
5. If feeding overflows the new integer local anchor, return overflow and no
   next state: candidate, order, window, outlier and all other supplied state
   remain available unchanged. No partial successful transition is exposed.

### Feeding a sample

Use unrounded binary64 phase error e in ns. For phase-domain comparisons,
convert outlier_threshold_ns and lock_threshold_ns to binary64 (as in the
pinned Go source); do not use BEAM exact mixed float/integer comparison.
Input envelopes, order and elapsed duration comparisons remain exact integers.

* If abs(e)>outlier_threshold_ns, it is an outlier. A run continues only when
  abs(e-e_first)<=threshold, comparing with the **first** error in the run;
  otherwise start a new run of length 1. At step_after, re-anchor exactly to
  the fed sample, keep y, clear lock/jitter/outlier run, record its local as
  last accepted and return stepped. Otherwise return rejected: mapping, lock,
  jitter and last accepted stay unchanged, but order and outlier metadata can
  change in the new state. An inlier ends the run only on successful feed.
* For an inlier, dt is local seconds from last anchor/step/loop update. If
  dt>0, use the **old** mapping to compute:

  ```text
  wn = 2*pi*bandwidth_hz
  x = min(0.5, wn*dt)
  kp = min(1, 2*(damping*x))
  y_new = clamp(y - (x*x/dt)*e/1e9, -max_offset_ppm*1e-6, +max_offset_ppm*1e-6)
  v = (predicted_old(remote)-I0) + kp*e
  whole = round_away(v)
  I0_new = I0 + whole; frac_new = v-whole; R0_new = remote
  ```

  Check I0_new against signed 64-bit before returning new state; update the
  loop reference time to sample local. The capped product stabilizes sparse
  readings and extreme finite gains. Evaluate caps without generating an
  overflowing float or arithmetic exception: BEAM does not expose Go-style
  Infinity intermediates. Do not cap dt first and then multiply Infinity by
  zero. All positive finite bandwidth/damping inputs, including binary64
  extremes, must work. With dt=0 mapping/rate/reference do not change.
* Every accepted inlier, including dt=0, increments lock run up to lock_count
  if abs(e)<=lock_threshold_ns; otherwise clears it. Equality counts.
* Jitter: first accepted inlier after anchor/step/reset sets m=e*e; later
  accepted inliers use `m += (e*e-m)/16`. Record sample local as last accepted
  and return accepted. Anchor/step do not count as jitter samples. Jitter is
  0 until two accepted inliers, then round_away(sqrt(m)) ns, saturated to signed
  duration range. Use unrounded e, not observation.error_ns.

Accepted/rejected/stepped observation.error_ns is round_away(e), saturated to
[Imin,Imax]; anchored/pending errors are zero. A finite phase error outside the
signed duration range is not itself a failure.

### Queries, rounding, holdover and reset

round_away means nearest integer, half ties away from zero. Mapping rounds
**displacement**, not absolute time:

* local(r) = I0 + round_away(frac + (r-R0)*Pn/(1+y)).
* remote(l) = R0 + round_away(((l-I0)-frac)*(1+y)/Pn).
* Both return not_anchored before anchoring, overflow if final result does not
  fit signed 64-bit. Add rounded whole displacement exactly to integer base,
  preserving base low bits. Allow displacement outside signed 64-bit when it
  cancels with the anchor to a fitting result; retain Go wide-displacement
  behavior. Never reject solely because displacement itself exceeds Imax.
* offset returns y. trim returns round_away(y*10^12), saturated to
  ±999_999_999_999, always inside Pacer.set_trim's range even at near-maximum
  offset. set_trim may still overflow a particular pacer's new anchor; updating
  two controller states is the caller's responsibility, not a shared transaction.
* state(now) returns holdover iff anchored and now-last_accepted>holdover_after_ns,
  using exact elapsed comparison across signed range. Equality is not holdover;
  earlier now is allowed. Otherwise locked if lock run reached lock_count,
  acquiring if not (also before anchoring). Pending/rejected readings do not
  refresh last accepted. Holdover is only a query result: mapping continues at
  last estimated rate; it does not start/stop a timer or change loop state.
* reset forgets mapping, y, input order, window, outlier run, lock and jitter,
  retaining config. The next reading may anchor at an earlier time/tick.

Binary64 follower estimates are not exact rational time. Arbitrarily distant
extrapolation is not nanosecond-accurate, and round trips can lose ticks/ns.
There is no exact inverse or universal bit-identical cross-runtime float
promise. Rounding, integer anchoring and saturation rules still apply. At a
0.5 ns period with anchor `(local=1,remote=0)`, local(-1) is
`1+round_away(-0.5)=0`; with anchor `(-1,0)`, local(1) is 0.

### Cross-module success and failure

```elixir
alias PLL.{Error, Follower, FollowerConfig, Pacer, Rate, Span}

{:ok, rate} = Rate.units_per_second(1000, 1)
cfg = %{FollowerConfig.default(rate) | bandwidth_hz: 1.0, damping: 1.0}
{:ok, f0} = Follower.new(cfg)
{:error, %Error{code: :not_anchored}} = Follower.local(f0, 0)
{:ok, f1, %{status: :anchored, error_ns: 0}} = Follower.observe(f0, 0, 0)
# 1 ms late, dt=1.001 s, x=0.5, kp=1:
{:ok, f2, %{status: :accepted, error_ns: 1_000_000}} = Follower.observe(f1, 1_001_000_000, 1000)
{:ok, 1_001_000_000} = Follower.local(f2, 1000)
-249_750_250 = Follower.trim(f2)  # y = -0.25 / 1.001 * 0.001
{:ok, p0} = Pacer.new(rate)
{:ok, p1, _initial} = Pacer.claim(p0, 1000)
{:ok, p2} = Pacer.set_trim(p1, Follower.trim(f2))
{:ok, p3, span} = Pacer.claim(p2, 2)
[{1000, 1_000_000_000}, {1001, 1_001_000_249}] = Enum.to_list(Span.all(span))
before = {Follower.offset(f2), Follower.local(f2, 1000), Pacer.next_due(p3), Pacer.trim(p3)}
{:error, %Error{code: :order}} = Follower.observe(f2, 1_001_000_000, 1000)
{:error, %Error{code: :invalid_argument}} = Pacer.set_trim(p3, 1_000_000_000_000)
^before = {Follower.offset(f2), Follower.local(f2, 1000), Pacer.next_due(p3), Pacer.trim(p3)}
bad = %{FollowerConfig.default(rate) | bandwidth_hz: 0.0, lock_count: 0}
{:error, %Error{code: :config, field: :bandwidth_hz, reason: "must be finite and > 0"}} = Follower.new(bad)
# There is no next-state value to accidentally retain from a failed transition.
```

Additional deterministic workflows, each starting from a fresh follower and
retaining each successful next state:

| Inputs/settings | Promised outcome |
| --- | --- |
| Default 1000 ticks/s; observe(0,0), then (k*10_000_000,k*10), k=1..8 | Anchored, eight accepted errors 0; offset/trim/jitter 0; locked at 80 ms. At now=5_080_000_000 still locked, at 5_080_000_001 holdover. State results are tagged ok tuples. |
| Same defaults; anchor(0,0), then (10_000_000,2010),(20_000_000,2020),(30_000_000,2030) | Errors -2_000_000_000: rejected, rejected, stepped; y=0, local(2030) returns ok 30_000_000; acquiring, jitter 0. |
| Rate 10^9, window_ns=4; (0,0),(1,1),(4,4),(5,5) | Anchored, pending, pending, accepted; equal errors retain candidate (1,1), (5,5) opens next window. Last accepted=1, not 5. |
| Rate 10^9; anchor(Imax,0); local(1) | Tagged overflow; original immutable follower unchanged. |

## Ownership, effects and concurrency

All values, including Pacer/Follower states and configuration, are immutable.
Each transition produces a new state (or an equivalent unchanged value for a
no-op). Internal immutable segments can be shared; issued spans retain old
segment timing. Freely share snapshots between processes, but one logical
schedule/loop should have **one owner retaining the current state**. Concurrent
branches from an old snapshot can issue overlapping slots or learn divergent
mappings; that is replay, not global coordination. The library does not serialize
callers or start an owner process. Configuration updates never alter followers
already created. Mutating struct fields by hand/forging state is unsupported;
no persistence or serialized layout is promised.

The library performs **no I/O, network access, timers, sleeping, process/task
creation, implicit clock reads, environment reads or credential access**.
It only transforms in-memory timing/config/history and never touches payloads.
Caller adapters provide monotonic elapsed ns, consistent origins, clock reads,
remote-counter unwrapping, wakeups, OTP ownership/cancellation, backpressure,
queues, devices and transport. Pacer earlier-now tolerance is not follower
input-order tolerance; adapters must distinguish them.

Build/test execution is separate from library runtime: Mix/ExUnit start VM/test
processes and write `_build`/compiler caches; format can write sources. Such
explicit development-tool effects do not contradict the runtime contract.
The deterministic checks require no network or credentials.

## Verification

From the repository root:

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test --seed 0
```

Tests cover exact pacing against an independent rational oracle, immutable
snapshots, validation and failure preservation, follower windows/outliers/steps,
synthetic-clock scenarios and pinned public-Go fixtures. See
[corpus documentation](https://github.com/Version2beta/pll-elixir/blob/release/0.1.0/docs/corpus.md) for provenance and numerical tolerances.
Finite fixtures do not establish universal parity, real-device behavior or
portable performance. Historical results are recorded in
[Stage 3 verification](https://github.com/Version2beta/pll-elixir/blob/release/0.1.0/docs/stage3-verification.md).


## Throughput benchmark

This dependency-free developer harness measures this Elixir implementation, not
Go speed or real-time scheduling. It is separate from the pure runtime library.
The harness uses the public library API and runs bounded workloads.

```sh
mix run scripts/throughput.exs --smoke
mix run scripts/throughput.exs
mix run scripts/throughput.exs --iterations 1000 --samples 3 --warmup 100
```

No environment configuration, config files, workload selection or positional
arguments. `--smoke` must stand alone: 12 iterations, 2 samples, 4 warmup iterations
per workload. Otherwise defaults are 1000 iterations, 3 samples, 100 warmup.
Each integer must be canonical positive decimal; iterations/warmup <=10000,
samples <=10; unknown, duplicate, missing, malformed or oversized options fail
with stderr and exit 2 before workloads. At most 900000 measured logical ops plus
90000 warmup ops across all nine workloads; each op is bounded (span visits 64
items). These bound work, not elapsed wallclock on arbitrary hardware.

Each workload warms up once, then prepares a fresh independent state outside each
sample's timer, and **chains every next immutable state within that sample**.
Workloads/samples run sequentially, no sleeping or live observation timestamps.
All library input clocks are deterministic integer counters. The harness uses only public library calls, not private fields or an external
implementation.

| Workload | One logical op; units per op |
| --- | --- |
| due_one | Pacer.due at i-1 ns, cap 1; 1 issued slot |
| due_batch | Pacer.due at 64*i-1 ns, cap 64; 64 issued slots |
| claim | Pacer.claim(1500); 1500 issued slots |
| skip | Pacer.skip at 64*i-1 ns, keep 0, plus next_due sink query; 64 skipped slots |
| span | Fully reduce Span.all over a preissued 64-slot span into sum(slot+ns); 64 generated tuples |
| inlier | Follower.observe at (10*i,10*i); 1 reading, accepted |
| window | observe(i,i), window_ns=4; 1 reading; accepted floor((n-1)/4), remaining pending |
| outlier | observe(10*i,10*i+100), threshold 10, step_after=n+1; 1 reading, rejected |
| step | observe(10*i,10*i+100*ceil(i/3)), threshold 10, step_after=3; 1 reading; floor(n/3) stepped, remaining rejected |

All rates are 10^9 units/s (1 ns period), zero pacer trim. Followers use default
config except those listed (both outlier_threshold_ns and lock_threshold_ns are
10 ns for every follower workload); each sample
anchors at (0,0) outside timing. Warmup uses its own n for outlier step_after.
Issuance does not enumerate spans: checksum adds first+count. Skip checksum adds
next cursor+due time. Follower checksum adds observation error+input local+remote;
status counts are observed, not assumed. Validate actual calls, units and exact
status distributions after timing; mismatch raises rather than mislabels a row.
Span enumeration is intentionally separate from issuance and repeatedly consumes
the same immutable span, generating every tuple anew. Other workloads must not
repeatedly use initial states. Checksums/counts are emitted, never dead sinks.

Header labels: schema name `pll-throughput-v1`, Elixir/OTP, system architecture,
online schedulers, config and **library_revision**, pinned to the protected
library baseline `03a99baca1db2872f6e6f9298914aab9e2242a2a`. This identifies
library code, NOT the benchmark implementation's checkout SHA/dirty status; record
`git rev-parse HEAD` separately when comparing local runs. No environment dump.
One stdout map per sample includes workload/sample, calls, units, statuses,
checksum and the following non-aggregated metrics:

* elapsed_ns: monotonic nanoseconds around execute only, including loop, state
  threading, accounting and sink overhead; not a pure isolated API latency.
* ns_per_op = elapsed_ns/calls; ops_per_s = calls*10^9/elapsed_ns.
* units_per_s = units*10^9/elapsed_ns. Slots/tuples/readings differ as above:
  do not confuse batch unit throughput with call throughput.
* process_memory_delta_bytes: self process memory after minus before sample,
  signed bytes (may be negative). Not peak memory or allocation volume.
* vm_gc_count_delta and vm_reclaimed_words_delta: differences of BEAM VM-wide
  `:erlang.statistics(:garbage_collection)` counters, including unrelated work;
  reclaimed **words**, not bytes/allocations or per-op allocations. Introspection
  brackets the timer and includes some measurement/validation bookkeeping (but
  validation itself occurs after the second snapshot). No forced GC.

Nonpositive measured elapsed time fails rather than divides by zero. Output,
metadata, warmup and setup are outside timing. Retained state lives through the
second clock; a report keeps scalar sinks/counts, not a permanent state history.
No thresholds, automatic tuning, Go comparison claims or statistical confidence
claims; short smoke times are only finite execution evidence. Repeat samples and
inspect noise before drawing conclusions.

Tool-only effects are explicitly permitted: monotonic clock reads, process memory
and VM-wide GC introspection, runtime/platform queries and stdout/stderr. Mix may
write ignored build caches/start VM processes as usual. The harness itself does
not write results, spawn workload processes, read environment/secrets, contact
network, sleep or tune VM globals. No permanent results/artifact format is added.


## Local real-time pacing demonstration

This checkout-only tool drives discard or local UDP with the Elixir pacer.
It is separate from the pure library and the throughput microbenchmark.
It supports pacer mode only: no ticker, rate search, remote destinations or
arbitrary payloads. Writer acceptance does not measure receipt or loss.
Historical same-machine results and their limits are recorded in
[pacing verification](https://github.com/Version2beta/pll-elixir/blob/release/0.1.0/docs/pacing-verification.md).


### Commands and effects

Run from the repository root:

```sh
mix run scripts/pacing.exs
mix run scripts/pacing.exs --bps 19392658 --unit-bytes 188 --seconds 5
mix run scripts/pacing.exs --bps 19392658 --unit-bytes 188 --seconds 5 --udp loopback --per-datagram 1
mix run scripts/pacing.exs --bps 19392658 --unit-bytes 188 --seconds 5 --udp loopback --per-datagram 7
```

Defaults: 19,392,658 bps, 188 bytes, 5 seconds, discard, grouping 1,
pacer only. This is approximately ATSC payload rate: 12,894.0545 units/s,
77.5551 microseconds/unit. Zero-filled bytes are timing payload, not valid MPEG-TS.
No flags means **no network**. Only literal `--udp loopback` enables IPv4
127.0.0.1, ephemeral ports, one receiver reading/discarding and one sender;
no DNS, remote destination, file payload or result file. Receiver read buffer
request 8 MiB is best-effort and not evidence of effective buffer size.

Only the shown value flags are supported. No config/environment inputs, positional
arguments, unknown/duplicate/missing options or alternative destinations.
All numeric strings canonical positive decimals: bps 1..100000000, unit bytes
1..65507, seconds integer 1..10, per-datagram 1..65507 with product <=65507
(even in discard, where effective grouping is 1). Before allocation, timers or
sockets, validate all types/products plus `1+ceil(bps*seconds/(8*unit_bytes))
<=1000000`. Also cap actual offers and calls/lateness samples at 1,000,000 each;
cap exhaustion is an incomplete failed trial, not a sustained result. Due cap
4096 is fixed. Bounds are tool constraints, not library API changes.

Tool-only effects: clocks, cancellable timed waits, bounded coordinator/worker
and loopback receiver processes, local sockets, runtime metadata and stdout/stderr;
Mix build caches as usual. No installs, dependencies, subprocess comparison runner,
VM-global tuning, secrets, persistent results or external actions. The tool does not launch Go comparisons. Report revision/dirty
state separately using operator Git commands, plus runtime/platform/schedulers
and all effective options with each comparison. No environment dump.

### Timing and failures

Isolated `scripts/pacing.exs` entrypoint and `scripts/pacing/` helpers, using only
public `PLL.Rate`, `PLL.Pacer`, `PLL.Span`; no private fields/algorithm changes.
A single worker retains each returned immutable pacer state, origin and counters;
there is no shared mutable schedule or implicit library clock. Inject tool-local
clock/wait/writer seams for deterministic tests, not a new public library API.

Use `System.monotonic_time(:nanosecond)-origin` integer offsets. After processing
a span, recompute remaining time to next due/deadline; if positive use a
cancellable receive timeout rounded **up** to whole milliseconds. Do not use
`Process.sleep` as a microsecond timer, repeated zero-time polling, busy-spin
waiting or scheduler changes. Coarse wakeups intentionally produce batches;
when already overdue, immediately drain another capped batch, checking deadline
and cancellation between calls and cancellation between units. Never skip to hide
backlog. Normal deadline stops new calls, finishes current batch and flushes
partial grouping; include final write in elapsed and backlog as Go does.

Coordinator monitors worker/receiver, imposes duration+2 seconds runtime guard
(excluding Mix startup), and kills the worker if it does not stop. Cooperative
cancellation is an internal injected/test seam, not an operator-exposed command
or signal API; the production coordinator does not send cancellation messages.
Worker owns sender socket; receiver owns read socket. Normal/error paths close
resources and terminate receiver; process death must release owned sockets and
pending timers. Cancellation aborts buffered output, reports incomplete/nonzero,
never a sustained verdict. Socket/open/read/send/flush failures stop the trial;
no retries, cross-trial buffers or false accepted counts. UDP success counts
whole datagram payload only, not receipt. Fake writer tests cover partial/error
accounting even though the UDP adapter reports whole-send success or error.
Ctrl-C/VM termination may prevent a final report; it is not a successful trial.
Wall guard is a safety bound subject to OS/VM scheduling, not a hard real-time SLA.

Report target, offered units, accepted payload bytes, elapsed ns, writer Mbps,
backlog ns, call/wake-up count, average/max units per call, nonempty lateness sample
count and median/p99/max ns with Go's quantile rule; distinguish effective datagram
grouping and send-call count from Due-call count. Print roughly once/second like
Go, inside timing. Go lacks a send-call metric, so do not claim identical output.
Report completed/deadline/error/cancel/cap/guard stop reason and timing verdict.
`sustained` is timing-only (nonempty deadline completion, backlog and p99 bounds);
`demonstration_pass` additionally checks accepted-byte accounting and bitrate.
The CLI exits 0 on deadline completion, not on a passing demonstration verdict;
operators must inspect `demonstration_pass` and record every failed trial.
Slot zero is due immediately: short runs can appear fast by up to about one unit;
no start-slot subtraction or forced unit-count equality across runtimes. Backlog
is cursor lag, not queue depth. Lateness is oldest scheduled unit at call entry,
not each unit's send time, network/receiver jitter or a bound on every unit.
