# Stage 2 supporting contract — bounded mapping and inlier loop

Subordinate to approved root README.md: Decisions/temporary Stage 2 boundary,
Public API, Types/bounds/errors, Follower configuration, Follower state machine,
Queries and Ownership. README wins; conflicts/new promises block work.

## Approved scope and seams

Preserve every Stage 1 guarantee unchanged. Add config, anchoring, ordering,
mapping/rounding, gain/rate updates, accepted inliers, lock/jitter/holdover/reset,
transactional overflow and first follower-to-pacer example. No dependencies,
I/O, implicit clocks, process/global state, adapters, installs or publication.
Stage 3 windows/outliers/steps and Go parity corpus remain deferred. The follower
is not complete. No task may implement Stage 3 or assume a fixture encoding.

All supplied public modules/data types are complete and protected. Follower
carries config plus immutable mapping/reference/order/lock/jitter data, not a
serialized format. Unsupported forged structs need not work. New private helpers
are allowed, but only FollowerCore and new helper files are implementation work;
all Stage 1 source is protected, with no unrelated refactor. Exported names,
signatures/docs stay fixed. Config.default does not validate nominal. Config
validation follows README table order, including all fields deferred in use.

Implement exact error shapes with nil field/reason except config errors. Wrong
state kinds raise ArgumentError. Scalar types/envelopes validate left-to-right
before semantics. Observe then checks existing order, then unsupported boundary:
window_ns>0 always unsupported, including first anchor; window=0 first reading
anchors; later abs(unrounded e)>float(outlier_threshold_ns) unsupported. No
metadata changes or replacement state on any failure. Otherwise feed the inlier.
No fabricated pending/rejected/stepped behavior in this stage. Error message is
`pll: unsupported in Stage 2`. Remove this temporary boundary only in Stage 3.

Use README equations and rounding of displacement, not absolute time. Subtract
signed-fitting integer differences before conversion; wide differences use
float(a)-float(b). Add rounded displacement exactly to integer anchors, allowing
wide cancellation. Float-domain phase/lock comparisons convert integer thresholds
to binary64, matching pinned Go follower.go outlier/lock comparisons (revision
971282632129110794c9d6edd22026e9de2359be); envelopes/order/elapsed remain exact.
At Imax threshold, binary64 e=-2^63 is an inlier and its reported error saturates
to Imin; this does not relax exact integer input bounds.

Evaluate gain caps without overflowing BEAM float products or reciprocals:
all finite positive bandwidth/damping are valid, including subnormals and max
binary64. Private helper algorithms are local freedom, not changed equations.
Check new integer anchor before exposing any transition. dt=0 leaves mapping,
rate and reference unchanged but updates accepted/lock/jitter/order data.
Jitter uses unrounded errors and requires two inliers before a nonzero getter.
Holdover is a query only; reset retains config but clears all learned history.
No hidden runtime effects or dependencies. Elixir 1.20.4 / OTP29 is the verified
machine, not a claim of wider runtime acceptance.

## Promise-to-test mapping and tasks

| README guarantee | Protected checks / task |
| --- | --- |
| Stage 1 Rate factories, gcd, uint64 terms, strings, zero sentinel, validation/messages | rate_test.exs / T1, 9 tests |
| Stage 1 exact due/floor/ceil, claims, skip, cursor U, bounds, empty/lazy spans, retained snapshots, pacing examples | pacer_test.exs, span_test.exs, readme_test.exs / T2, 21 tests |
| Stage 1 trim/no-op/floor anchor/bounds and independent rational oracle | trim_test.exs, model_test.exs, rational_oracle_helper.exs / T3, 8 tests |
| Full defaults, zero config, field order/reasons, types/envelopes, finite extremes, status/state/error spelling | follower_config_test.exs / S2-config, 4 tests |
| Anchoring, unanchored/scalar errors, half ties, >2^53 anchors, wide cancellation and exact binary periods via integer oracle | follower_mapping_test.exs / S2-mapping, 4 tests |
| Moderate independent equations, 240 updates, offset/mapping/jitter tolerance | follower_loop_test.exs + follower_equation_oracle_helper.exs / S2-loop |
| dt=0, lock equality/clearing/default eight-sample chain, two-inlier jitter, exact holdover and reset, immutable snapshots | follower_loop_test.exs / S2-loop |
| Temporary unsupported paths, unrounded classification, precedence and valid continuation, feed overflow rollback | follower_loop_test.exs / S2-loop |
| Extreme finite gain combinations, cap/underflow, offset clamp/trim saturation, Imax threshold/error/jitter saturation | follower_loop_test.exs / S2-loop |
| First follower-to-pacer README workflow, failed transitions retain old states | follower_loop_test.exs / S2-loop, 9 tests total |
| Formatting, warnings-as-errors, full discovered tree | S2-tree, 55 tests |

T1–T3 unchanged; prior T4 is replaced, not left mid-list. Every new implementation
task and final whole-tree check must fail delivered stubs. All prior Stage 1
checks pass on those stubs. All tasks must pass the unchanged runner --check on
a private reference overlaid onto the ACTUAL Stage 1 implementation. Expectations
pin installed ExUnit stdout counts with no skips/exclusions. Checks launch no
coder/model or network calls. Different summary/runtime requires re-verification,
not weakening expectations. No test claims the entire follower is complete.

The moderate oracle implements literal equations independently, without production
helpers/structs; tolerance <=1ns error/mapping, <=1e-12 offset, <=2ns jitter.
Exact integer boundary fixtures do not use these tolerances. Extreme-gain checks
use hand-derived cap limits: x=0.5 for max bandwidth, x effectively zero for
subnormal bandwidth at these dt values; kp=1 only when capped x and max damping.
Expected offset is -0.25/1.001*0.001, tolerance 1e-15. Overflow-safe arithmetic
was experimentally checked before building these tests; test evidence is local
feasibility, not universal binary64 identity or arbitrary-distance accuracy.

## Protected inventory and gate

Protect every root/nested README, SPEC.md, PROMPT.md, tasks.json, scripts/loop.sh,
all test/support files, config/, mix.exs, .formatter.exs, .gitignore, LICENSE,
all Stage 1 modules (including cores), plus follower/config/observation/status/
state public seams. PROGRESS.md and follower_core.ex/new implementation helpers
remain writable. Inventory must be checked against JSON-decoded grep EREs.
Private references/evidence stay outside the coder checkout; coder must not read
outside implementations/references, including sibling repositories. Existing
.loop attempt state is preserved; new IDs are S2-prefixed and collision-free.

Stage 2 kit preparation/commit only now. STOP for parent review before launch.
Exact eventual commands/limits and original unchanged $25 constraint are in root
README; caps are owner-confirmed, not independently verified, total spend unknown.
No additional model calls, Stage 3, remotes or installs during this preparation.
Reference/fixture results are not coder implementation, complete parity, live
integration, performance, security or real-use acceptance. A contract blocker
must stop the run through the harness; progress notes alone cannot stop retries.
