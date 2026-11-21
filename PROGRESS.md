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

# Stage 2 parent review and run authorization (current)
Parent review of the Stage 2 kit (kit commit 67813b6) is complete. The owner authorized
the Stage 2 implementation run with the root README command: claude-haiku-5-5 for normal
attempts, gpt-6.1-sol high for the second attempt, gpt-6.1-sol max for the final attempt,
MAX_ITER=12, MAX_ATTEMPTS=3, ITER_SECONDS=1200, JUDGE_TIMEOUT=300. Runner commit and
discard permissions continue for attempt-owned changes only. The original $25 budget is
not expanded; caps are owner-confirmed, not independently verified; total spend is unknown.
The run had not started when this checkpoint was committed. The temporary :unsupported
boundary is unchanged until Stage 3. Stage 3 and later kits remain unauthorized.
S2-config: Implemented PLL.FollowerCore.new/1 in lib/pll/follower_core.ex: table-order type, envelope and semantic checks (nominal must be a valid reduced-uint64 Rate; float fields must be floats; signed 64-bit integer envelopes return overflow); a wrong config kind raises ArgumentError; success returns {:ok, %PLL.Follower{config: config}} unanchored. Evidence: test/pll/follower_config_test.exs 4/4 passed (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors --force passed; Stage 1 suites 38/38 passed; whole tree 42/55 with 13 failures remaining.
S2-config changed only lib/pll/follower_core.ex (new/1 and private validation helpers; other follower stubs untouched); no protected file, test or dependency changed; no private reference, external implementation or Go source consulted; no new contract gap found.
S2-config remaining: observe/local/remote/offset/trim/jitter/state/reset stay stubs for S2-mapping and S2-loop; nonfinite float rejection is not separately exercisable on BEAM, so only the type/semantic checks apply; no blocker.
S2-mapping: Implemented in lib/pll/follower_core.ex: first-reading anchoring (window_ns>0 returns the Stage 2 unsupported error even at first anchor), left-to-right scalar validation, signed local/remote mapping with wide-difference cancellation, offset/trim/jitter/state/reset getters from current fields, and ArgumentError for wrong struct kinds. Evidence: test/pll/follower_mapping_test.exs 4/4 (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors --force passed; Stage 1 suites 38/38 and follower_config_test 4/4 passed; whole tree mix test --seed 0 46/55 with only the 9 follower_loop_test (S2-loop) failures left. Only lib/pll/follower_core.ex changed; no protected file, test or dependency touched; no private reference, external implementation or Go source consulted; no new contract gap found.
S2-mapping remaining: observe on an already-anchored follower still returns a not_anchored placeholder (order check, inlier feed, window/outlier boundary), which is S2-loop work; lock_run, last_accepted, jitter and the reference update are not fed yet, so state/jitter for anchored followers are correct only for the post-anchor fields.
S2-mapping blocks: none for this task; S2-loop must replace the anchored observe placeholder and must make the 9 follower_loop_test cases pass before S2-tree can pass.
