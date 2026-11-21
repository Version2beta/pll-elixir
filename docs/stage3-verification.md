# Stage 3 kit evidence — parent review gate

Prepared on kit/stage3-follower-parity over ACTUAL runner-written Stage 2
`e3352c209a2ba75359018f579643d7debc265382`, not a prior private-reference substitute.
Initial clean branch/HEAD matched the expected baseline. Initial baseline format,
warnings-as-errors compile, 55 tests and all seven Stage 2 runner tasks passed.
Source sibling stayed clean/read-only at 971282632129110794c9d6edd22026e9de2359be.
Owner explicitly approved line-oriented decimal/hex-binary64 encoding and the
separate offline public-Go harness before either was finalized/executed. The
initial preparation checkpoint was paused pending that decision; now resumed.
No models/coders, installs, remotes, publication or later kits were invoked.

## Overlay ownership and intentional supersession

Retains actual prior arithmetic. Only core changes: first reading now anchors
regardless of window, validated subsequent readings dispatch to new private
FollowerHistory, and complete phase-error/inlier adapters. Core is now protected
in full. Public Follower gets private window/outlier defaults and final-contract
doc comments. Its signatures and all other public structs/parsers remain protected.
Only FollowerHistory and new private helpers are implementation work.

Two Stage 2 loop cases changed solely where temporary unsupported was expected:
final window anchors and rejected transitions replace errors, with input/order/
threshold/snapshot assertions retained or strengthened. Error.message unsupported
compatibility remains historical; completed observe must not emit it. Nine loop
tests retained, including all non-temporary promises. S2-loop task checks are
incorporated into S3-history, preventing old attempt-ID collisions. S2-tree is
replaced by S3-tree. No old logs/attempt metadata deleted.

## Current checks

- Supplied stubs: format and warnings-as-errors compile pass; 53/66 tests pass,
  13 expected unfinished-path failures. All 46 pacing/config/mapping tests pass.
  The seven original loop tests without temporary-path assertions also pass.
- Unchanged runner --check: T1 9, T2 21, T3 8, S2-config 4, S2-mapping 4 pass
  supplied stubs; BOTH new tasks S3-history and S3-tree fail them.
- External private reference in /tmp/pll-s3-reference.ifHtRB overlays this actual
  build by replacing ONLY FollowerHistory. Format, compile, 66 tests and every
  task pass unchanged runner --check (S3-history 20; S3-tree 66).
- All three alias-based public README fences are extracted/executed, not doctests;
  remaining table examples covered by loop/history/mapping suites. Public calls
  exercise snapshots, errors and trim/pacer integration; no private runtime test
  shortcuts or live clocks.
- Corpus 172 lines / 159 records / six scenarios. Generation repeated and cmp
  identical after gofmt; tests replay checked-in bytes without Go. All statuses
  present: 125 accepted, 7 anchored, 8 pending, 6 rejected, 1 stepped successful
  observe records; 3 order and 1 overflow observe errors. See corpus.md for exact
  schema/provenance and numerical acceptance. Parent review of corpus remains
  part of this gate, not presumed approved merely from format approval.
- Synthetic loop estimates are also compared against the independent literal
  equation model extended with a first-error run list (exact statuses, <=1 ns
  error/mapping, <=1e-12 offset), not only rate-bound invariants.
- Three independent history-reference mutations are caught: rolling rather than
  first outlier reference (6/7 history pass), replacing candidate on tie (4/7),
  minimum absolute instead of signed candidate (6/7). Unmutated reference passes.
- Runner cmp byte-identical to skill source. Inherited disposable mechanics suite:
  26 cases pass, all 26 deliberate regressions caught; no model calls.
- Decoded protection ERE inventory covers all README/docs/tests/fixtures/generator,
  complete modules, project settings and automatically protected kit/runner paths.
  PROGRESS remains writable; only history/new private modules are unprotected.

## Evidence files outside coder checkout

/tmp/pll-s3-reference-judge.out — passing reference runner output.
/tmp/pll-s3-stub-judge.out — prior passes and two expected S3 failures.
/tmp/pll-s3-stubs-final.out — 53/66 with 13 expected failures.
/tmp/pll-s3-mechanics.out — 26 mechanics cases and regression catches.
/tmp/pll-s3-mutation-{rolling-first,candidate-tie,absolute-candidate}.out.
/tmp/pll-corpus-repeat.txt — repeat generation compared with protected fixture.
Private reference stays outside coder checkout; PROMPT forbids reading it or any
external implementation/sibling source during coder attempts.

## Limits and next gate

Feasibility on Elixir 1.20.4 / OTP29, not the future coder implementation. Finite
Go fixtures and a frozen-gain independent history model do not prove universal
parity. Synthetic integration is deterministic, not live device/network testing.
No broader runtime matrix, performance/security/release/live-model/owner-use
acceptance. Runtime effects are constrained by library design/tests, not a process
sandbox. Provider caps owner-confirmed only; spend/remaining unknown, original
$25 total unchanged, no added authorization. Parent reviews this complete kit and
corpus before any implementation loop. No later kits/install/remotes/publication.
