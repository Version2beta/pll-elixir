Implement only the supplied task, from these repository files.

1. Read the approved README.md (including Decisions and stage limitations),
   subordinate SPEC.md, and PROGRESS.md. README authority wins; contradictions
   or newly required contract decisions are blockers, not implementation freedom.
2. Implement the task in the core stubs (lib/pll/*_core.ex) or new private helper
   files only. Preserve every supplied exported name, spec and doc comment.
   Keep passing behavior unless the task requires its extension. No follower,
   dependency, CLI, clock, process, environment, I/O or network functionality.
3. Never edit any approved README (including nested READMEs), SPEC.md, tests,
   oracle/fixtures, complete files, project/formatter configuration (including
   any config/ directory), LICENSE, .gitignore, tasks.json, PROMPT.md or
   scripts/loop.sh. They are protected. PROGRESS.md is writable. Do not change
   protection or test discovery.
4. Do not seek, read, copy or adapt any private reference or any external prior
   implementation of this library. The only outside source you may read is the
   authorized Go source at ../pll, read-only; do not modify it. Otherwise work
   only from this repository's files. If you have encountered such material,
   record that in PROGRESS.md and stop.
5. Private helpers, exact integer algorithms and period reduction are local
   freedoms within the protected types/seams; never materialize huge spans.
   Run the task test, formatting and relevant earlier tests. Do not install.
6. Append three lines to PROGRESS.md: task id; what changed; what remains or
   blocks you. For a new contract gap, record it and stop WITHOUT inventing an
   answer. Notes do not automatically stop the runner; operator review is needed.
7. Stop. Do not commit, mark tasks done, discard user work, launch another
   model or implementation loop. The runner alone judges/commits authorized
   passing attempts and discards only attempt-owned failed changes.
