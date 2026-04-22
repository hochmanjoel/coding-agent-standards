<!-- agent-docs:begin { "file": "DECISIONS.md", "version": "1.0.0", "kind": "seed-once" } -->
<!-- Seeded by agent-docs-sync. This file is never overwritten once it exists. -->
<!-- agent-docs:end -->

# DECISIONS.md

Append-only log of architectural and non-trivial design decisions. Newest entries at the top.

**When to add an entry:** when a choice was made that a future reader (or agent) might otherwise re-litigate. Include the rejected options and *why* they were rejected. "Why not" is usually more valuable than "why".

**When not to add an entry:** tiny stylistic choices, decisions dictated entirely by the framework, anything the code itself makes obvious.

**Format:** use the template below. Keep entries short — the decision and the reasoning. Detailed exploration belongs in `RESEARCH.md`; point to it if relevant.

---

## Entry template — copy this

```
## YYYY-MM-DD — Short title of the decision

**Context:** 1–3 sentences on what problem we were solving.

**Decision:** What we're doing.

**Considered and rejected:**
- **Option A:** why not
- **Option B:** why not

**Consequences:** What this makes easier or harder going forward. Any follow-ups this implies.

**Revisit if:** conditions under which this should be reconsidered (e.g., "if we ever need multi-tenancy", "if request volume exceeds 10k/s").
```

---

<!-- New entries go here, newest first -->

## 2026-04-21 — Keep AGENTS.md as a single file rather than splitting by topic

**Context:** AGENTS.md 1.0.0 is ~290 lines. Considered whether to split it into a short charter plus topic files (Security, Dependencies, Tooling, Accessibility) to reduce instruction-dilution on every session load.

**Decision:** Keep it as a single file for now. Use `§`-style cross-references between sections instead of separate files.

**Considered and rejected:**
- **Tiered split (short charter + `STANDARDS/*.md` per concern).** Real failure mode: agents don't reliably pull in a companion file mid-task unless the trigger is discrete (adding a dep, writing crypto, UI work). Cross-cutting rules — error handling, "never commit secrets," verification, naming — apply to nearly every change and would be missed if split out. Would end up with ~60% of content still in the charter plus the overhead of a second file to maintain.
- **Claude Code `@path/to/file.md` imports.** Eager-expanded at session start, so they don't reduce the in-context length; they only improve navigability for humans reading the repo.

**Consequences:** AGENTS.md stays the one entry point, which is simpler for users, downstream projects, and the sync tool. Cost: a longer file that's slightly more likely to have middle-section rules under-weighted by smaller models. Mitigation is structural: headings are scannable, checklists are scannable, cross-references are explicit.

**Revisit if:** the file grows past ~400 lines, or we start supporting agents that don't auto-load the full AGENTS.md on every session (then on-demand loading becomes a real lever and a split becomes worth the complexity).

---

## 2026-04-21 — Per-document semver for templates, not project-wide

**Context:** Each template file (AGENTS.md, DEVELOPMENT.md, DECISIONS.md, RESEARCH.md, TODO.md, CHANGELOG.md) carries its own `version` in the `agent-docs:begin` header. Considered whether to move to a single project-wide version number for the template bundle.

**Decision:** Keep per-document semver. Each template's header version reflects the last release where that file's body changed. `CHANGES.md` groups entries by release and lists only the files that changed.

**Considered and rejected:**
- **Project-wide single version.** Would mean every release marks every file as upgraded — so `agent-docs sync` would prompt users about files whose body didn't actually change. Breaks the sync UX the tool is designed around (only surface real changes to the user), and inflates CHANGES.md with noise.
- **Project-wide version *plus* per-file "last changed in release" field.** More metadata, no real win over just bumping per-file versions directly.

**Consequences:** Template versions will drift (e.g., post-1.0.0 AGENTS.md may reach 1.3.0 while other files stay at 1.0.0). That's the intended behavior — the drift *is* the signal to the sync tool. The root `VERSION` file tracks the overall release/CLI version separately; it can match the most-frequently-updated template or be bumped independently when the CLI itself changes.

**Revisit if:** the sync tool changes its upgrade model (e.g., moves to an atomic bundle where all files must be at the same version for coherence).

---

## 2026-04-21 — Dependency pinning: lockfile-as-pin, manifest ranges allowed

**Context:** AGENTS.md 0.1.0 forbade `~` and `^` in manifests ("pin exact versions, no `^`, no `~`, no ranges"). The 1.0.0 synthesis of current supply-chain guidance (SLSA, OpenSSF, Latacora, and the lockfile-hash literature) came out against that stance.

**Decision:** Commit lockfiles for applications; lockfile integrity hashes are the real defense. Manifest ranges (`~`, `^`) are acceptable. Forbid `*` and `latest` outright. Don't ship lockfiles from libraries.

**Considered and rejected:**
- **Forbid manifest ranges entirely (the 0.1.0 stance).** Ceremonially strict but doesn't buy additional protection once the lockfile is committed — the lockfile pins the exact resolved version and hash either way. Friction during routine dependency updates (every `~x.y` gets flagged in review) without a security return.
- **Require lockfile + forbid manifest ranges.** Belt-and-suspenders; same friction with no added protection over lockfile alone.

**Consequences:** Matches how modern ecosystems (npm, pnpm, uv, poetry, Cargo) actually work. Users can take patch-level updates through normal tooling (`npm ci`, `uv sync`) and review the lockfile diff. Libraries explicitly don't commit lockfiles, avoiding the resolution conflicts they cause downstream.

**Revisit if:** a new supply-chain attack class shows lockfiles are insufficient for a common scenario, or if a target ecosystem emerges that doesn't produce a hashed lockfile.
