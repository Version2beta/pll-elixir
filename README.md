# pll-elixir — exact pacing and clock following

> **Stage 3 kit passed parent review (kit and 159-record public-Go corpus); one owner-authorized Stage 3 implementation run is authorized and has not run at this commit.**
> Stage 1 and bounded Stage 2 are implemented. Supplied Stage 3 history paths are
> intentionally unfinished until that run. The full normative follower contract below is unchanged.
> Stage 2 run limitations/approvals below are historical, not current launch authority.

This library helps audio/video, sensor, packet and device-buffer applications
pace units on their own timeline or learn the relationship to another clock.
A rational **Pacer** issues numbered slots without accumulated rounding drift.
A type-II, second-order phase-locked **Follower** estimates remote-clock phase
and frequency, filters delivery jitter, and maps ticks to local nanoseconds.
They work separately or together: follower trim can steer a pacer.

## Decisions and review gate

| Status | Decision and rationale |
| --- | --- |
| Approved | The user requested Elixir and Python versions of the same Go library, sibling directories `../pll-elixir` and `../pll-python`, and comprehensive README-first docs before readme-loop implementation stages. |
| Superseded | The earlier README-only assignment prohibited kits/Git/implementation. The approvals below now authorize bounded Stage 1 kit preparation and one owner-authorized Stage 1 implementation run, which has completed. |
| Approved | Local Mix package name `pll`, namespace `PLL`, Elixir >=1.15 with Erlang/OTP >=26; builtins/standard library only, ExUnit tests. Broader runtime testing and Hex publication availability are not established. |
| Approved | Validate all scalar argument types/envelopes left-to-right before semantic checks: Rate.units_per_second(0,U+1) and due(p,-1,U+1) return overflow. This resolves mixed-invalid-input precedence. |
| Approved | Existing README design: the API, integer envelopes, tagged errors, immutable explicit state transitions, numerical compatibility and library-only scope below. First bounded stage: exact Rate/Pacer/Span; follower contracts are preserved for later kits. |
| Approved | Retain source MIT licensing/attribution; Stage 1 carries the source LICENSE. Local development version `0.0.0-dev` is not a release. Publication/release metadata requires later review. |
| Approved | Initialize Git on a non-main branch and commit the verified Stage 1 kit, preserving existing work. Later runner commits of passing attempts and discards of only attempt-owned failed changes are authorized; no remotes, installs or publication; later kits require separate approval. |
| Approved | Stage 1 implementation loop authorized: Haiku-5.5 for normal first attempts; gpt-6.1-sol high for the second attempt; gpt-6.1-sol max for the final attempt, using the exact commands below with MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200 and JUDGE_TIMEOUT=300. Total budget $25. That Stage 1 authorization did not authorize later kits; Stage 2 preparation is separately approved below. |
| Approved | Provider-side spending cap: owner-confirmed as configured for this $25 budget. Not independently verified. The unchanged runner does not enforce, track or aggregate dollars; it bounds attempts and time only. |
| Superseded | Stage 2 kit preparation and kit commit only; launch then required parent review. Superseded by the Stage 2 run decisions below. No increased $25 budget, installs/remotes/publication/Stage 3 or preparation model calls. |
| Approved | Parent review of the verified Stage 2 kit (kit commit `67813b6`) is complete. The Stage 2 implementation loop is authorized with the exact commands in the Stage 2 kit operation section: Haiku-5.5 for normal first attempts, gpt-6.1-sol high for the second attempt and gpt-6.1-sol max for the final attempt, using MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200 and JUDGE_TIMEOUT=300. Prior permissions continue for runner commits of passing attempts and discards of only attempt-owned failed changes. The original $25 total budget is not expanded. That run did not authorize Stage 3; its separate preparation approval follows. Later kits, installs, remotes and publication remain unauthorized. |
| Approved | Stage 2 provider-side spending caps: owner-confirmed as configured. Not independently verified. The unchanged runner does not enforce, track or aggregate dollars; total spend and remaining funds are unknown. |
| Superseded | Temporary Stage 2 unsupported observe boundary described below preserves state for windowed/outlier observations rather than inventing partial window/outlier behavior. Final Stage 3 contract is unchanged. |
| Approved | Stage 3 overlay kit preparation and verified complete kit commit only, followed by parent review before any coding loop. Complete windows/outliers/steps, edge/retry cases, deterministic synthetic integration, public-Go differential corpus and all examples/regressions. Prior runner commit/discard permissions remain scoped to passing attempts/attempt-owned failures. No preparation model calls, installs, remotes, publication or later kits. Original $25 total is not expanded; caps remain owner-confirmed, not independently verified, spend unknown. |
| Approved | Dependency-free line-oriented corpus with decimal integers and hex binary64; separately authorized temporary offline generator against the pinned public Go API, leaving ../pll untouched. No network or dependency fetches. |
| Approved | Stage 3 parent review passed for the verified kit and the 159-record public-Go corpus. This records no normative API or test change. One Stage 3 implementation run is authorized with the exact command in the Stage 3 kit operation section: claude-haiku-5-5 for normal attempts, gpt-6.1-sol high for the second attempt and gpt-6.1-sol max for the final attempt, using MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200 and JUDGE_TIMEOUT=300. Prior runner commit and discard permissions apply only to passing attempts and attempt-owned failures. The original $25 total is not expanded; provider caps are owner-confirmed, not independently verified, and spend is unknown. No later kits, installs, remotes or publication are authorized. |
| Deferred | Aggregate spend accounting, remaining-budget tracking and runner-side dollar enforcement. Not established; any later paid run needs a new decision on these. |
| Deferred | Hex publication, broader runtime matrix, release automation, OTP adapters, CLI, simulator product and benchmarks; decide before the affected stage. No task may assume them. |

**Current gate: Stage 3 parent review passed; one authorized Stage 3 implementation run (not yet executed at this commit).**
See [Stage 3 verification](docs/stage3-verification.md) and operation commands at
end of this README. The original total $25 constraint is unchanged; provider caps
are owner-confirmed, not independently verified, and spend/remaining are unknown.

The following temporary boundary is historical Stage 2 provenance only. Stage 3
supersedes its emissions without changing the final normative contract. The legacy
unsupported message remains for historical/manual error values; completed final
observe paths never emit unsupported.

### Historical temporary Stage 2 execution boundary (approved then; superseded in Stage 3)

The final follower contract below remains normative for the finished library.
Stage 2 implements only config, mapping and the inlier loop. It is **not a
complete follower**. For this stage only, observe returns
`{:error, %PLL.Error{code: :unsupported, field: nil, reason: nil}}`, with message
`pll: unsupported in Stage 2`, for every config with `window_ns > 0` (even the
first anchor), and, for `window_ns == 0`, for subsequent samples whose unrounded
old-mapping phase error satisfies `abs(e) > outlier_threshold_ns`. Equality is
an inlier. Wrong state kind raises first, then scalar types/envelopes are
validated left-to-right, then existing input order is checked, then this boundary
is applied. A window=0 first reading anchors normally. Unsupported calls retain
all supplied state, including order and last-accepted time: no pending/rejected
metadata is consumed. Reset retains config, including this boundary. Stage 3
will replace this temporary error with the final windows/outliers/steps contract;
no Stage 2 test or result establishes those deferred behaviors.

**Local implementation freedom:** private helpers, integer
algorithms and immutable segment sharing within the kit's complete types/seams,
provided results, bounds, laziness, ownership and effects stay as specified. No runtime dependencies may
be added without owner approval. New contract gaps block affected kits and
return for review, not silent implementation decisions.

## Provenance, parity and non-goals

Source: Go `github.com/version2beta/pll`, revision
`971282632129110794c9d6edd22026e9de2359be` (short `9712826`), examined in
`/Users/rob/Development/pll`. Basis: full `SPEC.md` and `README.md`, public
`rate.go`, `pacer.go`, `span.go`, `follower.go`, errors/status/package comments,
and rate/pacer/follower examples, boundary and differential-model tests.
The original is provenance, not a runtime dependency. This
standalone root README is the port's user-facing readme-loop authority;
supporting kit specs may clarify but cannot override it. Source/doc conflicts
and later upstream changes require explicit review, not automatic adoption.

Functional equivalence means exact pacer results and equivalent follower
equations, state transitions, error categories and atomic failures on the shared
domain. It does not require Go ABI, duration formatting, writable span fields,
iterator protocol, zero-value controller structs, sentinel-error matching,
internal layouts, Go-specific fast paths, or mutating Go-style receivers.
There is **no transplanted claim** about Go benchmark times, zero allocations,
race-detector or simulator results, or real-time scheduler performance.

This is a library, not a sleeping rate limiter, token bucket, scheduler,
PTP/NTP/system-clock servo, counter-unwrapper, device driver, payload queue or
transport. The Go `cmd/pllpace`, `cmd/pllsim`, UDP tests, full simulator and
benchmark tools are excluded from initial port scope. Small deterministic
synthetic-clock tests are in scope; a shipped simulator/CLI is deferred.
No GenServer, Agent, Task, supervision tree or application-start callback is
needed to use the core. Caller-owned OTP integration is an adapter concern.

## Prerequisites and future installation

Recommended baseline: Elixir >=1.15 and Erlang/OTP >=26, binary64 floating
arithmetic and arbitrary-precision integers. The broader supported runtime
matrix still needs testing; Stage 1 is checked on Elixir 1.20.4 / OTP 29 only.
No third-party runtime or test dependency,
credentials, environment configuration or project/user configuration files.
All settings are explicit function arguments; there is no precedence system.

After implementation, a **proposed local consumer dependency** is:

```elixir
# Proposed consumer mix.exs entry for this Stage 1 checkout:
{:pll, path: "../pll-elixir"}
```

From the future consumer project, `mix deps.compile pll` would compile that
local dependency; from this library root, `mix compile` builds the Stage 1 exact
pacing modules. Stage 2 config, mapping and inlier-loop seams are implemented; supplied Stage 3 history stubs still fail on unfinished windows/outliers/steps. No installs or fetches are
authorized. No Hex version/install command is promised; publication availability
has not been checked. Compiling can write build
artifacts, but the library runtime has no file effects.

## First useful example (promised; Stage 1 README example tests)

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

## Public API (approved, exhaustive finished-library surface)

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
also use signed 64-bit (the approved 64-bit Go baseline, not platform-dependent
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
future approved runtime boundary, must be rejected with the field's config
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

### More hand-checkable pacing examples (promised)

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
is validation order. Reasons are exact strings; approved port field spellings
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
and accuracy are not promises about this unimplemented port.

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

### Cross-module success and failure (promised)

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

## Deterministic verification contract

Use ExUnit and builtin arithmetic; no added testing dependency. Stage 1
source-named suites cover Rate, Pacer, Span, an independent rational oracle and
pacing README examples. Stage 2 adds config/mapping/inlier-loop checks; Stage 3 adds shared public-Go fixtures and complete windows/outliers checks. Commands from this project root (Stage 1 suites pass on
this checkout):

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test --seed 0
```

A future project must specify formatter inputs so format checks cannot pass
vacuously. Compile/test write `_build`; they are not evidence of runtime file
writes. README code fences are script-style pattern matches, not IEx doctests;
example tests must explicitly execute them (or equivalent mechanically checked
extractions). Merely enabling `doctest` will not execute these fences. Test
acceptance requires observed nonzero expected tests, not just exit status.

Acceptance must cover:

1. Every API/default/error, validation precedence, tagged result/exception
   shapes, zero/empty values, index bounds, early-stopped lazy enumeration,
   input envelopes and failure preservation. Verify old snapshots remain
   unchanged and chain callers do not accidentally reuse stale state.
2. A deliberately simple independent pacer rational oracle using integer
   numerator/denominator pairs from the formula, no production timing helpers.
   Hand-derived floor/ceiling neighbors and retained spans cross-check it.
   Seeded bounded random operations include earlier now/backlog, repeated and
   extreme trims, huge terms, cursor U, floor-fit/ceil-overflow at Imax and
   full operation/error/state comparisons. Do not enumerate huge spans.
3. A literal follower equation oracle at moderate inputs; independent integer/
   high-precision rational calculations for extreme gain and mapping cases,
   not a shared float helper or rounded absolute-time model at huge times.
   Cover order including pending/rejected, dt=0, candidate ties, threshold
   equality, windows/holdover across signed bounds, first-run outlier reference,
   reset, two-inlier jitter, trim/error saturation, extreme finite gains and
   overflowing feed rollback followed by a valid continuation.
4. Anchors beyond 2^53, positive/negative half ties, wide displacements cancelling
   back into range, long synthetic runs, offset/drift, jitter, jumps and outage
   recovery. Tests never sleep or use live clocks/devices.
5. For the later follower/parity kit (not required for exact Stage 1), a
   review-approved corpus from the pinned Go public API, generated offline
   in a separately authorized temporary harness, without modifying the Go repo.
   Encode integers as decimal strings, floats as binary64 encodings; record
   operations, results/error codes and source revision. Replay both ports
   against this and independent oracles. Since OTP 26 has no built-in JSON
   requirement here, the approved line-oriented decimal-integer/hex-binary64 encoding is documented
   in docs/corpus.md. Two ports
   agreeing is not independent proof; investigate discrepancies with source
   equations and hand-worked cases.

Approved numerical acceptance (Stage 3 reference evidence is not implementation acceptance): exact
pacer integers, classifications/statuses,
states, saturation and designated hand-derived boundary mappings. Moderate
follower-model fixtures mirroring source differential tests allow <=1 ns error
and mapping differences, absolute offset difference <=1e-12; jitter fixtures
allow <=2 ns. Each fixture identifies applicable tolerance and boundary rounding.
No tolerance can mask changed status/threshold classification or relax exact
boundary cases. Extreme-gain fixtures require high-precision capped-gain
expectations with explicitly reviewed tolerances. Universal bitwise float
identity and accurate arbitrary-distance extrapolation are not promised. These
are approved limits, not results measured on a completed port.

## Readme-loop stages and current limitations

Prepare **one bounded kit at a time**: protect the
approved README, use subordinate supporting spec/promise-to-test mapping,
non-vacuously failing stubs, private passing reference, runner-judge and full
stage checks. Return for review between kits. Stage 1 is implemented on this
branch; Stage 2 config, mapping and inlier loop are implemented under the completed bounded run, with window/outlier behavior still temporary.

1. **Exact pacing:** Rate/Pacer/Span, error/input envelopes, immutable chaining,
   all pacing examples, independent rational oracle and extreme boundaries.
   This is useful alone; follower not yet claimed implemented.
2. **Mapping and loop:** config, anchoring/order, rounding/mapping, gain/rate
   update, accepted samples, lock/jitter/holdover/reset, transactional overflow;
   first follower-to-pacer trim example. Window/outlier behavior is visibly
   incomplete until next stage; do not advertise a partial follower as complete.
3. **Complete follower parity:** windows/outliers/steps, edge/retry cases,
   deterministic synthetic integration scenarios, shared differential fixtures,
   all README examples and whole-tree regression. Review runtime/build/release
   choices before publishing. OTP adapters, CLI/simulator products and benchmarks
   remain separate decisions.

**Evidence scope:** documentation is grounded in pinned Go source/tests. Stage 1
supplies a Mix project, protected public seams, the Stage 1 exact-pacing
implementation, acceptance tests and a subordinate [SPEC.md](SPEC.md). Private-reference
checks during kit preparation established feasibility only. The Stage 1 code was
written by the runner's coder and judged by the unchanged runner and Mix commands;
that is not owner, live-model or integration acceptance. There is no completed port,
installed/published package, complete follower verification, Go differential corpus,
performance result, live-model trial or real-device validation. Source Go
results are not port evidence. That was the historical Stage 2 gate; Stage 3 preparation is now separately approved.

**Kit-preparation evidence (historical, before the run; Elixir 1.20.4 / OTP 29):**
unchanged runner `--check` passed all four tasks on the private reference: 9, 21,
8 and 38 tests respectively, with zero failures/skips/exclusions. Both pacing
example fences executed against the reference. On the supplied stubs all four
runner tasks failed; the whole suite had 37 failures out of 38 tests. Task
independence was also checked with reference Rate plus Pacer/Span stubs, and an
otherwise working reference with set_trim stubbed. Inherited disposable runner
regressions: all 26 cases pass and all 26 deliberately regressed copies are
caught, with no model calls. These are fixture/reference results only.

**Owner-checkout Stage 1 implementation evidence (historical run):** the runner's coder made three
first-attempt commits with `claude-haiku-5-5`: T1 `792e3f8`, T2 `7b4603e`, T3
`d999aac`. No `gpt-6.1-sol` escalation or `STOP` occurred. T4, the whole stage,
passed the runner's judge without a coder attempt. At implementation commit
`d999aac`: `mix format --check-formatted` passed; `MIX_ENV=test mix compile
--warnings-as-errors` passed; `mix test --seed 0` reported 38 passed; and
`bash scripts/loop.sh --check` passed T1–T4. This verifies only the Stage 1 suite
and judge commands on this machine and toolchain. It is not owner acceptance,
live-model, integration or real-use validation. Total model spend is unknown.

**Owner-checkout Stage 2 implementation evidence (historical run, Stage 2-limited):** the
authorized runner's coder made three first-attempt commits with `claude-haiku-5-5`:
S2-config `cd8b3ea`, S2-mapping `b1e9249` and S2-loop `ec3aa37`, each with a
`Coder-Command:` trailer for the Haiku command. The S2-tree whole-tree task then passed
the judge without a coder attempt. Across the run the runner changed only
`lib/pll/follower_core.ex` and `PROGRESS.md`; no README, SPEC, test, support, config,
task or runner path changed. Final checks: `mix format --check-formatted` passed;
`MIX_ENV=test mix compile --warnings-as-errors` passed; `mix test --seed 0` reported 55
passed (follower_config 4, follower_mapping 4, follower_loop 9); `bash scripts/loop.sh
--check` passed T1, T2, T3, S2-config, S2-mapping, S2-loop and S2-tree. This is local
evidence for the Stage 2 config, mapping and inlier loop only. Windows, outliers, steps,
the Go parity corpus and the complete follower are not implemented; the temporary
`:unsupported` boundary remains. This is not owner acceptance, live-model, integration
or real-use validation. Three coder calls were made; total model spend is unknown.

## Historical Stage 1 kit operation (completed; not current launch instructions)

The kit is prepared directly in this checkout on `kit/stage1-exact-pacing`;
there is no archive to apply and no earlier implementation stage to overlay.
Do not copy the private reference into a coder checkout. The kit commit contained
stubs intentionally, not the reference. Existing README work and transient
`.wtha/` metadata are preserved; `.wtha/`, `_build/`, `.loop/` are excluded from
Git. No source files may be hidden to satisfy the runner's clean-start gate.
The kit commit `69ea26e` contained stubs intentionally; the current Stage 1
implementation is in the runner's commits after `c4f8a7e`.

Prerequisites: Bash, Git, jq, a working `timeout` or `gtimeout`, Elixir/Mix/OTP,
and installed `pi` for the authorized paid run. Local preparation checked Bash 3.2,
Git 2.54, jq 1.7, timeout smoke behavior, Elixir 1.20.4 / OTP 29 and pi 1.5.2.
No dependency install/fetch is needed. Tests use no live clocks, network or
credentials. Commands below write ignored development artifacts, not runtime I/O.

Review checks from this checkout:

```sh
git branch --show-current
git status --short
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
mix test --seed 0
bash scripts/loop.sh --check
```

`--check` launches no coder or formatter. On this checkout all four tasks pass
(exit 0), including whole-stage tests. The kit-preparation stubs failed all four
tasks (exit 1) before the run. Task stdout uses the exact installed ExUnit summary
format; a different runtime requires kit re-verification, not loose pass markers.
There are no prior-stage checks. See SPEC for promise-to-test mapping.

**Stage 1 implementation run (completed once; not authorized again).** Independent
source review found no code or test blockers. The owner authorized this bounded run
with a $25 total budget and confirmed a provider-side cap is configured. The run used
exactly this command from the kit checkout:

```sh
MAX_ITER=12 MAX_ATTEMPTS=3 ITER_SECONDS=1200 JUDGE_TIMEOUT=300 \
CHEAP_CMD='pi --provider anthropic --model claude-haiku-5-5 --thinking high --print --no-session' \
STRONG_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking high --print --no-session' \
STRONGEST_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking max --print --no-session' \
bash scripts/loop.sh
```

These are authorized identities and skill defaults, not a claim of live model
availability. No substitutions or provider renaming are allowed. The unchanged
runner commits passing attempts on the current non-main branch and discards
only failed attempt-owned changes established by its clean-start gate. Logs,
prompts and discarded diffs/notes live under `.loop/`; root `STOP` identifies a
task exhausting retries. PROGRESS.md is writable; approved READMEs, supporting
contracts, complete seams, tests and kit files are protected. Newly discovered
contract gaps require review; progress notes do not automatically halt retries.

Launch limits are MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200 and
JUDGE_TIMEOUT=300 (runner defaults 60, 4, 1200 and 300; positive-integer owner
overrides only). With three attempts a normal task uses Haiku-5.5, then
gpt-6.1-sol high, then gpt-6.1-sol max. These bound attempts and time, **not
spending**. The total authorized budget is $25, including model preparation work;
no reliable remaining amount has been independently verified. The owner reports a
provider-side spending cap configured; this is not independently verified. Pi's
local usage estimates are not a verified aggregate/provider billing ledger. Exact
`--print --no-session` commands do not persist session usage, and the runner does
not aggregate costs or enforce a dollar cap. No model/coder subprocess is invoked
by kit preparation or `--check`. The completed run made three coder calls, all
`claude-haiku-5-5` first attempts. Its total spend is unknown from this checkout and
must be checked against the provider's usage record.

## Historical Stage 2 kit operation (completed, not current launch instructions)

Prepared directly on `kit/stage2-mapping-loop`, overlaying the actual Stage 1
implementation at `049e0ca5a6128954870a59ebcbf25db29a6b294a`; no archive to apply.
Do not copy private references into this checkout. The kit contains intentionally
failing follower stubs. Existing `.loop/` logs/attempt metadata are preserved.
Stage 2 task IDs are S2-prefixed; T1–T3 preserve prior checks and the old T4
whole-stage task is replaced by the final S2 whole-tree task. All Stage 1 sources,
all tests, READMEs, config, seams and harness files are protected.

Prerequisites remain Bash/Git/jq/timeout (or gtimeout), installed Elixir/Mix/OTP
and pi; no installs/fetches. Verification uses Elixir 1.20.4 / OTP 29 only.
Launch-time prerequisite check (before the run): pi 1.6.0, jq 1.7.1,
`/usr/bin/timeout`, Bash 3.2, Git 2.54, Mix 1.20.4 / OTP 29; the runner copy matches
the skill source byte-for-byte.
Review commands from the checkout (no model calls):

```sh
git branch --show-current
git status --short
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
mix test test/pll/rate_test.exs test/pll/pacer_test.exs test/pll/span_test.exs test/pll/readme_test.exs test/pll/trim_test.exs test/pll/model_test.exs --seed 0
bash scripts/loop.sh --check
```

Kit-preparation evidence (historical, before the run): prior Stage 1 checks pass on
delivered stubs (38 tests); new tasks and whole-tree check intentionally fail. The private reference overlay onto actual Stage 1
passes 55 tests and unchanged runner T1–T3/S2-config/S2-mapping/S2-loop/S2-tree.
Delivered stubs have 39/55 passing tests (16 expected failures); each new task
fails. Config/mapping/loop reference task counts are 4/4/9. All three alias-based
public README example fences execute on the reference. Review-strengthened checks
also cover exact 1.25 ns unrounded outlier/lock classification, true wide integer
difference cancellation, reset config retention, both input envelopes, wrong
kinds, remote overflow, both trim clamps and the Imax binary64 lock threshold.
Independent rounded-outlier and rounded-lock mutations each fail the strengthened
loop suite (8/9 passing), while the unmodified reference passes all 55 tests.
These additions extend existing test cases; task counts remain 4/4/9 and 55.
Runner bytes match the
skill source; its 26 disposable regression cases and 26 mutation checks pass.
These are local feasibility results, not coder implementation, complete follower,
Go parity, real-device use or a wider runtime matrix. No coder/model was launched.

**Stage 2 run completed once (exit 0); not authorized again.** The authorized command
was run from the clean committed non-main kit checkout; its output and exit code were
recorded in ignored `.loop/stage2.run.out` and `.loop/stage2.exit`:

```sh
MAX_ITER=12 MAX_ATTEMPTS=3 ITER_SECONDS=1200 JUDGE_TIMEOUT=300 \
CHEAP_CMD='pi --provider anthropic --model claude-haiku-5-5 --thinking high --print --no-session' \
STRONG_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking high --print --no-session' \
STRONGEST_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking max --print --no-session' \
bash scripts/loop.sh
```

The runner commits passing attempts and discards only attempt-owned failed work;
logs, prompts, diffs and attempt state remain in `.loop/`, root `STOP` names an
exhausted task. Never delete earlier metadata to reset attempts. Progress notes
are writable but do not automatically halt retries for contract gaps. Commands
bound time/attempts, not dollars. Original total $25 budget is not expanded;
provider-side caps are owner-confirmed, not verified, and total spend is unknown.
No model subprocess is used for preparation, `--check`, or mechanics testing.
Local freedoms: private arithmetic/helper organization within fixed data/public
seams; no Stage 1 refactoring or dependencies. Deferred until Stage 3: window,
outlier, step histories and shared Go fixture encoding/corpus; wider runtime,
release/publication and adapters need later review. New contract gaps block work.

## Stage 3 kit operation (parent review passed; single authorized run)

Prepared directly on `kit/stage3-follower-parity`, over actual Stage 2 commit
`e3352c209a2ba75359018f579643d7debc265382`; no archive to apply. The kit includes
intentional unfinished FollowerHistory paths, not the external private reference.
No implementation loop has run. Prior .loop logs/attempts are preserved; S3 IDs
avoid earlier attempt collisions. Historical S2-loop checks move into S3-history;
S2-tree is replaced by the final S3-tree. Protected scope now includes complete
FollowerCore, all previous stable modules, structs, tests, fixtures, parser,
generator and READMEs. Only FollowerHistory/new private helpers are coder work.

Prerequisites unchanged: installed Bash/Git/jq/timeout or gtimeout, Mix/Elixir/OTP;
installed pi only for a later approved paid loop. No installs or dependency fetches.
Verified runtime remains Elixir 1.20.4 / OTP29 only. Offline corpus generation is
separately authorized and documented in [docs/corpus.md](docs/corpus.md); acceptance
tests use the checked-in corpus and do not require Go or sibling source access.

Review commands (no model calls):

```sh
git branch --show-current
git status --short
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
mix test test/pll/rate_test.exs test/pll/pacer_test.exs test/pll/span_test.exs test/pll/readme_test.exs test/pll/trim_test.exs test/pll/model_test.exs test/pll/follower_config_test.exs test/pll/follower_mapping_test.exs --seed 0
mix test --seed 0
bash scripts/loop.sh --check
```

On delivered unfinished paths, 46 prior checks pass; S3-history and S3-tree must
fail. On the external reference all tasks and 66 tests pass. Exact evidence,
limitations and intentional supersession: [verification](docs/stage3-verification.md).
No private reference may be copied into the coder checkout or read by the coder.

**Authorized single run.** Exact command, without model substitution or increased
budget:

```sh
MAX_ITER=12 MAX_ATTEMPTS=3 ITER_SECONDS=1200 JUDGE_TIMEOUT=300 \
CHEAP_CMD='pi --provider anthropic --model claude-haiku-5-5 --thinking high --print --no-session' \
STRONG_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking high --print --no-session' \
STRONGEST_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking max --print --no-session' \
bash scripts/loop.sh
```

Unchanged runner commits passing attempts on this non-main branch; discards ONLY
attempt-owned failures. Logs/prompts/diffs/notes remain under .loop/; root STOP
names an exhausted task. Never reset historical attempt state. PROGRESS.md is
writable; contract gaps require operator stop/review, not speculative code or
unattended retries. Normal first attempts Haiku5.5, retry high/max GPT6.1-sol.
Original total $25 unchanged; caps owner-confirmed, not independently verified;
spend/remaining unknown. Attempt/time limits do not enforce dollars. No preparation
model calls, remotes, installs, publication or later kits. Runtime matrix/release
and adapters remain deferred until separately reviewed.
