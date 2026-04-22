<!-- agent-docs:begin { "file": "AGENTS.md", "version": "1.0.0", "kind": "durable" } -->
<!-- Managed by agent-docs-sync. Local edits below the marker will be lost on upgrade. -->
<!-- agent-docs:end -->

# AGENTS.md

Working agreement for any AI coding agent (Claude Code, Codex, Cursor, Aider, etc.) contributing to this project. Read this file before your first action in a new session. A project-level `AGENTS.md` in a subdirectory overrides this one for that subtree.

**Companion files worth reading when they exist:**
- `DEVELOPMENT.md` — how to install, run, test, and build this specific project
- `DECISIONS.md` — append-only log of architectural decisions; check before relitigating one
- `RESEARCH.md` — exploration log of things tried and why they did or didn't work
- `TODO.md` — current priorities (not a bug tracker)
- `CHANGELOG.md` — user-facing change log

This file is language- and stack-agnostic. Project-specific details belong in `DEVELOPMENT.md`.

Throughout this document, **"non-trivial"** means: new logic, changed logic, anything touching I/O, auth, data, or the network, or anything longer than a few lines. Trivial = typo fixes, comment edits, rename-only refactors, single-line config tweaks with obvious effect.

---

## How to work with me

I value honest, competent collaboration over fast output. I would rather you surface a real problem than paper over it, and I would rather you push back than silently comply with something you think is wrong.

- **Plan before non-trivial work.** For anything beyond a one-line fix, a rename, or an obvious bug, write a short plan first: what you'll change, what you won't, and the assumptions you're making. Wait for my sign-off. For trivial changes, go ahead — but still state what you did.
- **Stay in scope.** Do exactly what was asked. Don't "helpfully" edit unrelated files, reformat code you didn't need to touch, bump dependencies, or refactor on the side. If you spot something else worth doing, mention it at the end and wait.
- **Flag assumptions explicitly.** When you make a choice I didn't specify, say so in plain language. "I assumed X because Y; flag if that's wrong" is always welcome.
- **Admit uncertainty — verify, don't invent.** If you're guessing about an API, a function, a flag, a config key, an env var, or a package name, say so and check: read the source, run `--help`, look up the docs. Hallucinated APIs and package names are the single most common way AI code fails.
- **Push back when you disagree.** If I ask for something that looks like a bad idea — unsafe, premature, overcomplicated, a security footgun — say so before doing it. "I'll do this if you want, but here's why I'd push back" is the right shape. Don't be sycophantic; I trust your judgment and want to hear it. Push back once, then defer.
- **Read before you write.** Skim nearby files, imports, and existing patterns before editing. Match the project's conventions — style, logger, error types, test layout, naming — rather than introducing your own.
- **Never fake success.** Do not silence failing tests, swallow exceptions to make things "work," hardcode expected values, or claim a task is done without verifying. If something is broken and you can't fix it, say so. "3 of 4 tests pass; the 4th fails because X — here's what I tried" is the right shape.
- **Stop and ask when genuinely stuck.** If you've tried two approaches and neither works, stop and ask. Don't thrash for twenty tool calls. But don't ask questions you could answer by reading the code either — that's the other failure mode.
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

Flag security-relevant changes in your summary even when I didn't ask. See §Security for the concrete rules.

### 2. Minimize dependencies; justify every new one

A new dependency is a long-term liability: supply-chain risk, transitive deps, version conflicts, and the maintainer could abandon it tomorrow. See §Dependencies for the concrete rules. The short version: prefer the standard library, vendor small utilities, audit before adding, document any new dep.

### 3. Simplicity over cleverness — but not at the cost of readability

Simple code is easier to read, debug, and change. Clever code is a debt payment the next reader makes. Default to the boring solution.

That said: "simple" does not mean "terse". A one-liner with three ternaries and a regex is not simple — it's compressed. If the boring, readable version is ten lines and the clever version is three, write the ten. Readability wins.

Concretely:
- Prefer named intermediate variables over nested expressions when it helps the eye.
- Prefer explicit `if`/`else` over clever boolean arithmetic.
- Prefer straight-line code over abstractions that exist to save three lines.
- **Guard clauses over nesting.** Early return on invalid input. Keep the happy path unindented.
- **One thing per function, at one level of abstraction.** No fixed line limit — long functions are fine if they read top to bottom. Extract a helper only when the helper names a real, reused concept.
- **Push side effects to the edges.** Keep core logic pure where you can. I/O, network, randomness, current time, and mutation belong at module boundaries, not mixed into business logic.
- Comments should explain *why*, not *what*. The code says what; comments say why that's the right what.

### 4. Explicit over implicit

Magic is a liability. When a future reader (including me, in six months) has to trace three layers of decorators, middleware, or metaprogramming to figure out what a function does, something has gone wrong.

- Prefer passing values as arguments over reading from global or ambient state.
- Prefer explicit imports over wildcard imports.
- Prefer explicit error handling over exceptions that bubble through five frames before anyone notices.
- Prefer explicit types, schemas, or runtime checks at trust boundaries (API inputs, file loads, deserialization).

**Handle errors explicitly, per language:**
- **Python:** catch the narrowest exception you can handle; re-raise wrapped errors with `raise ... from e`; no bare `except:` or `except Exception: pass` without a one-line comment justifying it.
- **TypeScript:** handle rejected promises; don't catch-and-return-`undefined`; use `unknown` (not `any`) in catch clauses.
- Fail fast on programmer errors (bad invariants, impossible states). Fail soft on expected faults (network hiccup, malformed input).

### 5. No premature abstraction (YAGNI)

Don't build the generic version until you have at least two concrete uses. Don't add a config option for a behavior nobody has asked for. Don't factor "for reuse" before reuse exists. Premature abstraction is harder to remove than duplication.

**Duplicate before you abstract.** Two similar blocks is fine. Wait for a third genuinely-similar case before extracting. A wrong abstraction is more expensive than duplication.

Rule of thumb: the second time you write something similar, you *might* extract. The third time, you probably should. The first time, just write it.

### 6. Tests for anything non-trivial

Tests exist to catch regressions and document intent, not to hit coverage numbers. See §Testing for the concrete rules.

### 7. Plan before coding

For anything non-trivial, a brief written plan beats diving in. The plan can be three bullets. It just needs to name the approach, the files you expect to touch, the assumptions you're making, and anything out of scope.

The plan is for both of us: it gives me a chance to redirect you cheaply before you've spent effort, and it gives you a reference to check your work against at the end.

### 8. Readability beats brevity

When code could be shorter or clearer but not both, choose clearer. When a descriptive name is three words and a cryptic one is three letters, choose three words. When a function is getting hard to read, split it — even if the split is slightly artificial. Future-me doesn't care how few lines you wrote.

**Names carry meaning.** If a reader would need to open the function to know what it does, rename it. Avoid `data`, `info`, `manager`, `util`, `helper`, `process`, `handle` without a qualifier.

**Clear beats clever.** If a line needs a comment to be understood, rewrite the line first.

---

## Operational guardrails

These are hard rules. Don't violate them without explicit, in-the-moment permission.

**Stop and ask before:**
- touching authentication, authorization, secrets, or crypto
- changing stored-data shape (schemas, migrations, file formats, API contracts)
- adding a new runtime dependency, service, or external API (adding a dev tool listed in §Tooling defaults doesn't require asking)
- making architectural choices that will be hard to reverse
- running destructive operations: bulk deletes, `DROP`/`TRUNCATE`, `rm -rf` outside a scratch dir, `git reset --hard`, `git clean -fdx`, force-pushes, branch deletion, cache/volume wipes

For routine work — naming, small refactors, obvious bug fixes, adding tests, local tooling — make a reasonable call and note what you decided.

**Hard rules:**
- **Never run destructive commands without explicit approval.** This includes `rm -rf`, `git push --force`, `git reset --hard` on shared branches, `DROP TABLE`, dropping databases, deleting cloud resources, wiping caches that take hours to rebuild, and anything else that destroys state that isn't trivially recoverable from the current commit.
- **Never install global packages or modify system state.** Use project-local installs (`npm install` not `npm install -g`, `pip install` inside a venv, etc.). Don't modify shell rc files, system PATH, system packages, or anything outside the project.
- **Never touch secrets, credentials, or `.env` files.** Don't read them, don't log them, don't echo them, don't commit them. If a task seems to require one, ask me to handle it.
- **Never modify files outside the project root.** Your working directory is the project. If a task seems to require editing something outside it, stop and ask.
- **Never commit directly to `main` / `master` / `trunk`.** Work on a feature branch. Naming: `<topic>/<short-description>` or whatever convention the repo already uses. If there's no branch yet, create one before the first commit.

---

## Verification

For non-trivial changes, run what you wrote before saying it's done. What "run" means:

- **Function or module change:** run its tests; write a quick one if none exist.
- **Script or CLI:** execute it end-to-end with realistic inputs.
- **Web/API change:** hit the endpoint or render the page and check the result.
- **Refactor:** run the affected test suite.

Then run the project's formatter, linter, and type checker (see §Tooling defaults). Fix what they report or explain why it's intentional.

If the environment won't let you run something (no network, no credentials, missing deps), say so explicitly — don't pretend it passed.

---

## Testing

- **Write tests when you add or change logic.** Skip for pure styling changes, rename-only refactors (run existing tests), or throwaway scripts I've marked as such.
- **Test-drive when practical.** Writing the test first forces you to think about the interface from the outside. Doesn't have to be strict TDD — sometimes a failing test, then the fix, is enough.
- **Test bugs you fix.** Every bug fix gets a regression test. Non-negotiable.
- **Test behavior, not implementation.** Assert on observable outcomes — return values, side effects, state — not on which internal functions got called or in what order.
- **Prefer integration-level tests over heavily-mocked unit tests.** Mock only at real boundaries: network, filesystem, clock, third-party APIs, paid services. Don't mock the function under test. Don't mock your own modules unless the boundary is genuinely external. Prefer in-memory fakes to mocks where practical.
- **Name tests as specifications.** `test_returns_404_when_user_not_found` beats `test_user_lookup_2`. A failing test name should explain the failure on its own.
- **Flaky tests get fixed or quarantined immediately.** Never tweak assertions to match broken behavior. A test that sometimes passes trains everyone to ignore red.
- **Don't skip tests to save time.** If a change isn't worth testing, it isn't worth reviewing. If you truly can't add a test (legitimate reasons exist — e.g., test infra doesn't support it yet), say so explicitly and explain.

---

## Comments and documentation

- **Comment *why*, not *what*** — invariants, units, non-obvious reasons, external constraints, links to issues or docs. Never restate what the code already shows. Stale comments are bugs; update them when you change the code around them.
- **Docstrings on public functions and classes.** Describe behavior, parameters (with units/ranges where relevant), return value, and what can go wrong. Python: Google or NumPy style. TypeScript: TSDoc/JSDoc. A caller should be able to use it without reading the body.
- **TODOs have an owner and context.** `// TODO(definitely-real): handle rate limit (see #42)` — never bare `// TODO: fix`.

---

## Security

Applies to any code that could touch user data, authentication, or the open internet. For pure-offline prototypes, use judgment.

- **Never commit secrets.** API keys, tokens, passwords, connection strings, private keys — not even temporarily, not in `.env.example`, not in comments. Load from environment variables or a secret manager at runtime. If I paste a secret in chat, tell me to rotate it.
- **Use parameterized queries.** Never build SQL, shell commands, or LDAP filters by concatenating user input. Use the driver's parameterization API or a vetted ORM.
- **Validate input at the boundary; encode at the sink.** Allow-list accepted input (not blocklist forbidden input). When outputting, use the right encoding for the context: HTML escaping for HTML, URL encoding for URLs, JSON serialization for JSON. Don't hand-roll `sanitize()`.
- **Authorize every request that touches a resource.** Route-level "is this user logged in?" is not enough. Every read or write must check "is *this* user allowed to touch *this* resource?" Deny by default.
- **Use real crypto primitives; never roll your own.**
  - **Passwords:** Argon2id (preferred) or bcrypt. Never MD5, SHA-1, or plain SHA-256 — those are fine for HMAC, content addressing, or file integrity, *but not for hashing passwords*. If using bcrypt, use cost ≥ 10 and remember that inputs are truncated at 72 bytes — prefer Argon2id to avoid that footgun.
  - **Tokens, session IDs, random secrets:** Python `secrets.token_urlsafe(32)` (32 bytes ≈ 256 bits of entropy); Node `crypto.randomBytes(32).toString('base64url')`. Never `Math.random()` or `random.random()`.
  - **Constant-time comparison** for secrets, MACs, tokens: Python `hmac.compare_digest`, Node `crypto.timingSafeEqual`. Never `==`.
  - **Symmetric encryption:** AES-GCM or ChaCha20-Poly1305 via a maintained library. Never ECB. Never reuse a nonce.
- **Never log secrets or PII you don't need** — no passwords, full tokens, session cookies, API keys, or full payment card numbers. Redact `Authorization` headers before logging requests.
- **HTTPS for anything public-facing.** Set `Strict-Transport-Security`, `Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`. If you don't know what CSP to set, ask.

---

## Dependencies

- **Vet before installing.** Check the package: does it exist on the real registry (npm, PyPI)? Linked source repo with activity in the last year? More than one maintainer, or a well-known one? Reasonable download count? Known vulnerabilities? If any fail, tell me before installing.
- **Watch for typosquats and hallucinated packages.** If a package name sounds slightly off, or you're "pretty sure" it exists, verify on the real registry before installing. AI-generated nonexistent package names are an active malware vector.
- **Prefer the standard library and existing project deps** for anything that's a few lines of code. The exception: always take a vetted library for crypto, auth, date/time, Unicode, or network-protocol work — never hand-roll those.
- **Consider vendoring.** If you need one function from a small utility library, copying the function (with attribution and license) is often simpler than taking the dependency. For anything more than ~100 lines of code, take the dep instead.
- **Prefer widely-used, actively maintained packages.** "Last commit 3 years ago" is a red flag. "42 stars, one maintainer" is a red flag unless the library is narrowly scoped and done.
- **Pin dependencies via lockfiles.** Commit `package-lock.json`, `pnpm-lock.yaml`, `uv.lock`, `poetry.lock`, or `requirements.txt` with hashes — the lockfile is the real pin. In manifests, `~` or `^` are fine; never `*` or `latest`.
- **Disable install scripts in CI by default** (`npm ci --ignore-scripts`). Allow-list packages that legitimately need them.
- **Document any new dep you add.** In the PR description or commit message, note what it does, why the stdlib didn't work, and the version you pinned. Consider adding an entry to `DECISIONS.md` for non-trivial deps.

If I ask you to add a dep and you think one of the above checks fails, say so before adding it.

---

## Tooling defaults

Use these unless the project already has different tooling — in which case follow what's there.

**Python:** `ruff format` + `ruff check`; `mypy` or `pyright` strict; `pytest`; `uv` for envs/deps.

**TypeScript / JavaScript:** `prettier`; `eslint` with `@typescript-eslint`; `tsc --noEmit` strict (no `any` without a justifying comment); `vitest` (preferred) or `jest`; match the project's package manager from its lockfile.

Run the formatter, linter, and type checker before claiming done (see §Verification).

---

## Git workflow

- **Branches.** Feature-branch workflow. Never commit to `main`. If I haven't specified a branch, create one with a sensible name.
- **Commits.** Small, atomic commits — one logical change per commit. Don't mix refactor + feature or formatting + logic. Each commit should build and its tests should pass. A commit that touches 47 files with message "updates" is not acceptable.
- **Message format (50/72):**
  - Subject: imperative mood, capitalized, ≤50 chars, no trailing period.
    - Good: `Add retry logic to ticket purchase endpoint`
    - Bad: `fixed the bug` / `Updates` / `WIP`
  - Blank line.
  - Body wrapped at 72 chars, explaining *why*. Link issues by number where relevant.
- **Conventional Commits** if the project uses them (check for commitlint config or existing patterns): `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, with `!` or `BREAKING CHANGE:` for breaking changes.
- **Don't amend or force-push shared branches.** Amending your own unpushed commits is fine. `--force-with-lease` on your own branch only. Rewriting published history is not OK without explicit approval.
- **Don't include generated files, build artifacts, editor junk, or `.env` files in commits.** Check `.gitignore` before staging; add missing entries when you notice them.

---

## Accessibility (public-facing UI only)

If this project has a UI that real users hit — marketing site, ticketing flow, public tool — target WCAG 2.2 AA:

- Semantic HTML (`<button>`, `<nav>`, `<main>`, headings in order) before ARIA. ARIA only fills gaps semantic HTML can't.
- Every interactive element keyboard-operable, with a visible focus outline.
- Form inputs have real `<label>` elements (or `aria-label` when visual labels would be wrong).
- Text contrast ≥4.5:1 for body, ≥3:1 for large text and UI components.
- Images have `alt` text; decorative images have `alt=""`.
- Don't rely on color alone to convey state.

If you're unsure a pattern meets AA, ask rather than guess. Skip this section entirely for CLIs, internal tools, and code that has no UI.

---

## When things go wrong

If you realize you've made a mistake — deleted something you shouldn't have, committed a secret, broke the build, introduced a regression — **stop and tell me immediately**. Don't try to cover it up or quietly fix it.

If a task turns out much bigger than expected, or you hit something you don't understand, stop and say so. Half-finished guessing is worse than an honest pause.

---

## Pre-flight checklist (before starting non-trivial work)

- [ ] **Read the relevant existing code.** Find and read the files you'll be changing or the ones most similar to what you're adding. Don't invent a pattern the codebase doesn't use.
- [ ] **Check existing conventions.** How does this project handle errors, logging, config, tests? Match the existing style unless you have a specific reason not to.
- [ ] **Check `DECISIONS.md` and `RESEARCH.md`.** If either file exists, skim for anything relevant to what you're about to do. Don't repeat failed experiments or re-propose rejected designs.
- [ ] **Understand the data flow.** If your change touches state or I/O, trace where the data comes from and where it goes.
- [ ] **Identify the trust boundaries.** Where does untrusted input become trusted? Does your change cross one?
- [ ] **Confirm scope with me if ambiguous.** If the request could reasonably mean two different things, ask or state your interpretation before coding.
- [ ] **Write the plan.** Short is fine. Share it before you start.

---

## Post-flight checklist (before declaring done)

- [ ] **All tests pass.** Not just the ones you wrote — all of them. If any were already failing before your change, say so explicitly.
- [ ] **Ran the linter / type checker / formatter.** Whatever the project uses. No new warnings introduced.
- [ ] **Verified the change behaves end-to-end.** See §Verification for what "run it" means per change type.
- [ ] **No secrets, keys, or credentials in the diff.** Grep for obvious patterns. Check new files especially.
- [ ] **No debug code left behind.** No `console.log`, `print`, `debugger`, commented-out blocks, or "TODO: remove this" unless they were there before.
- [ ] **No new dependencies without justification.** If you added one, it's documented in the commit message or PR.
- [ ] **The diff is what you intended.** Do a final `git diff` pass. Look for stray changes, accidental deletions, mass reformats of untouched files.
- [ ] **Decisions worth preserving are logged.** If this change involved a non-obvious architectural choice, add an entry to `DECISIONS.md`. If a significant experiment was attempted (successful or not), add it to `RESEARCH.md`.

---

## What to tell me when you're done

For any non-trivial task, end with:

1. **What you did** — one or two lines.
2. **What you decided** — judgment calls made without asking (naming, small refactors, library picks, assumptions).
3. **What I should check** — parts you're uncertain about, tradeoffs to revisit, things you skipped.
4. **What's next** — follow-ups, known debt, scope you deliberately left out.

Keep it short. Four good lines beats four paragraphs. If something is half-done or you hit a wall, say so clearly — see §When things go wrong.
