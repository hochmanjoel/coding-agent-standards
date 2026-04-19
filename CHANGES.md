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
