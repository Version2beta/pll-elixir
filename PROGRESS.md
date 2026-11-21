# Stage 1 progress

Kit preparation verified protected seams/tests against an external private
reference using unchanged runner --check: T1 9, T2 21, T3 8, T4 38 passing tests.
Both pacing README fences passed on that reference. Every task fails delivered
stubs; whole-stage stubs: 1/38 passed, 37 failures. No coder attempts have run.

Owner clarified: validate all scalar types/envelopes left-to-right, then semantics.
Independent source review found no code/test blockers. The owner authorized the
Stage 1 paid implementation run: $25 total budget; a provider-side cap is reported
configured by the owner (not independently verified, not runner-enforced).
No follower or later-kit work is authorized.
T1: Implemented PLL.RateCore factories in lib/pll/rate_core.ex: per-scalar type then uint64 envelope checks (left-to-right), zero-term invalid_rate, gcd reduction, bits_per_second, and exact to_string spelling with ArgumentError for wrong kinds.
T1 evidence: test/pll/rate_test.exs 9/9 passed (seed 0); mix format --check-formatted and MIX_ENV=test mix compile --warnings-as-errors passed; whole suite now 9/38 (remaining failures are unimplemented T2-T4 Pacer/Span/trim work). Only lib/pll/rate_core.ex changed.
T1 blockers: none found; no contract gap; no private reference or external implementation was consulted, and the Go source was not read.
