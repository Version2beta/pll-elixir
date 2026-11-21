Implement only the supplied task, from these repository files.

1. Read the approved README.md (including Decisions and stage limitations),
   subordinate SPEC.md, and PROGRESS.md. README authority wins; contradictions
   or newly required contract decisions are blockers, not implementation freedom.
2. Implement the task in lib/pll/follower_history.ex or new private helper files only.
   All prior source including FollowerCore is complete and protected; do not refactor it. Preserve every supplied exported name, spec and doc comment.
   Keep passing behavior unless the task requires its extension. No
   dependency, CLI, clock, process, environment, I/O or network functionality.
3. Never edit any approved README (including nested READMEs), SPEC.md, tests,
   oracle/fixtures, complete files, project/formatter configuration (including
   any config/ directory), LICENSE, .gitignore, tasks.json, PROMPT.md or
   scripts/loop.sh. They are protected. PROGRESS.md is writable. Do not change
   protection or test discovery.
4. Do not seek, read, copy or adapt any private reference or any external prior
   implementation of this library. Work only from this checkout. Do not read private references or other
   implementations outside this checkout (including sibling repositories).
   If you have encountered such material,
   record that in PROGRESS.md and stop.
5. Private helpers and algorithms are local
   freedoms within the protected types/seams; never materialize huge spans.
   Run the task test, formatting and relevant earlier tests. Do not install.
6. Append three lines to PROGRESS.md: task id; what changed; what remains or
   blocks you. For a new contract gap, record it and stop WITHOUT inventing an
   answer. Notes do not automatically stop the runner; operator review is needed.
7. Stop. Do not commit, mark tasks done, discard user work, launch another
   model or implementation loop. The runner alone judges/commits authorized
   passing attempts and discards only attempt-owned failed changes.
