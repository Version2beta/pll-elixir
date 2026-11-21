# Public Go corpus v1

Encoding and temporary offline generation were explicitly approved before execution.
Source: github.com/version2beta/pll revision
971282632129110794c9d6edd22026e9de2359be, local read-only ../pll. Generator imports
only the public package, never internal packages/private members. Generated with
Go 1.27.2 darwin/arm64; no network, installs or dependency fetches. Local replace
points at the pinned clean source; all build-module writes occur in mktemp space.
Go build caches outside that source may be written. Tests never need Go.

Reproduce from project root with installed Go and the pinned clean sibling:

```sh
bash scripts/corpus/generate.sh /absolute/path/to/pinned-source > /tmp/pll-public.txt
cmp test/fixtures/go_public_v1.txt /tmp/pll-public.txt
```

Schema: ASCII, single spaces, LF, decimal integers (no exponent), finite binary64
as 16 lowercase big-endian hexadecimal digits. Header `PLL-CORPUS 1 REVISION`.
`C name rate_num window_ns bandwidth_bits damping_bits outlier_threshold_ns`
starts a fresh default config with denominator 1 and those overrides. `END` closes
it. Records:

`OP local remote result status error_ns local_result local_value remote_result remote_value offset_bits trim jitter state`

OP is O observe, Q query-only, R reset then query. Error calls retain old state.
Unused/error values are zero, status none when no successful observation.
Result codes ok/order/overflow/not_anchored. Queries always follow the operation
using its same arguments; lifecycle queries use local. Floats encode output
estimates. Non-clean fixtures require exact numerical offset equality on this
finite dataset; they do not promise universal bit-identical cross-runtime results.

172 lines: header, 6 configs, 159 operation/query/reset records, 6 END lines.
Scenarios clean/window/jump/fraction/signed/overflow include all five statuses,
order and feed-overflow errors with continuation, unanchored queries, reset,
window ties/boundaries, signed extremes and fractional threshold decisions.
Generator and strict parser/schema/exact fixture are protected.

Inspection: clean fixture uses approved moderate tolerances <=1 ns for observation
and mapping, <=1e-12 offset, <=2 ns jitter. Trim is exact for every fixture,
including clean: observed reference replay matches every public-Go trim result.
Other scenarios require exact
integers/float offset, including fractional classifications and signed boundaries.
Statuses, error codes and lifecycle state are EXACT for all records. No tolerance
relaxes a threshold or boundary. Both generated runs compare byte-for-byte.
The six finite scenarios complement independent models, not universal parity.
