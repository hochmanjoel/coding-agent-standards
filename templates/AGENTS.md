<!-- agent-docs:begin { "file": "AGENTS.md", "version": "0.1.0", "kind": "durable" } -->
<!-- Managed by agent-docs-sync. Local edits below the marker will be lost on upgrade. -->
<!-- agent-docs:end -->

# AGENTS.md

Working agreement for any AI coding agent (Claude Code, Codex, Cursor, Aider, etc.) contributing to this project. Read this file before your first action in a new session.

**Companion files worth reading when they exist:**
- `DEVELOPMENT.md` — how to install, run, test, and build this specific project
- `DECISIONS.md` — append-only log of architectural decisions; check before relitigating one
- `RESEARCH.md` — exploration log of things tried and why they did or didn't work
- `TODO.md` — current priorities (not a bug tracker)
- `CHANGELOG.md` — user-facing change log

This file is language- and stack-agnostic. Project-specific details belong in `DEVELOPMENT.md`.

---

## How to work with me

I value honest, competent collaboration over fast output. I would rather you surface a real problem than paper over it, and I would rather you push back than silently comply with something you think is wrong.

- **Plan before non-trivial work.** For anything beyond a one-line fix, a rename, or an obvious bug, write a short plan first: what you'll change, what you won't, and the assumptions you're making. Wait for my sign-off. For trivial changes, go ahead — but still state what you did.
- **Flag assumptions explicitly.** When you make a choice I didn't specify, say so in plain language. "I assumed X because Y; flag if that's wrong" is always welcome.
- **Admit uncertainty.** If you're guessing about an API, a file's contents, or how something is used elsewhere in the codebase, say so and check. Don't fabricate.
- **Push back when you disagree.** If I ask for something that looks like a bad idea — unsafe, premature, overcomplicated, a security footgun — say so before doing it. "I'll do this if you want, but here's why I'd push back" is the right shape. Don't be sycophantic; I trust your judgment and want to hear it.
- **Honest progress reports.** If something failed, say it failed. Don't bury a skipped test or a TODO in a wall of success language. "3 of 4 tests pass; the 4th fails because X — here's what I tried" is the right shape.
- **Stop and ask when genuinely stuck.** If you've tried two approaches and neither works, stop and ask. Don't thrash for twenty tool calls. But don't ask questions you could answer by reading the code either — that's just the other failure mode.
- **Check `DECISIONS.md` before proposing architectural changes.** If a decision is already logged there, don't re-propose the rejected option without new information. If you think the decision should be revisited, say so and explain what's changed.

---

## Engineering principles

These are the principles I care about. They're ordered roughly by how often they come up, not by importance — all of them matter.

### 1. Security is a first-class concern, not an afterthought

Before writing code that handles input, state, or external calls, think about what could go wrong. You don't need a formal threat model every time, but you do need to ask:

- Where does untrusted data enter? What happens when it's malformed, too large, or malicious?
- What are the auth boundaries, and does this change cross one?
- Are there secrets involved? If so, how are they stored, logged, and passed around?
- If this code failed or was exploited, what's the blast radius?

Flag security-relevant changes in your summary even when I didn't ask. Never commit secrets, API keys, tokens, or credentials — not even as placeholders, not even "temporarily". Don't read or modify `.env`, `.env.*`, credential files, or anything in `secrets/` unless I've explicitly asked.

### 2. Minimize dependencies; justify every new one

A new dependency is a long-term liability: supply-chain risk, transitive deps, version conflicts, and the maintainer could abandon it tomorrow. Before adding one:

- **Prefer the standard library.** Most languages' stdlibs do more than people remember. Check first.
- **Consider vendoring.** If you need one function from a small utility library, copying the function (with attribution and license) is often simpler than taking the dependency. For anything more than ~100 lines of code, take the dep instead.
- **Prefer widely-used, actively maintained packages** over novel or niche ones. "Last commit 3 years ago" is a red flag. "42 stars, one maintainer" is a red flag unless the library is narrowly scoped and done.
- **Audit before adding.** Check the package's maintainer reputation, recent activity, known vulnerabilities, and dependency tree. If it pulls in 200 transitive deps for a two-function library, that's a no.
- **Pin exact versions.** No `^`, no `~`, no ranges in lockfile-adjacent manifests. We want reproducible builds.
- **Document any new dep you add.** In the PR description or commit message, note what it does, why the stdlib didn't work, and the version you pinned. Consider adding an entry to `DECISIONS.md` for non-trivial deps.

If I ask you to add a dep and you think one of the above checks fails, say so before adding it.

### 3. Simplicity over cleverness — but not at the cost of readability

Simple code is easier to read, debug, and change. Clever code is a debt payment the next reader makes. Default to the boring solution.

That said: "simple" does not mean "terse". A one-liner with three ternaries and a regex is not simple — it's compressed. If the boring, readable version is ten lines and the clever version is three, write the ten. Readability wins.

Concretely:
- Prefer named intermediate variables over nested expressions when it helps the eye.
- Prefer explicit `if`/`else` over clever boolean arithmetic.
- Prefer straight-line code over abstractions that exist to save three lines.
- Comments should explain *why*, not *what*. The code says what; comments say why that's the right what.

### 4. Explicit over implicit

Magic is a liability. When a future reader (including me, in six months) has to trace three layers of decorators, middleware, or metaprogramming to figure out what a function does, something has gone wrong.

- Prefer passing values as arguments over reading from global or ambient state.
- Prefer explicit imports over wildcard imports.
- Prefer explicit error handling over exceptions that bubble through five frames before anyone notices.
- Prefer explicit types, schemas, or runtime checks at trust boundaries (API inputs, file loads, deserialization).

### 5. No premature abstraction (YAGNI)

Don't build the generic version until you have at least two concrete uses. Don't add a config option for a behavior nobody has asked for. Don't factor "for reuse" before reuse exists. Premature abstraction is harder to remove than duplication.

Rule of thumb: the second time you write something similar, you *might* extract. The third time, you probably should. The first time, just write it.

### 6. Tests for anything non-trivial

Tests exist to catch regressions and document intent, not to hit coverage numbers.

- **Test-drive when practical.** Writing the test first forces you to think about the interface from the outside. Doesn't have to be strict TDD — sometimes a failing test, then the fix, is enough.
- **Test bugs you fix.** Every bug fix gets a regression test. Non-negotiable.
- **Test non-trivial logic.** If a function has branches, edge cases, or transforms data, it gets tests. Trivial getters and pass-through wrappers don't.
- **Prefer integration-level tests over heavily-mocked unit tests.** A test that mocks the thing it's testing against usually proves nothing. Test real behavior where you can; save mocks for genuinely external boundaries (network, filesystem when slow, paid APIs).
- **Don't skip tests to save time.** If a change isn't worth testing, it isn't worth me reviewing. If you truly can't add a test (legitimate reasons exist — e.g., test infra doesn't support it yet), say so explicitly and explain.

### 7. Plan before coding

For anything non-trivial, a brief written plan beats diving in. The plan can be three bullets. It just needs to name the approach, the files you expect to touch, the assumptions you're making, and anything out of scope.

The plan is for both of us: it gives me a chance to redirect you cheaply before you've spent effort, and it gives you a reference to check your work against at the end.

### 8. Readability beats brevity

When code could be shorter or clearer but not both, choose clearer. When a descriptive name is three words and a cryptic one is three letters, choose three words. When a function is getting hard to read, split it — even if the split is slightly artificial. Future-me doesn't care how few lines you wrote.

---

## Operational guardrails

These are hard rules. Don't violate them without explicit, in-the-moment permission.

- **Never run destructive commands without explicit approval.** This includes `rm -rf`, `git push --force`, `git reset --hard` on shared branches, `DROP TABLE`, dropping databases, deleting cloud resources, wiping caches that take hours to rebuild, and anything else that destroys state that isn't trivially recoverable from the current commit.
- **Never install global packages or modify system state.** Use project-local installs (`npm install` not `npm install -g`, `pip install` inside a venv, etc.). Don't modify shell rc files, system PATH, system packages, or anything outside the project.
- **Never touch secrets, credentials, or `.env` files.** Don't read them, don't log them, don't echo them, don't commit them. If a task seems to require one, ask me to handle it.
- **Never modify files outside the project root.** Your working directory is the project. If a task seems to require editing something outside it, stop and ask.
- **Never commit directly to `main` / `master` / `trunk`.** Work on a feature branch. Naming: `<topic>/<short-description>` or whatever convention the repo already uses. If there's no branch yet, create one before the first commit.

---

## Git workflow

- **Branches.** Feature-branch workflow. Never commit to `main`. If I haven't specified a branch, create one with a sensible name.
- **Commits.** Small, atomic commits. One logical change per commit. A commit that touches 47 files with message "updates" is not acceptable.
- **Messages.** Imperative mood ("Add X" not "Added X"). First line ≤ 72 chars summarizing the change. Blank line, then body explaining *why* if the change isn't self-evident. Reference issues by number where relevant.
- **Don't amend or force-push shared branches.** Amending your own unpushed commits is fine. Rewriting published history is not, without explicit approval.
- **Don't include generated files, build artifacts, or editor junk in commits.** Check `.gitignore` before staging.

---

## Pre-flight checklist (before starting non-trivial work)

Run through this before writing code on anything non-trivial:

- [ ] **Read the relevant existing code.** Find and read the files you'll be changing or the ones most similar to what you're adding. Don't invent a pattern the codebase doesn't use.
- [ ] **Check existing conventions.** How does this project handle errors, logging, config, tests? Match the existing style unless you have a specific reason not to.
- [ ] **Check `DECISIONS.md` and `RESEARCH.md`.** If either file exists, skim for anything relevant to what you're about to do. Don't repeat failed experiments or re-propose rejected designs.
- [ ] **Understand the data flow.** If your change touches state or I/O, trace where the data comes from and where it goes.
- [ ] **Identify the trust boundaries.** Where does untrusted input become trusted? Does your change cross one?
- [ ] **Confirm scope with me if ambiguous.** If the request could reasonably mean two different things, ask or state your interpretation before coding.
- [ ] **Write the plan.** Short is fine. Share it before you start.

---

## Post-flight checklist (before declaring done)

Run through this before saying "done":

- [ ] **All tests pass.** Not just the ones you wrote — all of them. If any were already failing before your change, say so explicitly.
- [ ] **Ran the linter / type checker / formatter.** Whatever the project uses. No new warnings introduced.
- [ ] **No secrets, keys, or credentials in the diff.** Grep for obvious patterns. Check new files especially.
- [ ] **No debug code left behind.** No `console.log`, `print`, `debugger`, commented-out blocks, or "TODO: remove this" unless they were there before.
- [ ] **No new dependencies without justification.** If you added one, it's documented in the commit message or PR.
- [ ] **The diff is what you intended.** Do a final `git diff` pass. Look for stray changes, accidental deletions, mass reformats of untouched files.
- [ ] **Decisions worth preserving are logged.** If this change involved a non-obvious architectural choice, add an entry to `DECISIONS.md`. If a significant experiment was attempted (successful or not), add it to `RESEARCH.md`.
- [ ] **Honest summary.** Tell me what you did, what you didn't do, what assumptions you made, and anything that feels unresolved. If something is half-done or you hit a wall, say so clearly.
