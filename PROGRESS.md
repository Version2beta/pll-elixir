# Stage 1 progress

Current state (author review gate): the owner-authorized Stage 1 runner completed on
kit/stage1-exact-pacing. T1 (792e3f8), T2 (7b4603e) and T3 (d999aac) each passed on
the first claude-haiku-5-5 attempt; T4 (whole stage) passed the runner judge with 38
tests. No gpt-6.1-sol escalation and no STOP. Total spend unknown; the owner-reported
provider cap is not independently verified. No further Stage 1 loop is authorized; the
Stage 2 run is recorded at the end of this file.

Kit preparation (historical, before the run) verified protected seams/tests against an
external private reference using unchanged runner --check: T1 9, T2 21, T3 8, T4 38 passing tests.
Both pacing README fences passed on that reference. Every task fails delivered
stubs; whole-stage stubs: 1/38 passed, 37 failures. No coder attempts had run then.

Owner clarified: validate all scalar types/envelopes left-to-right, then semantics.
Independent source review found no code/test blockers. The owner authorized the
Stage 1 paid implementation run: $25 total budget; a provider-side cap is reported
configured by the owner (not independently verified, not runner-enforced).
No follower or later-kit work is authorized.
T1: Implemented PLL.RateCore factories in lib/pll/rate_core.ex: per-scalar type then uint64 envelope checks (left-to-right), zero-term invalid_rate, gcd reduction, bits_per_second, and exact to_string spelling with ArgumentError for wrong kinds.
T1 evidence: test/pll/rate_test.exs 9/9 passed (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors passed; whole suite now 9/38 (remaining failures are unimplemented T2-T4 Pacer/Span/trim work). Only lib/pll/rate_core.ex changed.
T1 blockers: none found; no contract gap; no private reference or external implementation was consulted, and the Go source was not read.
T2: Pacer and Span untrimmed issuance, bounds, lazy snapshots and README examples implemented.
T2 changed: lib/pll/pacer_core.ex, lib/pll/span_core.ex and new private lib/pll/segment_core.ex. Evidence: task test 21/21 passed (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors passed; full suite 30/38 (rate 9/9 and the T2 files pass; the 8 failures are trim_test/model_test, T3).
T2 remaining/blocks: valid nonzero set_trim is not implemented and still returns invalid_argument (T3 must replace it); no new contract gap found; no private reference or external implementation consulted; Go source not read.
T3: Implemented valid nonzero set_trim in lib/pll/pacer_core.ex (new private retrim: re-anchor at floor of old cursor time, overflow if above Imax, no-op for unchanged trim kept first) and a shared exact segment builder SegmentCore.new/5 in lib/pll/segment_core.ex (period den*10^21/(num*(10^12+q)), gcd-reduced; new/1 now uses it, same ratio). Evidence: task test test/pll/trim_test.exs + test/pll/model_test.exs 8/8 passed (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors --force passed; earlier T1/T2 suites 30/30 passed; whole suite mix test --seed 0 38/38 passed.
T3 remaining/blocks: none found; no new contract gap; no private reference or external implementation consulted; Go source not read; no protected files edited. Runner judgment and commit remain for the runner; follower work remains out of scope.

# Stage 2 kit checkpoint (supersedes prior no-follower authorization statements)
Historical: Stage 2 preparation and a verified kit commit were authorized, with no coder
launch at that checkpoint (superseded by the run authorization below).
Temporary unsupported errors for windowed/outlier observations are approved;
full windows/outliers/steps remain Stage 3. Delivered follower core is a stub.
Stage 1 remains implemented and protected. Parent reviews verified kit before any
implementation loop. No increased budget; provider cap owner-reported, spend unknown.
Stage 2 verification: actual Stage 1 baseline and delivered-stub prior suites pass
38 tests; new config/mapping/loop tasks all fail stubs (whole tree 39/55 passed,
16 expected failures). Private reference overlay on actual Stage 1 passes unchanged
runner all seven tasks (9/21/8/4/4/9/55), whole tree and three public examples.
Protection inventory checked, runner byte-identical; disposable regression suite
26/26 passes and 26/26 mutations caught. No coder/model subprocess launched.

Stage 2 prelaunch review strengthening: exact 1.25ns outlier/lock fixtures reject
classification using rounded errors; each independent mutation fails 1/9 loop
tests. Added both input envelopes, wrong-kind getters/observe/reset, true wide
mapping cancellation, remote overflow, reset config retention, negative clamp/
trim saturation and Imax binary64 lock threshold within existing test groups.
Counts unchanged: reference tasks 9/21/8/4/4/9/55 all pass; delivered stubs retain
38 Stage 1 passes and fail every S2 task (39/55 whole tree, 16 failures).
Reference verification used a separate temporary overlay on actual Stage 1;
owner checkout implementation stubs were never replaced. That preparation ended at its
parent launch gate; no coder/model calls or Stage 3 work were performed then.

# Stage 2 parent review and run authorization
Parent review of the Stage 2 kit (kit commit 67813b6) is complete. The owner authorized
the Stage 2 implementation run with the root README command: claude-haiku-5-5 for normal
attempts, gpt-6.1-sol high for the second attempt, gpt-6.1-sol max for the final attempt,
MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200, JUDGE_TIMEOUT=300. Runner commit and
discard permissions continue for attempt-owned changes only. The original $25 budget is
not expanded; caps are owner-confirmed, not independently verified; total spend is unknown.
The run had not started when this checkpoint was committed. The temporary :unsupported
boundary is unchanged until Stage 3. Stage 3 and later kits remain unauthorized.

# Stage 2 run result (current; author review gate)
The authorized runner exited 0 after `every task passes` (raw output and exit code in
ignored .loop/stage2.run.out and .loop/stage2.exit). Each task passed on attempt 1 with
claude-haiku-5-5: S2-config cd8b3ea, S2-mapping b1e9249, S2-loop ec3aa37. S2-tree passed
the runner judge without a coder attempt. No gpt-6.1-sol escalation, no STOP, and no
attempt was discarded. Runner changes since the docs commit 6c3a590 were limited to
lib/pll/follower_core.ex and PROGRESS.md. Final checks: format check passed; warnings-as-errors compile passed;
`mix test --seed 0` reported 55 passed; `bash scripts/loop.sh --check` passed all seven
tasks. Stage 2 is limited: windows, outliers, steps, Go parity and the complete follower
remain unimplemented, and the temporary :unsupported boundary remains. Total spend is unknown;
the run made three coder calls. No further loop is authorized.
S2-config: Implemented PLL.FollowerCore.new/1 in lib/pll/follower_core.ex: table-order type, envelope and semantic checks (nominal must be a valid reduced-uint64 Rate; float fields must be floats; signed 64-bit integer envelopes return overflow); a wrong config kind raises ArgumentError; success returns {:ok, %PLL.Follower{config: config}} unanchored. Evidence: test/pll/follower_config_test.exs 4/4 passed (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors --force passed; Stage 1 suites 38/38 passed; whole tree 42/55 with 13 failures remaining.
S2-config changed only lib/pll/follower_core.ex (new/1 and private validation helpers; other follower stubs untouched); no protected file, test or dependency changed; no private reference, external implementation or Go source consulted; no new contract gap found.
S2-config remaining: observe/local/remote/offset/trim/jitter/state/reset stay stubs for S2-mapping and S2-loop; nonfinite float rejection is not separately exercisable on BEAM, so only the type/semantic checks apply; no blocker.
S2-mapping: Implemented in lib/pll/follower_core.ex: first-reading anchoring (window_ns>0 returns the Stage 2 unsupported error even at first anchor), left-to-right scalar validation, signed local/remote mapping with wide-difference cancellation, offset/trim/jitter/state/reset getters from current fields, and ArgumentError for wrong struct kinds. Evidence: test/pll/follower_mapping_test.exs 4/4 (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors --force passed; Stage 1 suites 38/38 and follower_config_test 4/4 passed; whole tree mix test --seed 0 46/55 with only the 9 follower_loop_test (S2-loop) failures left. Only lib/pll/follower_core.ex changed; no protected file, test or dependency touched; no private reference, external implementation or Go source consulted; no new contract gap found.
S2-mapping remaining: observe on an already-anchored follower still returns a not_anchored placeholder (order check, inlier feed, window/outlier boundary), which is S2-loop work; lock_run, last_accepted, jitter and the reference update are not fed yet, so state/jitter for anchored followers are correct only for the post-anchor fields.
S2-mapping blocks: none for this task; S2-loop must replace the anchored observe placeholder and must make the 9 follower_loop_test cases pass before S2-tree can pass.
S2-loop
S2-loop changed: lib/pll/follower_core.ex implements later-reading observe: order check (local >= last local, remote > last remote); window_ns>0 and unrounded old-mapping abs(e) > outlier_threshold_ns return the temporary unsupported error with no state change; accepted inliers update the mapping only when dt>0 (capped gain/rate, rounded displacement anchor, overflow-checked), then lock run and two-sample jitter. Evidence: follower_loop_test 9/9 (seed 0); format check and warnings-as-errors compile passed; whole tree 55/55; a scratch 60,000-observe fuzz (not in repo) raised no exceptions. Only lib/pll/follower_core.ex and PROGRESS.md changed; no protected file, test or dependency touched; no private reference, external implementation or Go source consulted.
S2-loop remaining/blocks: no new contract gap and no blocker found; Stage 3 windows/outliers/steps stay deferred and the temporary unsupported boundary remains; task judgment and commit are left to the runner.

# Stage 3 preparation checkpoint (not a runnable kit)
Stage 3 kit preparation is approved; no implementation loop before parent review.
Current baseline at e3352c2 independently passes format/compile/55 tests/all seven
runner checks. Created kit/stage3-follower-parity from that clean actual build.
Added draft private-history seam/stub and six history tests; replaced only temporary
Stage 2 unsupported expectations with final normative successful transitions.
Draft external reference passes 61 tests; supplied stubs pass 53/61 and all 46 prior
pacing/config/mapping checks. Full Stage 3 kit verification is NOT complete.
Paused per parent direction pending owner fixture encoding/temp harness approval.
No harness/model launch, encoding decision, partial kit commit, install or sibling
write. See docs/stage3-checkpoint.md for exact evidence, reference path and remaining
work. Historical Stage 2 SPEC/tasks/PROMPT are not Stage 3 launch instructions.

# Stage 3 verified overlay kit — parent review before implementation loop
Owner explicitly approved dependency-free decimal-integer/hex-binary64 lines and
separate temporary offline public-Go generation leaving ../pll untouched. Preparation
resumed from preserved checkpoint; no additional model/coder calls occurred.
Final scope/ownership, superseded temporary assertions and verification are recorded
in docs/stage3-verification.md; corpus schema/provenance in docs/corpus.md. Prior
checkpoint scratch was incorporated there, not shipped as contradictory instructions.
Supplied stubs: 53/66 tests pass, 13 expected failures; 46 prior pacing/config/mapping
checks pass. External reference over actual Stage 2: 66 tests and every unchanged
runner task pass. Both new S3 tasks fail stubs; task IDs preserve historical attempts.
Generator run twice offline yields identical 172-line/159-record pinned public corpus;
Go sibling stays clean. Mechanics: 26 pass/26 mutations caught, runner unchanged.
Original $25 total not expanded; caps owner-confirmed, spend unknown. No implementation
loop before parent review; no installs/remotes/publication/later kits.

# Stage 3 pre-launch review strengthening
Test-only blocker addressed: step now starts locked with two nonzero inliers and
nonzero jitter; poststep acquiring/first-inlier jitter and restarted outlier run
are discriminated. Omitting lock/jitter-count/outlier clears individually fails.
Valid continuation is flushed after overflow; reset open-window state is observed
through a new boundary. Seeded oracle tests count classifications and add replay
order checks. Exact clean corpus trim replay passed and tolerance is tightened to
exact. Docs distinguish finite exact numerical fixtures from universal float
identity and no longer disclose private reference/evidence locations. Counts remain
66 total/20 S3-history. No coder/model calls; parent launch gate remains required.

# Stage 3 launch gate (parent review passed)
Parent review of the Stage 3 kit (kit commit 460ef51) and the 159-record public-Go corpus
passed. Docs now record one owner-authorized Stage 3 implementation run with the README
command: claude-haiku-5-5 for normal attempts, gpt-6.1-sol high for the second attempt and
gpt-6.1-sol max for the final attempt; MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200,
JUDGE_TIMEOUT=300. Runner commit/discard permissions apply only to passing attempts and
attempt-owned failures. The original $25 total is not expanded; provider caps are
owner-confirmed, not independently verified; spend is unknown. This gate update changes
no normative API, SPEC or test contract. The run had not started at this checkpoint.
S3-history: implemented final window candidates, strict-smaller signed tie rule, flush-then-trigger windows, first-error outlier runs, exact re-anchoring steps and transactional rollback in lib/pll/follower_history.ex only (private window %{start,local,remote,error} and outlier %{first,count} state; reuses FollowerCore history_error/3 and history_inlier/4).
S3-history evidence: task command 20/20 passed; mix format --check-formatted, MIX_ENV=test mix compile --warnings-as-errors and mix test --seed 0 66/66 passed; a scratch 300x300 random ordered run (not kept) raised no exceptions. No protected file, dependency, private reference or external implementation was read or changed; no new contract gap found.
S3-history remaining/blocks: none for this task. Not committed or marked done; the runner judges. Corpus and synthetic passes are finite fixture evidence, not universal cross-language parity.

# Stage 3 run result (current; author review gate)
The single authorized runner run exited 0 after `every task passes` (raw output and exit code
in ignored .loop/stage3.run.out and .loop/stage3.exit). S3-history passed on attempt 1 with
claude-haiku-5-5 at 89a1a81; S3-tree passed the judge without a coder attempt. No
gpt-6.1-sol escalation, discard or STOP. Changed by the run: lib/pll/follower_history.ex
and PROGRESS.md only; protected paths unchanged. Acceptance at HEAD: format passed,
warnings-as-errors compile passed, `mix test --seed 0` 66 passed, `scripts/loop.sh --check`
passed all seven tasks. Completed observe never emits :unsupported. Evidence is finite
fixtures and frozen-gain models, not universal parity, live integration, security or
performance. Total spend unknown; one coder call. No further loop is authorized.

# Benchmark overlay kit — parent review before coding loop
Owner Proceed approved bounded dependency-free throughput tool outcome and verified
kit commit only at this checkpoint. Baseline actual clean Stage 3 HEAD 03a99baca1db2872f6e6f9298914aab9e2242a2a;
new branch kit/throughput-benchmark. Public API-only nine workloads; complete bounded
parser/report arithmetic and CLI, one implementation stub and six protected tests.
All 66 prior checks pass delivered stubs; whole tree 68/72 (4 expected failures),
BENCH-1 and BENCH-tree both fail unchanged --check. External private reference over
actual Stage 3 passes all 72 tests and eight runner tasks. Public smoke: 18 observed
samples, 0.28 s startup-inclusive local elapsed; statuses/sinks inspected. No speed
claims. Detailed scopes/limits/protection evidence: docs/benchmark-verification.md.
Runner byte-identical; mechanics 26 passes/26 mutations caught. .loop state kept.
Only scripts/bench/runner.exs and progress notes are writable. All library sources,
tests, config, READMEs/docs, complete parser/entrypoint protected. No real loop/model
calls, installs, remotes/publication or sibling changes. Original $25 total unchanged,
caps reported not independently verified, spend unknown. Stop for parent review.


# Benchmark kit independent-review strengthening — still before launch
Addressed all P1/P2 review gaps: exact units/all workloads and bad nonzero counts;
independent full public chained inlier/outlier state reductions; architecture,
schema/revision smoke labels; nonpositive elapsed rejection without exception-type
overpinning. README now explicitly names both follower phase/lock thresholds as
10 ns; external reference configs match (no library/API change).
Actual prior tests 66/66 pass; stubs 68/72 with both BENCH tasks failing --check;
external reference 72/72 and all eight unchanged runner tasks pass. Four isolated
stale-state/positive-units/default-lock mutations each fail one benchmark test.
Public smoke: 18 rows in 0.26 s including startup, window accepted2/pending10,
step rejected8/stepped4. Counts remain six benchmark tests/72 total. Evidence in
docs/benchmark-verification.md. Protected source/old tests and owner runner stub
unchanged. No model/real implementation loop; stop for parent launch review.

# Benchmark launch gate (parent review passed)
Parent review of the benchmark kit (HEAD 4867fc4d82168e230c37ea2022ca28a2b6eb0da1 on
kit/throughput-benchmark) passed, including the independent-review strengthening recorded in
docs/benchmark-verification.md. One owner-authorized coding loop is permitted with the README
command: claude-haiku-5-5 for normal attempts, gpt-6.1-sol high for the second attempt and
gpt-6.1-sol max for the final attempt; MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200,
JUDGE_TIMEOUT=300. Runner commit/discard permissions apply only to passing attempts and
attempt-owned failures. The original $25 total is not expanded; provider caps are
owner-confirmed, not independently verified; spend is unknown. Only scripts/bench/runner.exs
is coder work; library, tests, fixtures and README/SPEC are unchanged by the loop. The loop
had not started at this checkpoint.

BENCH-1: implemented the public-API throughput runner in scripts/bench/runner.exs only: nine chained PLL workloads, exact count/status validation, fake-clock sample arithmetic with memory/VM-GC deltas, and the sequential main header/sample output; exported names, signatures and doc comments preserved.
BENCH-1 evidence: mix format --check-formatted (including scripts/bench/*.exs and scripts/throughput.exs) passed; MIX_ENV=test mix compile --warnings-as-errors passed; task command 6/6 passed (seed 0 and 12345); mix test test/pll --seed 0 66/66; mix test --seed 0 72/72; mix run scripts/throughput.exs --smoke exit 0 with 18 sample rows across all nine workloads; bad option exit 2. Issuance units use observed Pacer.next_due cursor deltas because Span fields are private; no protected file, dependency or private/outside reference was read or changed.
BENCH-1 remaining/blocker: none for this task; not committed or marked done, loop.sh --check not run, and the runner alone judges and commits. Timing values are local finite-run evidence only, with no thresholds or speed claims.

# Benchmark loop result (current; author review gate, no further loop)
The single owner-authorized runner run exited 0 after `every task passes` (raw output and exit
code in ignored .loop/bench.run.out and .loop/bench.exit). BENCH-1 passed on attempt 1 with
claude-haiku-5-5 at e477f81 (Coder-Command trailer present); BENCH-tree passed the judge with
no coder attempt. No gpt-6.1-sol escalation, discard or STOP. The run changed only
scripts/bench/runner.exs and PROGRESS.md; library, tests, fixtures, READMEs, SPEC, config and
complete seams are unchanged. Spend unknown; one coder call. No further loop is authorized.
Coder notes (BENCH-1 attempt 1): Issuance units use observed Pacer.next_due cursor deltas
because Span fields are private. Timing values are local finite-run evidence only.
