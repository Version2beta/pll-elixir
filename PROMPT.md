Implement only the supplied benchmark task from these repository files.

1. Read approved README.md (Decisions and Throughput benchmark), subordinate
   current SPEC.md overlay, and PROGRESS.md. README wins. Historical stage
   write permissions do not apply. Contract gaps require stop/review, not guesses.
2. Edit only scripts/bench/runner.exs and append PROGRESS.md. Preserve exported
   names/signatures/doc comments. Private helpers within that file are local
   freedom; no new implementation files. All library APIs/algorithms are complete.
3. Never edit approved READMEs, SPEC, tests/support/fixtures, docs, project/config,
   formatter, license, gitignore, tasks, PROMPT, runner or complete files including
   scripts/bench/contract.exs and scripts/throughput.exs. Do not alter discovery.
4. No private reference or outside implementation reads (including siblings).
   If encountered, record and stop. Work only from this checkout. No dependencies,
   installs, network, secrets, environment config, VM tuning, workload concurrency,
   sleeps, subprocesses or library effects. Tool-only clocks/introspection/stdout
   are allowed exactly as README defines; synthetic library inputs only.
5. Run task tests, formatting (including explicit script inputs) and prior tests.
   Append three progress lines: task ID; change/evidence; remaining/blocker.
   New contract decisions block work; notes do not automatically stop the runner.
6. Stop. Do not commit, mark tasks done, discard user work, launch models or loops.
   The unchanged runner alone judges/commits/discards authorized attempts.
