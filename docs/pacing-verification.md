# Pacing kit verification — preparation only

Authority: root README Local real-time pacing demonstration, approved scope A,
and Pacing kit operation. Overlay baseline actual HEAD
cd35fec92eb4632b1efc52468a024eb5bacec497, branch kit/local-pacing-demo.
Existing README/progress design draft preserved and approval accurately recorded.
No coder launch, network trial, installation, dependency fetch, remote or publication.
Original $25 aggregate unchanged; provider caps owner-confirmed, unverified;
spend/remaining unknown. Review before coding; live 18-trial comparison reserved
for actual implementation, not this feasibility work.

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
