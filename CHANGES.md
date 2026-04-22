# CHANGES

Changelog for the coding-agent-standards templates. When a template version bumps, add a bullet here so `agent-docs sync` can show users what actually changed.

## Format

```
## X.Y.Z — YYYY-MM-DD

### FILENAME.md
- Short description of what changed
- Another change
```

Use the exact filename as the section header (e.g. `### AGENTS.md`, not "AGENTS" or "Agents"). The sync tool matches on this literal string. If a release only touches one file, only include that one section.

---

## 1.0.0 — 2026-04-21

### AGENTS.md
- Added definition of **"non-trivial"** at the top so later sections can reference it consistently.
- Added **Verification** section with per-change-type rules (function/module, script/CLI, web/API, refactor) and explicit "don't pretend it passed" guidance for blocked environments.
- Added **Comments and documentation** section, including the `// TODO(owner): reason (see #issue)` format.
- Added **Tooling defaults** section: Python (`ruff`, `mypy`/`pyright` strict, `pytest`, `uv`); TS/JS (`prettier`, `eslint` with `@typescript-eslint`, `tsc --noEmit` strict, `vitest`/`jest`).
- Added **Accessibility** section targeting WCAG 2.2 AA, scoped to public-facing UI only.
- Added **When things go wrong** section — "stop and tell me immediately" for mistakes, regressions, committed secrets.
- Replaced the post-flight "Honest summary" bullet with a 4-item **What to tell me when you're done** section (what you did / decided / I should check / what's next).
- Expanded Security with concrete crypto primitives (Argon2id preferred, bcrypt cost ≥10 + 72-byte footgun note, `secrets.token_urlsafe(32)`, `crypto.randomBytes`, constant-time comparison, AES-GCM/ChaCha20-Poly1305), SQL/LDAP/shell parameterization, validate-at-boundary / encode-at-sink, "authorize every request that touches a resource," HTTPS security headers.
- Expanded Dependencies with typosquat / hallucinated-package warning, install-script lockdown in CI (`npm ci --ignore-scripts`), and shifted pinning stance: the **lockfile is the real pin**; manifest ranges (`~`, `^`) are acceptable (previously forbade them).
- Expanded Testing with flaky-tests-fixed-or-quarantined rule, name-as-specification examples, explicit "don't mock the function under test" guidance.
- Expanded Git workflow with 50/72 subject-line format, good/bad commit-message examples, and Conventional Commits note (when the project uses them).
- Added per-language error-handling rules under "Explicit over implicit" (Python: narrowest exception, `raise ... from e`; TypeScript: `unknown` in catch clauses, handle rejected promises; fail-fast vs. fail-soft).
- Added **Duplicate before you abstract** and **rule-of-three** to YAGNI principle.
- Added **Guard clauses over nesting**, **One thing per function**, and **Push side effects to the edges** under Simplicity.
- Added a **"Stop and ask before…"** escalation list to Operational guardrails (auth/secrets/crypto, stored-data shape, new runtime deps/services, architectural choices, destructive ops).
- Added post-flight item pointing to §Verification so "run the thing" is explicit in the checklist.

### DEVELOPMENT.md
- Version header bump only; no body changes.

### DECISIONS.md
- Version header bump only; no body changes.

### RESEARCH.md
- Version header bump only; no body changes.

### TODO.md
- Version header bump only; no body changes.

### CHANGELOG.md
- Version header bump only; no body changes.

---

## 0.1.0 — 2026-04-19

### AGENTS.md
- Initial release: working agreement, 8 engineering principles, operational guardrails, pre-flight / post-flight checklists.

### DEVELOPMENT.md
- Initial template with TODO placeholders for stack, setup, day-to-day commands, architecture notes, and gotchas.

### DECISIONS.md
- Initial template: append-only ADR log with an entry template, newest-first ordering.

### RESEARCH.md
- Initial template: exploration log with an entry template.

### TODO.md
- Initial template: Now / Next / Maybe sections.

### CHANGELOG.md
- Initial template in Keep-a-Changelog format.
