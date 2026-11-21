# pll-elixir — exact pacing and clock following

> **Stage 3 implementation completed by the single authorized runner run (exit 0); author review gate.** Completed observe never emits `:unsupported`. Evidence is finite fixtures only: not universal parity, live integration, security or performance.
> Stage 1, Stage 2 and Stage 3 are implemented; the full normative follower contract below is unchanged.
> Stage 2 run limitations/approvals below are historical, not current launch authority.
> Benchmark: the single owner-authorized coding loop completed (exit 0) and the local harness is implemented; author review gate, no further loop authorized (see Throughput benchmark).

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
| Approved | Bounded dependency-free public-API throughput harness kit and verified kit commit; tool-only clock/introspection/output effects as described below. Parent review before coding loop; no expanded budget, library changes or dependencies. |
| Approved | Parent launch review of the benchmark kit (HEAD `4867fc4d82168e230c37ea2022ca28a2b6eb0da1`, branch `kit/throughput-benchmark`) passed, including the independent-review strengthening in [benchmark verification](docs/benchmark-verification.md). One coding loop is authorized with the exact command in the Benchmark kit operation section: claude-haiku-5-5 for normal attempts, gpt-6.1-sol high for the second attempt and gpt-6.1-sol max for the final attempt, using MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200 and JUDGE_TIMEOUT=300. Runner commit and discard permissions apply only to passing attempts and attempt-owned failures. Only `scripts/bench/runner.exs` is writable implementation. The original $25 total is not expanded; provider caps are owner-confirmed, not independently verified, and spend is unknown. No library change, dependency, installation, remote, publication or additional loop is authorized. |
| Approved | Benchmark loop completed once with exit 0: BENCH-1 passed on the first claude-haiku-5-5 attempt (`e477f81`); BENCH-tree passed the judge with no coder attempt. No gpt-6.1-sol escalation, discard or STOP occurred. The loop changed only `scripts/bench/runner.exs` and `PROGRESS.md`. Local timed evidence is one short machine run, not a speed claim; spend is unknown. The loop is not authorized again. |
| Approved | Local real-time pacer demonstration and bounded local trials under the [contract](#local-real-time-pacing-demonstration--approved-scope-a). Kit preparation/verified kit commit authorized; stop for parent review before coder launch. |
| Approved | Scope A: bounded pacer demonstration parity, not full `pllpace` flag parity. Ticker/find-max/remote destinations/arbitrary payloads excluded; receipt/loss guarantees excluded. The three configurations, three repetitions per language and thresholds below are approved local trials, reserved until actual implementation. |
| Deferred | Aggregate spend accounting, remaining-budget tracking and runner-side dollar enforcement. Not established; any later paid run needs a new decision on these. |
| Deferred | Hex publication, broader runtime matrix, release automation, OTP adapters, CLI, simulator product and broader benchmarks; decide before the affected stage. No task may assume them. |

**Current gate: parent review of the verified local pacing kit; no coder launch authorized yet.**
The completed throughput benchmark remains at its author review gate (single loop run).
See [benchmark verification](docs/benchmark-verification.md) and the Throughput benchmark section;
[Stage 3 verification](docs/stage3-verification.md) remains the historical Stage 3 record. The original total $25 constraint is unchanged; provider caps
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

## Stage 3 kit operation (run completed once; not authorized again)

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

**Stage 3 run completed once (exit 0); not authorized again.** The authorized command was
run from the clean committed non-main kit checkout, with output in ignored `.loop/stage3.run.out`
and exit code in `.loop/stage3.exit`:

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

## Throughput benchmark (approved bounded tool; implemented by the single authorized loop)

This dependency-free developer harness measures this Elixir implementation, not
Go speed or real-time scheduling. It is separate from the pure runtime library.
The approved outcome is a local harness only: no library API/algorithm changes,
installs, dependencies, network, secrets, global VM tuning or concurrency product.
CLI spelling, bounded defaults and report definitions below are local design
choices within that approval. Wider benchmarking/publication remains deferred.

Public commands (implemented in BENCH-1; local evidence is limited to the runs described below):

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
All library input clocks are deterministic integer counters. No library source,
API, algorithm, private fields or external implementation may be used/changed.

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
Stage 3 baseline `03a99baca1db2872f6e6f9298914aab9e2242a2a`. This identifies
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

### Benchmark kit operation — loop completed once; not authorized again

Prepared directly on `kit/throughput-benchmark` over actual clean Stage 3 HEAD
`03a99baca1db2872f6e6f9298914aab9e2242a2a`; no archive to apply. Existing `.loop/`
state remains intact. BENCH-1 is the single normal implementation task; BENCH-tree
replaces S3-tree and stays last. Only `scripts/bench/runner.exs` is writable
implementation, plus progress notes. All library sources, tests, fixtures,
READMEs, supporting contracts, config and complete parser/entrypoint are protected.
No private reference is included or available to the coder.

Prerequisites unchanged: installed Bash/Git/jq/timeout (or gtimeout), Elixir/Mix/OTP;
pi only for the single authorized loop below. No installs/fetches. Check locally:

```sh
git status --short
mix format --check-formatted
mix format --check-formatted scripts/bench/*.exs scripts/throughput.exs
MIX_ENV=test mix compile --warnings-as-errors
mix test test/pll --seed 0  # all 66 prior tests, including Stage 3 corpus
mix test --seed 0         # stubs intentionally fail new tests
bash scripts/loop.sh --check
```

`--check` makes no model calls. Verified evidence and protection inventory:
[benchmark kit verification](docs/benchmark-verification.md). The following single
implementation loop was run once (exit 0) and is not authorized again:

```sh
MAX_ITER=12 MAX_ATTEMPTS=3 ITER_SECONDS=1200 JUDGE_TIMEOUT=300 \
CHEAP_CMD='pi --provider anthropic --model claude-haiku-5-5 --thinking high --print --no-session' \
STRONG_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking high --print --no-session' \
STRONGEST_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking max --print --no-session' \
bash scripts/loop.sh
```

**Loop result (completed once, exit 0; output in ignored `.loop/bench.run.out`, exit code in
`.loop/bench.exit`):** BENCH-1 passed on attempt 1 with `claude-haiku-5-5` and commit `e477f81`
(`Coder-Command:` trailer present). BENCH-tree then passed the judge without a coder attempt, and
`every task passes` ended the run. The loop changed only `scripts/bench/runner.exs` and
`PROGRESS.md`; library, tests, fixtures, READMEs, SPEC and configuration were protected and unchanged.
Acceptance at the final docs commit: format (including scripts), warnings-as-errors compile, 72 tests,
unchanged `--check` (8/8) and the public smoke (18 rows). Model spend is unknown; provider caps
are owner-confirmed and not independently verified.

**Public run commands (no model calls):**

```sh
mix run scripts/throughput.exs --smoke
MIX_ENV=prod mix run scripts/throughput.exs
mix run scripts/throughput.exs --iterations 1000 --samples 3 --warmup 100
```

**Local timed evidence limits:** the default run completed in about one second on one machine
(Elixir 1.20.4, OTP 29, aarch64 macOS, 10 schedulers) with 27 rows. Those numbers are not
versioned, not a speed claim, not a Go comparison, not an allocation or real-time measurement and
not a statistical confidence interval. Process memory deltas are self-process net changes and may be
negative. VM GC counts and reclaimed words are VM-wide counters that include unrelated work; reclaimed
words are not allocation volume. The timer also includes the in-execute initial cursor read and loop
accounting.

Runner commits passing attempts on the nonmain branch and discards only
attempt-owned failures; prompts/logs/diffs/notes under `.loop/`, exhausted task
in root `STOP`. Never reset historical attempts. Haiku normal, GPT high/max
escalation; no substitutions, extra calls or fanout. Original aggregate $25
budget is not expanded; provider caps owner-confirmed, not independently verified;
spend/remaining unknown. Attempt/time limits do not enforce dollars. Contract gaps
block the run for review; progress notes do not stop retries automatically.

## Local real-time pacing demonstration — approved scope A

**Approved contract; kit contains an unfinished runner, not a completed tool.** A developer runs a bounded
local demonstration of the actual Elixir pacer driving discard or local UDP,
then compares the same workload with Go on the same machine. This is different
from the existing throughput microbenchmark. It does not change the library,
its no-I/O contract, the corpus, tests, runner or historical logs. The initial
port's CLI exclusion is narrowed only for this isolated tool. Scope A, its exact
effects/bounds and local comparative trials below are approved. Kit preparation
and verified kit commit only at this checkpoint; parent review before coding.
No paid call or live UDP trial is performed during preparation. Original aggregate $25 budget unchanged; spend/remaining unknown,
provider caps owner-confirmed, not independently verified.

### Source basis and parity boundary

Inspected sibling Go HEAD `971282632129110794c9d6edd22026e9de2359be`, clean,
read-only. These are source facts, not evidence of past or current performance:

* `../pll/cmd/pllpace/main.go:32–40,55–83`: defaults are 100,000,000 bps,
  1000-byte units, 10 seconds, pacer, discard, one unit/datagram; search off,
  slack 5 ms. Validation precedes payload/socket creation. Duration accepts
  finite fractional seconds truncated to ns, at least 1 ns and below signed
  duration overflow; rate is positive uint64, unit bits/int and grouping must
  fit; UDP payload <=65507. There is no small resource/wall-time cap for normal
  trials; only search rates are capped at 10^12 bps.
* `main.go:173–231`: fresh rate/pacer, zero-filled unit, monotonic elapsed origin;
  `Due(now,4096)` drains oldest slots, never skips. Each successful call counts
  as a wake-up (including empty spans); lateness records `now-Time(0)` once per
  nonempty span, **before** output. Offer increments before sink submission;
  max batch is slots from one call, not units in a datagram. Sleep until the
  earlier of next due and trial deadline, if positive; stop before a new call
  at/after deadline, but finish an already issued batch.
* `main.go:102–170,185–194,312–325`: group UDP units and flush final partial
  datagram on success; discard uses group 1 regardless of `-per-datagram`.
  Count actual writer-accepted bytes, including partial bytes on error; clear
  failed buffers, propagate errors/short writes, never carry them to another
  trial. Final flush is inside elapsed time. Backlog is
  `max(0, final_elapsed - next_due_ns)` after flushing. Mbps is accepted payload
  bytes * 8 / elapsed seconds / 10^6, **excluding UDP/IP/link headers**.
* `main.go:150–170,348–355`: sorted lateness uses index `floor(f*(n-1))`
  (empty quantile 0), not interpolated percentiles or per-packet jitter. Search
  passes only nonempty trials with backlog and p99 <= slack. Ordinary runs
  print metrics, not a timing pass/fail, and timing failure does not set an
  error exit code. Progress printing about once/second costs measured time.
* `main.go:234–276`: ticker floors exact ns period, starts after one period,
  offers one unit per delivered tick (ticks can drop), max batch 1, no lateness
  samples. Backlog uses ideal `(offered+1)/units_per_second`, not next pacer due.
* `main.go:359–419`: find-max is pacer-only: double starting bps until failure
  or rate limit, then bisect to ratio <=1.05 or adjacent integers. Repeated
  trials multiply cost; neither highest passing rate nor UDP success proves
  lossless delivery. `main.go:284–300` requests an 8 MiB read buffer without
  checking success, then reads/discards loopback datagrams: **no receipt count**.
  Receiver lifetime is process lifetime, not an explicitly closed trial socket.
* `../pll/README.md:260–266` describes real pacing/search and loopback, separate
  from `make bench`; there is no recorded ATSC result there.

Go test inventory, fully read, not rerun here (`../pll/cmd/pllpace/main_test.go`):
writer failure/short write (43), per-trial flush (64), invalid/valid options (82),
exact ticker periods (137), grouping/partial writes (153), both runners' accounting
and final errors (182), low-rate deadline (220), delayed final flush in elapsed
and backlog (241), bytes with error (255), bisection progress/adjacency (264),
nonempty/boundary sustained criterion (308). These use fake writers and some live
timers; none establishes receiver loss/jitter or a sustained real UDP bitrate.

**Scope decision:**

* **A (approved):** pacer-mode demonstration parity: discard, loopback,
  grouping 1/7, equivalent metrics and same-machine Go comparison. Bounded
  defaults differ deliberately from Go. Reject `--mode ticker`, `--find-max`
  and remote `host:port`; label this *pacer demonstration parity*, never full
  command parity.
* **B (excluded; separate design required):** add timer-per-unit comparator and bounded
  find-max. BEAM millisecond timers cannot promise Go's microsecond ticker;
  dropped-tick semantics, trial/rate/aggregate-wall caps and fair comparisons
  must be approved before a kit. Full external-target flag parity is not offered
  by either choice. Remote UDP and arbitrary payloads require specific approval.

### Approved finished-tool command and effects (scope A)

Examples are promises for a future tool, **not executable instructions now**:

```sh
mix run scripts/pacing.exs
mix run scripts/pacing.exs --bps 19392658 --unit-bytes 188 --seconds 5
mix run scripts/pacing.exs --bps 19392658 --unit-bytes 188 --seconds 5 --udp loopback --per-datagram 1
mix run scripts/pacing.exs --bps 19392658 --unit-bytes 188 --seconds 5 --udp loopback --per-datagram 7
# Future same-machine Go counterparts (sibling remains read-only; caches outside it):
(cd ../pll && GOPROXY=off GOTOOLCHAIN=local go run ./cmd/pllpace -bps 19392658 -unit-bytes 188 -seconds 5)
(cd ../pll && GOPROXY=off GOTOOLCHAIN=local go run ./cmd/pllpace -bps 19392658 -unit-bytes 188 -seconds 5 -udp loopback -per-datagram 1)
(cd ../pll && GOPROXY=off GOTOOLCHAIN=local go run ./cmd/pllpace -bps 19392658 -unit-bytes 188 -seconds 5 -udp loopback -per-datagram 7)
```

Approved defaults: 19,392,658 bps, 188 bytes, 5 seconds, discard, grouping 1,
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
VM-global tuning, secrets, persistent results or external actions. Go commands are
manual comparison, not something the Elixir tool launches. Report revision/dirty
state separately using operator Git commands, plus runtime/platform/schedulers
and all effective options with each comparison. No environment dump.

### Approved structure, timing and failures

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
(excluding Mix startup), and cancels/kills owned processes if they do not stop.
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
Slot zero is due immediately: short runs can appear fast by up to about one unit;
no start-slot subtraction or forced unit-count equality across runtimes. Backlog
is cursor lag, not queue depth. Lateness is oldest scheduled unit at call entry,
not each unit's send time, network/receiver jitter or a bound on every unit.

### Approved verification and comparative acceptance

Before a kit: independently verify fake-clock tests for immutable chaining,
slot zero, empty/4096-capped batches, coarse wakeups/backlog without skips,
low-rate deadline (never wait for a distant slot), final partial flush time/count,
quantile boundaries, errors/partial writes, cancellation/guard/cleanup and all
bounds rejected before effects. Future source-named tests live under
`test/pacing/`; existing deterministic suites stay unchanged and must still pass.
No network/timers in deterministic acceptance; separately authorized local trials
are essential, not replaced by microbenchmarks or fake writers.

Approved future local trials (after actual implementation): 3 configurations (discard, UDP group 1, UDP group 7),
3 sequential repetitions per language, 5 seconds each, fixed 19,392,658 bps and
188-byte units. Alternate language order, same machine/load, record versions,
revisions/dirty state and individual raw summaries, not invented averages.
18 trials = 90 requested seconds, each externally limited to 12 seconds including
startup, aggregate session <=300 seconds including preparation; stop on errors,
no retries/search/rate escalation. Offline build caches only, no fetches.

Approved criterion per completed pacer trial: nonempty, accepted bytes equal
188*offered, no errors/cap/cancel/guard, final backlog <=5 ms and oldest-unit
p99 <=5 ms (Go's search timing criterion applied explicitly), plus writer bitrate
within 1% of target for this 5-second demonstration. The bitrate bound is an
additional approved demonstration check, **not a Go normal-run pass rule**.
Record all repetitions and both languages' results, including failures; failure
requires review, not auto-tuning/relaxing thresholds or claiming parity complete.
No universal speed ratio or guaranteed success on arbitrary hardware promised.

This validates local offered/accepted rate and schedule catch-up under those
conditions. It does **not** validate receipt, loss, receiver drain stability,
network jitter, hardware buffers, wire bitrate, valid TS content, remote delivery
or full flag parity. No receiver counters or new transport product are proposed.

**Feasibility evidence now (no network):** Elixir 1.20.4/OTP 29, 100 sequential
`receive after 1` waits timed with monotonic ns: min 1,911,458 ns, median
1,999,125 ns, max 2,086,583 ns, total experiment 201,099,625 ns. This supports
coarse-wait/batch design, not 77.6 microsecond wakeups or demonstrated ATSC pacing.
At roughly 2 ms a batch is about 26 units; actual writer/lateness/backlog viability
remains unproven until implementation and authorized live local trials.

**Current gate:** scope A is approved. Review the verified kit before coder launch;
choice B remains excluded. The full live comparison is reserved for the actual
implementation, not a reference result. No coder launch follows automatically.


### Pacing kit operation — prepared, parent review before launch

Prepared on `kit/local-pacing-demo` over actual completed library/benchmark HEAD
`cd35fec92eb4632b1efc52468a024eb5bacec497`, preserving existing README/progress drafts.
No archive to apply. Only `scripts/pacing/runner.exs` and appended progress notes
are coder work; all library/benchmark files, tests, fixtures, configuration,
READMEs/docs, complete pacing contract/runtime/entrypoint and runner are protected.
PACING-runner is one normal task; PACING-tree replaces BENCH-tree and stays last.
Earlier 72 checks remain unchanged. Existing `.loop/` history is preserved; task
IDs are new. Evidence/protection inventory: [pacing verification](docs/pacing-verification.md).

No installs/fetches: installed Mix/Elixir/OTP, Bash, Git, jq and timeout/gtimeout;
pi only for a later authorized coder launch. Verified runtime Elixir 1.20.4/OTP29.
Check commands (stubs intentionally fail the new task and whole-tree task):

```sh
git status --short
mix format --check-formatted
mix format --check-formatted scripts/bench/*.exs scripts/throughput.exs scripts/pacing/*.exs scripts/pacing.exs
MIX_ENV=test mix compile --warnings-as-errors
mix test test/pll test/bench --seed 0
mix test --seed 0
bash scripts/loop.sh --check
```

The exact future launch command, **withheld pending parent review**, is:

```sh
MAX_ITER=12 MAX_ATTEMPTS=3 ITER_SECONDS=1200 JUDGE_TIMEOUT=300 \
CHEAP_CMD='pi --provider anthropic --model claude-haiku-5-5 --thinking high --print --no-session' \
STRONG_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking high --print --no-session' \
STRONGEST_CMD='pi --provider openai-codex --model gpt-6.1-sol --thinking max --print --no-session' \
bash scripts/loop.sh
```

The unchanged runner commits passing judged attempts on this non-main branch and
discards only attempt-owned failed changes under prior scoped permissions.
`.loop/` retains prompts/logs/attempts/diffs; root `STOP` names exhausted task.
Do not reset historical state. New contract gaps block work for operator review;
progress notes do not stop retries automatically. Private helper organization
inside runner.exs is local freedom, not new files/features/effects. No sibling
reads by coder, deps, tuning, remotes, publication or extra model calls. Original
$25 aggregate unchanged; caps owner-confirmed, unverified; spend/remaining unknown.
Attempt/time caps are not dollar enforcement. Return for review after this kit;
never chain another kit or automatically run the approved live trials.
