# Pacing kit verification — preparation only

Authority: root README Local real-time pacing demonstration, approved scope A,
and Pacing kit operation. Overlay baseline actual HEAD
cd35fec92eb4632b1efc52468a024eb5bacec497, branch kit/local-pacing-demo.
Existing README/progress design draft preserved and approval accurately recorded.
Preparation checkpoint had no coder launch, network trial, installation, dependency fetch, remote or publication.
Original $25 aggregate unchanged; provider caps owner-confirmed, unverified;
spend/remaining unknown. Parent launch review passed at 739c03e; see Launch gate below.
The preparation sections below are historical checkpoint evidence.

## Delivered files and seams

Only scripts/pacing/runner.exs is unfinished coder work (plus progress append).
Complete protected files: contract.exs validates all scalar/work/product bounds
before effects and computes reports/quantiles; runtime.exs supplies monotonic
clock, cancellable coarse waits, monitored worker guard, linked receiver ownership,
local UDP adapters and resource cleanup; scripts/pacing.exs handles parsing,
metadata/output and exit codes. Injected io seam precisely specified in SPEC.
No core library or previous benchmark change. No reference implementation shipped.

One new normal task PACING-runner, final PACING-tree replaces BENCH-tree. Prior
T1/T2/T3/S2-config/S2-mapping/S3-history/BENCH-1 remain. All prior 72 tests unchanged.
11 new source-named tests in test/pacing/runner_test.exs (83 whole-tree tests):
options/types/work/products before effects, quantiles/report independent arithmetic,
slot-zero/immutable chain/low-rate deadline and ceil-ms wait, coarse/4096 catchup,
grouping/final flush elapsed/backlog, error/partial bytes/final errors/no carry,
cancellation before call/between units/in wait, already-issued batch completion,
frozen-clock actual one-million-call cap, all approved ATSC command configurations
using fake clocks/writers and exact rational expected units, plus monitored
success/exception/abnormal exit/guard and linked-child cleanup.

Process tests use real isolated BEAM processes and monitor messages, no sockets,
no deliberate timer waits or wall-time success thresholds. Guard test uses timeout
zero with blocked worker; linked-child death observed. This is resource-owner
lifecycle evidence, not a test of the operating system UDP implementation.
Cancellation/release remains subject to VM/OS scheduling; no hard real-time claim.

## Checked evidence

Elixir1.20.4/OTP29, aarch64 macOS, 10 online schedulers. Separate temporary checkout
copied actual owner library/benchmark/test files; no substitute library. Judge runs
there avoid overwriting historical owner .loop logs. Full reference passes all83
and all nine unchanged-runner --check tasks, including whole-tree. Delivered stub
passes prior72; whole tree74/83 (9 expected failing tests), new suite2/11, and both
PACING-runner/PACING-tree fail the judge. Existing seven task checks pass stubs.
Checks use exact `Result: N passed` stdout expectations, not marker-only exits.

Public reference CLI low-rate discard check:
`mix run scripts/pacing.exs --bps 1 --seconds 1` completed one offered unit,
188 accepted bytes, one Due/writer call, elapsed1,001,468,250ns, backlog0;
stop deadline, timing sustained true, demonstration_pass false (slot-zero artifact,
not ATSC rate evidence). No network used. Three finished-tool ATSC option examples
run through parser and real public-API runner under deterministic fake clock/writer
in the 11-test suite; they are NOT live UDP/interface demonstrations.
Full actual ATSC comparison is unproven and intentionally not run here.

Four isolated mutations rejected by tests: stale next state (low-rate chain,
1 failing test), omit final partial flush (3), ignore UDP grouping (4), round
rather than floor quantile index (1). Restored reference then rechecked. These
checks support non-vacuous seams, not exhaustive proof of every implementation.

## Protection and runner

Runner bytes compare identical with readme-loop skill scripts/loop.sh. Skill
mechanics suite: all26 real-loop cases pass and all26 deliberate regressions
caught, in disposable repositories, no models. No runner edits.

Decoded grep ERE protection inventory checked against54 required paths, including
all library/test/doc/corpus/benchmark paths, every README, project/config/license,
formatter/gitignore, complete pacing contract/runtime/entrypoint. tasks.json,
SPEC.md, PROMPT.md and scripts/loop.sh additionally protected by unchanged runner.
Only pacing runner and progress are writable implementation paths; new files and
external implementation reads prohibited by PROMPT/SPEC. Protection constrains
accepted changes, not process access or a security sandbox.

Checks: explicit format inputs including both script trees; warnings-as-errors
Mix compile; prior72; full83; stub/reference unchanged-runner --check; public
low-rate discard CLI; decoded protection ERE inventory; runner cmp/mechanics;
git diff --check. No source, test or runner file from earlier stages changed.
No permanent output format beyond approved stdout maps and no live trial results.

## Prelaunch review follow-up — canonical integer boundary

Reviewer reported no P0/P1 blockers and identified a P2 trailing-newline parser
crash. Parent authorized the narrow protected-file fix. Pacing numeric regex now
uses absolute `\A...\z` anchors, enforcing the existing canonical decimal promise.
The existing parser test includes `["--bps", "5\n"]` and verifies tagged rejection
before Runtime dispatch; test counts remain11/83. Reverting only the anchors in
the external reference makes that regression fail with ArgumentError, proving it
catches the original crash. Restored patched file then checked again.

Patched current kit copied to a fresh temporary checkout over the actual library
and benchmark: external reference83/83 and all9 unchanged-runner judge tasks pass;
stubs retain prior72/72 and whole-tree74/83, with both new tasks failing as intended.
Explicit format checks, warnings-as-errors compile, decoded protection inventory
(54 required paths), runner byte comparison and git diff --check pass. tasks.json,
runner, runtime, entrypoint, unfinished implementation and earlier suites unchanged.
The CLI newline case itself exits2, stdout empty, stderr `pacing: invalid options`;
no runtime dispatch or sockets. No live UDP, pacing trial, coder or model call.
The original26/26 mechanics evidence above is historical; not rerun for this fix.

Documentation clarification only: cooperative cancellation is internal/test-only,
not operator-exposed; production coordinator uses guard kill. Ctrl-C does not
guarantee a report. `sustained` is timing-only; `demonstration_pass` also checks
accounting and bitrate, and CLI exit0 merely means deadline completion. Operators
must inspect/retain every trial verdict. Full approved18-trial comparison remains
reserved for actual implementation after launch review.

Separate out-of-scope note: the existing benchmark parser still uses the same
`^...$` numeric-anchor pattern. It was not changed by this pacing fix; assess its
own trailing-newline handling separately rather than widening this patch.

## Launch gate: parent review passed; authorized loop and bounded trials

Parent launch review of `kit/local-pacing-demo` at `739c03e6094e897129fad94fd2ec97122157a918`
passed: static review found no P1, and the narrow canonical-integer parser fix was verified
(external reference 83/83 with all nine judge tasks; delivered stubs prior 72 pass, whole tree
74/83 with both PACING tasks failing). This gate records authorization only: no normative API,
SPEC, test, fixture or library change.

Authorized, in order:

1. One coder loop with the README command (`claude-haiku-5-5` normal attempts,
   `gpt-6.1-sol` high for attempt 2, `gpt-6.1-sol max` for attempt 3; `MAX_ITER=12`,
   `MAX_ATTEMPTS=3`, `ITER_SECONDS=1200`, `JUDGE_TIMEOUT=300`). Only `scripts/pacing/runner.exs`
   and appended `PROGRESS.md` lines are coder work. Runner commits and discards are limited to
   passing attempts and attempt-owned failures. Contract gaps stop the loop for review; no
   speculative retries. Provider availability, auth or provider errors stop and are reported.
2. After the loop's judge and final checks pass, 18 bounded local trials per the scope A
   contract (below). No other loop, kit or model call.

Budget and spend: the original $25 aggregate is not expanded; provider caps are owner-confirmed,
not independently verified and not runner-enforced; spend and remaining funds are unknown.

### Trial protocol (scope A, local, same machine)

- Target fixed at 19,392,658 bps, 188-byte units, 5 seconds, discard or UDP loopback
  with grouping 1 or 7. Three repetitions per language, 18 trials, 90 requested seconds.
- Order: pair index k = 3*(rep-1)+config (configs ordered discard, loopback 1, loopback 7).
  Elixir runs first when k is even; Go runs first when k is odd. Trials are strictly sequential.
- Elixir: after `MIX_ENV=prod mix compile`, run
  `MIX_ENV=prod mix run scripts/pacing.exs --bps 19392658 --unit-bytes 188 --seconds 5`
  with `--udp loopback --per-datagram 1|7` where applicable, each under `timeout 12`.
- Go: build once offline into a temporary path outside the sibling, using
  `GOPROXY=off GOSUMDB=off GOTOOLCHAIN=local GOWORK=off go build -mod=readonly` from a read-only
  sibling checkout at `../pll` (`971282632129110794c9d6edd22026e9de2359be`). Each trial runs that
  executable as `-bps 19392658 -unit-bytes 188 -seconds 5` with `-udp loopback -per-datagram 1|7`
  where applicable, each under `timeout 12`. The executable avoids per-trial `go run` startup.
  No Go source, `go.mod` or `go.sum` changes are allowed in the sibling.
- Stop, with no retries or search: execution errors, socket errors, guard/cap/cancel stops,
  nonzero exit, external timeout, or a failed preparation step. Completed trials whose
  timing or bitrate verdict fails are recorded honestly and do not stop the matrix. No threshold
  tuning and no rate escalation.
- Raw stdout/stderr, exit codes, commands, start/end time, platform, OTP/Elixir/Go versions,
  schedulers, kit and sibling Git refs with dirty state are saved under the ignored
  `.loop/pacing-comparison/` only. Nothing versioned records machine-specific artifacts.

Criteria per completed trial (both languages):

- nonempty (offered > 0), accepted bytes exactly 188 * offered, no error, cap, cancel or guard stop;
- final backlog <= 5 ms and oldest-unit p99 <= 5 ms;
- writer payload Mbps within 1% of 19.392658. Elixir reports raw elapsed ns. Go prints
  elapsed only to milliseconds, so the Go 1% check uses exact printed byte counts with the
  printed elapsed; this precision limit is recorded, not papered over.

Go's normal run exits 0 without a pass verdict; the criteria above are computed by the
operator from its raw summary. Lateness is oldest unit per wake-up, not per-packet interarrival.
Accepted-send counts are send acceptance, not receiver receipt; the receiver discards data and
no loss, jitter, wire bitrate, header overhead, TS validity or device guarantee follows.

## Live result: authorized loop and bounded matrix complete (author review gate)

Loop: `PACING-runner` passed on attempt 1 with `claude-haiku-5-5` at `598a4a2` (Coder-Command
trailer present); `PACING-tree` passed the judge with no coder attempt. No `gpt-6.1-sol`
escalation, discard or STOP. Changed by the loop: `scripts/pacing/runner.exs` and `PROGRESS.md`
only. Checks at `598a4a2`: format (both script trees), warnings-as-errors compile, `mix test
test/pacing --seed 0` 11/11, `mix test --seed 0` 83/83, `scripts/loop.sh --check` 9/9 pass.

Matrix: all 18 trials ran once, each command exited 0 under `timeout 12`, with no external timeout,
no stderr, no halt and no retry. Elixir: `MIX_ENV=prod mix run scripts/pacing.exs` after a prod
compile, reporting `stop: :deadline`. Go: the `pllpace` executable built offline from the
read-only sibling at `971282632129110794c9d6edd22026e9de2359be`, with `GOPROXY=off GOSUMDB=off
GOTOOLCHAIN=local GOWORK=off -mod=readonly`, output outside the sibling. The sibling was clean
before and after. Order alternated per pair as in the protocol. Matrix wall time 117.6 s.
Raw outputs, commands, exits, timings and Git refs are under ignored `.loop/pacing-comparison/`.

Per config (3 repetitions each; target writer rate 19.392658 Mbps, bound 1%):

| Config | Elixir writer Mbps (min-max) | Elixir backlog ms (min-max) | Elixir oldest-unit p99 ms (max) | Go writer Mbps (min-max) | Go backlog ms (max) | Go oldest-unit p99 ms (max) | Pass |
| --- | --- | --- | --- | --- | --- | --- | --- |
| discard | 19.3851-19.3853 | 1.901-1.939 | 2.045 | 19.3929 | 0.000 | 0.020 | 3/3 each |
| UDP loopback group 1 | 19.3858-19.3876 | 1.301-1.771 | 1.943 | 19.3926-19.3929 | 0.022 | 0.028 | 3/3 each |
| UDP loopback group 7 | 19.3852-19.3920 | 0.175-1.927 | 1.985 | 19.3929 | 0.000 | 0.022 | 3/3 each |

Every trial passed all approved criteria: nonempty; accepted bytes exactly 188 * offered; no error,
cap, cancel or guard stop (Go: exit 0); backlog <= 5 ms; oldest-unit p99 <= 5 ms; writer Mbps
within 1% of target. Elixir writer deviation was 0.004-0.039%; Go was 0.001%. Go's 1% check used
exact printed byte counts and printed elapsed (ms precision), because Go prints no raw elapsed ns.
No threshold was tuned.

Observed lateness (oldest unit per wake-up, not per packet): Elixir median ranged 0.19-1.96 ms and
due calls 2,596-8,352 with 7.7-24.8 units per call, because it waits in whole milliseconds and
drains batches. Its maximum reached 7.08 ms in one group-1 trial (rep 2), above the 5 ms bound
on maximum lateness but not a pass criterion. Go woke about 64,400 times per trial with median
11-12 us and p99 16-28 us. These are different schedulers, not one identical per-packet metric.

Limitations and boundaries:

- Same machine, not a controlled idle system. Other local sessions were active; 1-minute load was
  4.10 at matrix start and 2.98 at end (10 schedulers). Ambient load is a comparison limitation;
  its contribution to the Elixir spread is not isolated.
- Three repetitions per config, one machine, one short run each. No speed ratio, no universal or
  hardware-independent claim.
- Writer-accepted bytes are send acceptance only. The receiver discards data; there is no receipt,
  loss, jitter-at-receiver, wire bitrate, header overhead, device or valid MPEG-TS guarantee.
- Payloads are zero-filled timing bytes, not MPEG-TS. Discard runs send nothing to a network.
- No ticker mode, find-max, remote UDP, or flag parity beyond the approved pacer demonstration.
- Spend: one coder call (Haiku attempt 1); no gpt-6.1-sol call. Total spend is unknown; the
  original $25 total is not expanded and provider caps are owner-confirmed, not independently verified.

Gate: the authorized loop and matrix are complete. No further loop, trial, model call or threshold
change is authorized; the outcome is for author review.
