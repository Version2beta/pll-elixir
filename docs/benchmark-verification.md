# Benchmark kit verification and implementation evidence

Historical sections below record kit preparation and private-reference feasibility before the
coder loop. The current implementation evidence is the final section, "Implementation loop
result"; it supersedes the preparation-only status and the "not yet run" launch checkpoint.

Baseline: actual clean owner Stage 3 checkout
03a99baca1db2872f6e6f9298914aab9e2242a2a on kit/stage3-follower-parity.
Prepared on kit/throughput-benchmark. Only new benchmark implementation is a
stub; no implementation loop/model calls were made. Private feasibility reference
is excluded from the checkout and is not coder input. README is authority; current
SPEC overlay maps promises/checks. No library source, fixtures or old tests changed.

## Observed local evidence

Elixir 1.20.4, OTP 29, aarch64-apple-darwin27.0.0, 10 online schedulers.
No broader runtime support evidence is claimed.

* Baseline and delivered-stub `mix test test/pll --seed 0`: 66 passed, including
  complete Stage 3 history, synthetic and checked-in public Go corpus checks.
* Delivered-stub `mix test --seed 0`: 68/72 passed, 4 expected failures.
  Benchmark task alone: 2/6 passed. Complete parsing/arithmetic already pass;
  positive real-workload, enumeration, sample and timed output tests fail stubs.
* Delivered-stub unchanged `bash scripts/loop.sh --check`: prior six tasks pass;
  BENCH-1 and BENCH-tree fail. No empty filters or success-marker-only checks.
* External reference over an independent copy of ACTUAL Stage 3 source plus this
  overlay: all 72 tests pass; unchanged runner --check passes all eight tasks:
  9/21/8/4/4/20/6/72. Whole-tree task also runs public CLI --smoke.
* Public `mix run scripts/throughput.exs --smoke` reference execution: exit 0,
  18 measured rows (nine workloads x two samples), all positive elapsed_ns and
  nonzero checksums. Process-level shell elapsed 0.26 s (startup included), not
  a performance guarantee. Header/config/runtime/source labels inspected.
  Due batch units=768/calls=12; claim units=18000/calls=12; span checksum=48384,
  units=768/calls=12. Window statuses accepted=2/pending=10; outlier rejected=12;
  step rejected=8/stepped=4. No huge benchmark configuration was run.
* Public invalid `--samples 0`: exit 2, stderr `invalid or duplicate option:
  --samples`, no stdout. Complete parser tests cover upper bounds, malformed,
  duplicate, missing/unknown and oversized options.
* Fake-clock sample test: 200 ns / 2 calls =100 ns/op, 10^7 ops/s,
  128 units => 640000000 units/s; signed process bytes delta -20,
  VM-wide GC count delta 3 and reclaimed words delta 100. No speed assertion.
* Formatting checks include explicit scripts; warnings-as-errors compile passes.
* scripts/loop.sh byte-identical to skill copy. Inherited disposable mechanics:
  all 26 real-loop cases pass and all 26 deliberate regressions caught; no models.
* Decoded protected patterns verified with grep ERE over tracked plus new kit
  paths: every path except PROGRESS.md and scripts/bench/runner.exs is protected
  (runner implicit kit guards included). All README paths, source, project config,
  test/support/fixtures, corpus generator, docs, complete parser/entrypoint covered.
  Existing .loop logs/state preserved; new BENCH IDs avoid earlier attempts.

## Independent-review strengthening (parent launch gate remains)

Reviewed kit at 5361081; addressed all three P1 gate findings and cheap P2s.
The six benchmark tests retain their count but now check:

* Exact units per op for every workload; invalid nonzero units/calls and status
  counts must raise, with no prescribed exception type.
* Prepared follower states equal independently constructed/anchored public states
  with both outlier_threshold_ns and lock_threshold_ns set to 10 ns. README
  threshold wording now names these two fields explicitly (precision only).
* Inlier/outlier final states equal independent public Follower.observe reductions
  chaining every next state, for n=1,4,12,17. No private-field inspection or shared
  execute helper. This detects stale anchored state even when statuses agree.
* Smoke header includes architecture, pll-throughput-v1 and the full pinned
  library revision. Zero and negative elapsed fake clocks must raise.

Fresh verification after strengthening: actual prior suite 66 passed; delivered
stubs 68/72 (four expected failures), BENCH-1/BENCH-tree both fail --check; external
reference all 72 and every runner task pass. Public smoke produces 18 rows in
0.26 s startup-inclusive shell elapsed with the representative counts above.
Four isolated external reference mutations each yield 5/6 benchmark tests passing
(one failure): reuse initial state for inlier; reuse initial state for outlier;
validate only positive units; restore default lock threshold 100000. Unmodified
reference passes 6/6. No model/coder calls; owner implementation remains stubbed.
Unchanged runner and full decoded grep-ERE protection inventory rechecked.

## Parent launch gate (passed; the one loop has since completed)

Parent launch review of the kit at 4867fc4d82168e230c37ea2022ca28a2b6eb0da1 passed.
The independent-review strengthening above is part of the reviewed kit. The owner
authorized one coding loop with the README command only (Haiku normal; gpt-6.1-sol
high second attempt; gpt-6.1-sol max final; MAX_ITER=12, MAX_ATTEMPTS=3,
ITER_SECONDS=1200, JUDGE_TIMEOUT=300). Only scripts/bench/runner.exs is coder work.
This checkpoint predates the loop; the loop result is recorded in the final section.

## Limitations and next gate

Reference evidence proves bounded feasibility on actual Stage 3, not a completed
coder implementation or independent acceptance. Tests cover representative finite
workflows, not all possible harness implementations or benchmark environments.
Loop/accounting/checksum overhead is timed; global GC counters include other VM
work. Memory deltas are not allocations or peaks. No confidence intervals,
performance thresholds, Go comparison, live clock/device/network integration,
security audit, publication or broad runtime matrix is established.

All recorded benchmark output remains temporary outside the checkout; no permanent
results format is added. Reference code must not be exposed to coder. Parent launch review
passed; a single owner-authorized loop is permitted. Original aggregate $25 unchanged; provider
caps owner-confirmed, not verified; spend and remaining amount unknown. No extra
models/fanout, installs, remotes, sibling writes, library refactors or publication.

## Implementation loop result (current)

Historical kit feasibility above (private reference, stub failures, parent launch review) is
separate from the completed implementation below. The implementation is the runner's single
coder attempt, not the private reference.

* Loop: `MAX_ITER=12 MAX_ATTEMPTS=3 ITER_SECONDS=1200 JUDGE_TIMEOUT=300` with the README
  commands, run once from kit/throughput-benchmark after the pre-launch docs gate `e8e5068`.
  Exit 0 after `every task passes`. Output: ignored `.loop/bench.run.out`; exit code
  `.loop/bench.exit`. No STOP, no discard, no escalation.
* Commits: `e477f81` (BENCH-1 attempt 1, `claude-haiku-5-5`, `Coder-Command:` trailer).
  BENCH-tree had no coder attempt and passed the judge. One coder call; spend unknown.
* Changed by the loop: `scripts/bench/runner.exs` and `PROGRESS.md` only. Library, tests,
  fixtures, configuration, READMEs and SPEC were not changed by the loop.
* Implementation review: nine chained public workloads through `prepare/2`, `execute/3`
  and `validate!/3`; warmup and setup outside timing; elapsed measured only around
  `execute/3`; the final state remains live through the second clock and is dropped from the
  report; exact calls/units/statuses are validated after timing and mismatches raise.
  Snapshots record self-process memory and VM-wide GC counters only.
* Acceptance at the final docs commit: `mix format --check-formatted` and the same
  command for `scripts/bench/*.exs scripts/throughput.exs`, `MIX_ENV=test mix compile
  --warnings-as-errors`, `mix test --seed 0` (72 passed), `bash scripts/loop.sh --check`
  (8/8 pass), and `mix run scripts/throughput.exs --smoke` (18 rows, exit 0).
* Local default baseline: `MIX_ENV=prod mix run scripts/throughput.exs` completed in about
  one second with 27 rows (nine workloads, three samples). Output is ignored
  `.loop/bench.baseline.out`; it is machine-specific and not versioned.
* Limits: one machine, short runs, three samples. No speed claim, Go comparison, allocation
  measurement, real-time claim or confidence interval. Process memory deltas are
  self-process net changes (can be negative). VM GC counts and reclaimed words are VM-wide.
  Reclaimed words are not allocation volume. Timing includes loop, accounting and sink
  overhead, and one initial cursor read inside `execute/3`. Batch units (slots/readings/tuples)
  are not call latency. No runtime matrix, publication or adapter claim.
