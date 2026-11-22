# 0.1.0 release candidate

Registry publication is reserved for the owner. No upload has been performed.

## Local evidence

All 83 tests pass on Elixir 1.20.4 / OTP 29; format and warnings-as-errors
compilation pass. The actual Hex archive was unpacked, every file compared
against source, and all three executable README API examples run from a separate
Mix consumer depending on the unpacked archive, not the checkout.

Compatibility CI must pass on the exact candidate before publication. GitHub
reviews and checks are separate from local validation; no independent human
approval is asserted here. Core source, tests, numerical tolerances and corpus
are unchanged. Previous README is retained in pre-release-readme.md as historical
context, not current authority or launch instructions.

## Owner publication

Artifacts and logs are outside Git at /tmp/pll-release-010; temporary storage may
be lost. Verify SHA-256 values in SHA256SUMS and source identity before upload.
Do not rebuild from an edited checkout or replace an existing published version.

Authenticate with mix hex.user auth, confirm mix hex.user whoami, then from
the clean, validated release checkout run mix hex.publish package --dry-run
followed by mix hex.publish package. Package-only publication does not publish
HexDocs. Hex rebuilds the package: stop if the preview differs from the inspected
archive. Do not use --replace or --yes.

After publication, verify official registry metadata and fresh consumer installs,
imports/examples and any installed CLI. Only then report registry release success.
Version tags must identify the final validated commit; never move a public tag.
