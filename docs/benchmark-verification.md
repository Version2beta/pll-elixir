# Benchmark overlay kit verification — preparation only

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
  nonzero checksums. Process-level shell elapsed 0.28 s (startup included), not
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

## Limitations and next gate

Reference evidence proves bounded feasibility on actual Stage 3, not a completed
coder implementation or independent acceptance. Tests cover representative finite
workflows, not all possible harness implementations or benchmark environments.
Loop/accounting/checksum overhead is timed; global GC counters include other VM
work. Memory deltas are not allocations or peaks. No confidence intervals,
performance thresholds, Go comparison, live clock/device/network integration,
security audit, publication or broad runtime matrix is established.

All recorded benchmark output remains temporary outside the checkout; no permanent
results format is added. Reference code must not be exposed to coder. Parent review
is required before any real model loop. Original aggregate $25 unchanged; provider
caps owner-confirmed, not verified; spend and remaining amount unknown. No extra
models/fanout, installs, remotes, sibling writes, library refactors or publication.
