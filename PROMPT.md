Implement only the supplied pacing task from these repository files.
1. Read approved README.md Decisions/Local real-time pacing demonstration/Pacing kit
   operation, current SPEC.md overlay and PROGRESS.md. README wins; gaps require stop.
2. Edit only scripts/pacing/runner.exs and append PROGRESS.md. Preserve exported
   signatures/doc comments. Private helpers inside that file only. Use public PLL
   API; never inspect private state, reuse stale immutable states or skip backlog.
3. Never edit READMEs, SPEC, docs, tests/fixtures/support, library, benchmark,
   project/config, tasks, PROMPT, gitignore, formatter, license, loop or complete
   contract/runtime/entrypoint. No external implementation or sibling reads.
4. No deps/installs/secrets/environment configuration/remotes/publication/VM tuning,
   models/subprocesses, ticker/search or remote UDP. Work through injected seams;
   tests require no network/live waits. Do not run live demonstration during coding.
5. Run task tests, prior tests and format including scripts. Append three lines:
   task ID; changes/evidence; remaining/blocker. New decisions block work for review;
   progress notes do not automatically halt retries. Do not improvise contract.
6. Stop. Do not commit, mark tasks done, discard changes, launch loops/models or
   change discovery. Runner alone judges/commits/discards scoped attempts.
