# Stage 1 supporting contract — exact pacing

This file is subordinate to the approved root [README.md](README.md), especially
Decisions, Public API, Types/bounds/errors, Exact pacer contract and Ownership.
A conflict blocks work; it is never permission to override README promises.

## Approved scope and boundaries

Only PLL.Rate, PLL.Pacer, PLL.Span and stage error values. Elixir >=1.15 /
OTP >=26 baseline; verification on 1.20.4 / OTP 29 only. No dependencies.
No follower implementation, Go corpus/harness, CLI, adapters, release, remote,
installation or publication. All future follower contracts remain in README.

The public modules/types and segment snapshot are complete protected seams.
Factory terms reduce by gcd. The segment pn/pd is a positive exact period in
nanoseconds; it may be reduced, but must represent den*10^21/(num*(10^12+q)).
Pacer carries nominal Rate, cursor, segment; Span carries first/count/segment.
Representation is not a serialization promise. Only factory/transition-issued
values (plus zero Rate/Span sentinels) need support; manually forged states
are unsupported. Wrong struct kinds raise ArgumentError, not FunctionClauseError.
All exported names/signatures/docs are fixed. Implementation lives in the supplied
*_core.ex seams and, if useful, new private helper modules. Public wrappers,
getters, String.Chars dispatch and error messages are complete, not coder work.
PLL.Error.message covers the three Stage 1 codes; future follower codes remain
outside this stage. The development version 0.0.0-dev is not a release promise.

Use unbounded integer arithmetic. See README for exact due vs floor/ceiling,
slot U exclusion, claim last-floor check, skip semantics, no-op trim before
anchor checks, and floor anchoring. Every error is exactly {:error, %PLL.Error{}}
with the specified code and nil field/reason, no state/output. Every success
returns state before output. Validate all scalar types/envelopes left-to-right before any semantic checks,
then validate semantics. Thus units_per_second(0,U+1) and due(p,-1,U+1)
return overflow. Wrong state kind raises before scalar validation. New
ambiguities must be returned for review. Never read implicit time, spawn,
sleep, perform I/O/network/environment access, or mutate process/global state.

## Promise to acceptance checks

All tests use the public API; no production arithmetic helpers in the oracle.

| README promise | Protected checks / task |
| --- | --- |
| Rate factories, gcd, full uint64 terms, getters, exact strings/protocol, zero sentinel, scalar envelopes, wrong kinds, stage messages | test/pll/rate_test.exs / T1 |
| Immutable cursor, due exactness/floor neighbors, ceilings, earlier-now backlog/caps, claim/skip/keep=0, >10^9 units/s, empty spans | test/pll/pacer_test.exs / T2 |
| U never issued/skipped; cursor U and conditional overflow, capped latest slot, Imax floor-fit/ceiling-overflow, failure preservation | test/pll/pacer_test.exs / T2 |
| Span floor, exact index exception categories, zero/issued empty, fresh reusable lazy Enumerable and early halt on enormous extent | test/pll/span_test.exs / T2 |
| First useful 48k example, 30000/1001 example, byte starts | test/pll/readme_test.exs / T2 |
| Trim limits, same-trim true no-op, floor anchor, large periods, original snapshots/issued spans, skip/slow README example | test/pll/trim_test.exs / T3 (invalid trims also T2) |
| Independent rational model, full result/state/error comparisons, seeded operation chains, extreme terms/trims/cursors and retained spans | test/support/rational_oracle_helper.exs and test/pll/model_test.exs / T3 |
| Formatting, warnings-as-errors, complete discovered suite with exact observed count | T4, last; top-level format_check/check also run by judge |

The oracle retains raw rate terms, evaluates unreduced numerator/denominator
pairs directly from the README formula, and binary-searches exact due boundaries
instead of using the production inverse-period approach. It uses no production
timing helper. There are 48 deterministic seeded chains of 80 operations plus
hand-selected boundary chains. Large spans are sampled, never materialized.
The huge-extent early-halt fixture rejects eager enumeration in practice, not
an allocation or universal computational-complexity proof.

## Task boundaries and verification

T1 implements RateCore. T2 implements untrimmed PacerCore/SpanCore, including
validation of invalid trims; T3 adds valid trim transitions and whole-state
rational comparisons. T4 is integration, not a padded independent feature.
Earlier tests must continue passing. During kit preparation, all meaningful tasks
and the whole-tree check were verified to fail supplied stubs and pass the private
reference using unchanged scripts/loop.sh --check. On the owner checkout the runner
then committed passing T1–T3 implementations, and T4 passes the whole stage.
Exact stdout summaries are pinned to installed ExUnit 1.20.4; on another ExUnit summary version stop for kit re-verification rather
than weakening expectations. No test is skipped/excluded.

Protected inventory: root README.md (and any nested approved README), SPEC.md,
PROMPT.md, tasks.json, scripts/loop.sh, .gitignore, .formatter.exs, mix.exs,
LICENSE, any config/ directory, every test/support file, and complete
lib/pll/{error,segment,rate,pacer,span}.ex. PROGRESS.md and the *_core.ex files are
intentionally writable. No private reference belongs in this repository. .loop/, _build/ and existing transient
.wtha/ metadata are ignored; none are runtime library outputs.

Private helpers, exact arithmetic algorithms and period reduction are local
freedom only within those seams. Do not add dependencies or change contracts.
Future follower/config/status/mapping tests, shared Go corpus/encoding, wider
runtime matrix, release automation, publication and OTP adapters are deferred
until their affected reviewed kit. No task may assume those decisions.

## Evidence limits and gate

Reference checks establish satisfiability by one local implementation, not
owner/coder implementation correctness, security, live models, integration,
performance, a supported runtime matrix or actual device use. Runtime effects
are also reviewed in the private reference; development tooling itself writes
_build/. The kit-preparation checkout returned to failing stubs; the current
checkout contains the runner-committed Stage 1 implementation.

The Stage 1 implementation run has completed once under the README launch gate:
three first-attempt claude-haiku-5-5 commits (T1, T2, T3) and a passing whole-stage
T4. No gpt-6.1-sol escalation or STOP occurred. The owner reports a provider-side
spending cap configured; this is not independently verified. The unchanged runner
has attempt/time limits but no dollar cap and does not aggregate spending, so total
spend is unknown. Notes cannot automatically pause it for contract changes; a
contract blocker must stop the run through the harness and return for review.
Current gate: author review. No further implementation loop is authorized by this
document.
