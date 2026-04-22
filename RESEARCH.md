<!-- agent-docs:begin { "file": "RESEARCH.md", "version": "1.0.0", "kind": "seed-once" } -->
<!-- Seeded by agent-docs-sync. This file is never overwritten once it exists. -->
<!-- agent-docs:end -->

# RESEARCH.md

Exploration log. Things tried, whether they worked, and what we learned. This is the "don't make me read the same stale Stack Overflow answer twice" file.

**When to add an entry:** when you (or the agent) spent real time evaluating something — a library, an approach, a debugging hypothesis — and the answer is worth remembering. Especially important for dead ends: "we tried X, it doesn't work because Y" saves the next person an hour.

**When not to add an entry:** successes that are now visible in the committed code don't need a log entry. The code speaks for itself.

**Format:** dated, short, honest. Include links to external sources you relied on.

---

## Entry template — copy this

```
## YYYY-MM-DD — Short title of the question or hypothesis

**Question:** What were we trying to figure out?

**What I tried:**
- Approach 1: result
- Approach 2: result

**Conclusion:** What we now believe. If unresolved, say so.

**Sources:** links, if any.

**Related:** links to `DECISIONS.md` entries, issues, or PRs this informed.
```

---

<!-- New entries go here, newest first -->

## 2026-04-21 — Foundational principles to put in AGENTS.md 1.0.0

**Question:** What belongs in a stack-agnostic `AGENTS.md` that's genuinely durable across projects and aimed specifically at AI coding agents? The 0.1.0 release was a first-pass working agreement; what does the literature and current-practice guidance actually say should be in it?

**What I tried:**
- Synthesized seminal software-engineering books (Ousterhout's *A Philosophy of Software Design*, Martin's *Clean Code* and its critics, Hunt & Thomas's *Pragmatic Programmer*, Beck's *Tidy First?*, Fowler's *Refactoring*, Freeman & Pryce's *GOOS*) to find the principles that survive the Martin vs. Ousterhout / Classicist vs. Mockist / DRY vs. AHA disagreements.
- Cross-referenced engineering-org handbooks (Google's Eng Practices + *Software Engineering at Google*, Linux kernel process docs, Rust API Guidelines, Effective Go, PEP 8/20).
- Pulled current standards where they're decision-critical: OWASP Top 10:2021, Saltzer & Schroeder 1975, CISA *Secure by Design*, NIST SP 800-218 SSDF, SLSA v1.0, SemVer 2.0.0, WCAG 2.2, Green Software Foundation SCI.
- Compiled AI-agent-specific failure modes with sources: Spracklen et al. (USENIX Security 2025) on 19.7% package-hallucination rate, the slopsquatting proof-of-concepts, GitClear's 2024/2025 reports on AI amplifying copy-paste and reducing refactoring, METR's 2024 RCT finding experienced devs were 19% slower with AI while feeling 20% faster, CodeRabbit's finding of ~2.74× vulnerability density in AI code.
- Produced a candidate 73-directive menu grouped by domain, each enforceable in code review.

**Conclusion:** Most quality-engineering principles converge across 40 years and different authors; the disagreements (Martin vs. Ousterhout on function size and comments, Classicist vs. Mockist TDD, three-pillars vs. Observability 2.0, data-oriented vs. hotspot) are real and are called out rather than finessed. The operative AI-agent-specific additions are narrow but critical: **verify packages exist on the real registry, never invent APIs, read nearby code before writing, stay in scope, run the code, never swallow errors.** Those six directives are direct responses to documented failure modes, not philosophy. The report's candidate directives were the source for AGENTS.md 1.0.0's additions over 0.1.0 (Verification, Tooling defaults, Accessibility, When-things-go-wrong sections; Argon2id / `secrets.token_urlsafe` / constant-time-compare crypto specifics; typosquat + hallucinated-package warning; flaky-quarantine rule; lockfile-as-pin; per-language error-handling rules).

**Sources:** the full report is preserved verbatim at [`research/2026-04-21-software-engineering-principles-for-ai-coding-agents.md`](research/2026-04-21-software-engineering-principles-for-ai-coding-agents.md).

**Related:**
- [`templates/AGENTS.md`](templates/AGENTS.md) 1.0.0 incorporates the directives.
- [`CHANGES.md`](CHANGES.md) 1.0.0 entry summarizes what made it in.
- `DECISIONS.md` entries covering per-doc versioning, single-file AGENTS.md (vs. splitting by topic), and lockfile-as-pin.
