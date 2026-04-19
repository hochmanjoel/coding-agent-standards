<!-- agent-docs:begin { "file": "DECISIONS.md", "version": "0.1.0", "kind": "seed-once" } -->
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
