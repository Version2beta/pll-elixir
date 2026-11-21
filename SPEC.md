# Stage 3 supporting contract — complete follower overlay

Subordinate to root README.md: Public API; Types/bounds/errors; Exact pacer;
Follower configuration; Follower state machine; Queries/rounding/holdover/reset;
Ownership/effects; Deterministic verification contract. README wins. New
contract gaps block work and require review, not implementation guesses.

## Scope and complete seams

Overlay actual Stage 2 at e3352c209a2ba75359018f579643d7debc265382. Preserve its
config/mapping/inlier arithmetic and all Stage 1 behavior. Complete windows,
outlier runs/steps, pending/rejected order, exact elapsed comparisons, atomic
flush rollback and reset histories. No dependencies or runtime I/O, clocks,
processes, credentials, implicit environment or adapters.

Only lib/pll/follower_history.ex and new private helper modules are coder work.
FollowerCore is now complete/protected: observe validates kind/scalars/order,
anchors first readings for every config, then delegates subsequent observations.
Its history_error/3 and history_inlier/4 adapters expose existing arithmetic
without promising new public library API. Follower's window/outlier fields are
private representation, not serialization or public mutation promises. Reset
already restores their defaults. Preserve names/specs/docs of supplied seams.

Implement FollowerHistory.observe/3's supplied signature. Return only a tagged
error on failure, never a replacement state. Validate input only through existing
core dispatch. Successful pending/rejected calls consume input order; failed
calls consume nothing. Window flush returns candidate error/status, then opens
trigger candidate against updated mapping. Half-open elapsed comparisons are
exact integers across signed limits. Candidate selection is strictly smaller
signed unrounded error; ties keep earlier. Compare unrounded phase-domain errors
to binary64 thresholds, including outlier-run distance to FIRST error, not last.
Step retains y, reanchors exactly and clears lock/jitter/outlier history. Inlier
run clearing occurs only after successful feed. Never mutate supplied snapshots.
Use complete stable arithmetic, including its tagged overflow and exact-anchor
mapping. No broad previous-stage refactor is allowed.

Historical Stage 2 unsupported transitions are intentionally superseded ONLY
for final windows/outliers/steps. Error.message(:unsupported) remains legacy
compatibility for historical/manual error values; completed observe never emits
that code. Supplied stubs still use it on unfinished paths; this is not a final
API promise. No final normative behavior is changed.

## Promise mapping and ordered tasks

| README promise | Protected checks | Task/count |
| --- | --- | --- |
| Rate factories/strings/envelopes | rate_test | T1 / 9 |
| Pacer/Span exact issuance/lazy snapshots/examples | pacer_test, span_test, readme_test | T2 / 21 |
| Trim and independent rational oracle | trim_test, model_test, rational_oracle_helper | T3 / 8 |
| All config defaults/validation/status/error strings | follower_config_test | S2-config / 4 |
| Signed mapping/ties/large anchors/wide cancellation | follower_mapping_test | S2-mapping / 4 |
| Prior inlier equations, dt=0, gain extremes, offset clamps, jitter, holdover, rollback, trim integration; temporary cases replaced by final classifications | follower_loop_test, follower_equation_oracle_helper | S3-history / 9 |
| Windows signed minima/ties/boundaries, post-flush candidate, first outlier reference/equality/run reset, steps keep rate, signed elapsed, overflow retry/reset, README table workflows | follower_history_test | S3-history / 7 |
| Independent integer histories over 1203 seeded readings; synthetic drift/jitter/jumps/outage and pacer steering over 1200 readings | follower_synthetic_test, history_oracle_helper | S3-history / 2 |
| Public pinned Go classifications/error/state/mapping/offset/trim/jitter and reset | go_corpus_test, go_corpus_helper, fixtures/go_public_v1.txt | S3-history / 1 |
| All three public executable README fences, plus final outlier path | readme_fences_test | S3-history / 1 |
| Whole tree, formatted and warnings-as-errors | all discovered tests | S3-tree / 66 |

T1–T3/S2-config/S2-mapping are retained. S2-loop's checks move into S3-history,
so the historical ID's attempt metadata cannot collide with final behavior work.
S2-tree is replaced by S3-tree, always last. No previous logs/state are deleted.
All 46 prior pacing/config/mapping checks pass stubs. Both new S3 tasks must fail
supplied unfinished paths and pass external reference via unchanged --check.
Counts pin installed ExUnit summary, no skipped/excluded tests. Runtime changes
require re-verification, not relaxed matching.

The independent integer history oracle uses period 1 ns and effectively zero
loop gains at bounded inputs, integer shifts and a literal error-run list; it
shares no production helpers. It isolates history transitions rather than
claiming full float-loop independence. Prior moderate equation and exact mapping
oracles remain in force. Synthetic clocks are deterministic, not live integration.
Corpus schema/provenance/tolerances are in docs/corpus.md. Classifications exact;
no tolerance may mask thresholds/ties. Finite fixtures do not prove universal
cross-language parity or arbitrary-distance accuracy.

## Protection and local freedom

Protect every README, all docs/contracts, tests/support/fixtures, generator,
runner, configs, Mix/formatter/.gitignore/LICENSE and every existing module
except FollowerHistory. Complete public structs/parser/arithmetic adapters are
protected. Private helper names/algorithms are local freedom; no public surface
change or dependencies. PROMPT prohibits private reference/external implementation
reads. Process permissions are not a security sandbox; isolate credentials before
any later authorized paid run.

Stage 3 preparation/verified-kit commit approved. Encoding and temporary offline
public-Go harness explicitly approved; source read-only, no dependency fetches.
No implementation loop before parent review. Original $25 total unchanged;
caps owner-confirmed, not independently verified, spend/remaining unknown.
Publication, broader runtime matrix and products/adapters remain deferred.
