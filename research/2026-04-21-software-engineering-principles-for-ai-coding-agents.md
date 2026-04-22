# Foundational principles of quality software engineering, synthesized for AI coding agents

> Source document for AGENTS.md 1.0.0. Preserved verbatim; encoding normalized
> from the original (em/en dashes, arrows, math symbols, and diacritics were
> mojibake in the raw input). Dated 2026-04-21.

The central argument of this report is simple: **quality software engineering is not a matter of taste but a working synthesis of a few dozen well-sourced principles, most of which are stable across decades, ecosystems, and authoritative bodies.** The principles below are drawn from seminal books (Ousterhout's *A Philosophy of Software Design*, Martin's *Clean Code* and its critics, Hunt & Thomas's *Pragmatic Programmer*, Beck's *Tidy First?*, Fowler's *Refactoring*, Freeman & Pryce's *GOOS*), from engineering-org handbooks (Google's Eng Practices and *Software Engineering at Google*, Linux kernel Documentation/process, Rust API Guidelines, Effective Go, PEP 8/20), and from current standards and guidance (OWASP Top 10:2021 and Cheat Sheets, NIST SP 800-218 SSDF, NIST SP 800-207 Zero Trust, CISA *Secure by Design* 2023, SLSA v1.0, SPDX, SemVer 2.0.0, W3C WCAG 2.2, Green Software Foundation SCI, Saltzer & Schroeder 1975). Where the authorities disagree — and they often do — the report names the disagreement and takes a position suitable for AI-generated code reviewed by humans.

The report's purpose is to justify a tight set of AGENTS.md directives for AI coding agents. Agents differ from humans in ways the principles must respect: **they hallucinate packages and APIs, confidently emit deprecated patterns, swallow errors to make tests pass, over-mock, and drift out of scope.** Every directive in the final section is chosen to be enforceable in code review — the test is whether a reviewer can point at a line and say "this violates rule N."

---

## 1. Code quality and design

**Names carry intent.** A reader should know a symbol's role from its name without reading the body (Ousterhout; Linux kernel style; Rust API Guidelines). Failure modes are vague buckets (`data`, `info`, `manager`, `util`), stutter (`io::IoError`), Hungarian prefixes, and names that lie after a refactor. Ousterhout prefers longer, precise names; Linux style accepts `i` for tight local counters — a surface disagreement about scope, not substance.

**Functions should do one thing at one level of abstraction** — the single point on which Martin (*Clean Code*) and Ousterhout diverge most sharply. Martin's prescription of two-to-four-line functions is *the* contested rule in this literature; Ousterhout explicitly rejects it ("methods containing hundreds of lines of code are fine if they have a simple signature and are easy to read"), and Linux coding style warns against splitting merely to satisfy a size limit. The defensible synthesis: one conceptual operation at one abstraction level, but **no artificial size ceiling**. Helpers earn their place by naming a reusable concept, not by shortening a line count.

**Prefer deep modules — wide implementation, narrow interface.** This is Ousterhout's central thesis and is echoed by the Go proverb "the bigger the interface, the weaker the abstraction." The anti-pattern is "classitis" — swarms of shallow classes each adding a layer without hiding anything. Martin's SRP culture, taken literally, produces exactly this failure; both camps agree on information hiding as the underlying goal.

**Minimize coupling and maximize cohesion.** Things that change together belong together; things that don't, don't. Beck's *Tidy First?* frames coupling reduction as the economic foundation of design, because structural simplification makes every future behavioral change cheaper. Hickey's *Simple Made Easy* reframes this as avoiding *complecting* — braiding independent concerns together.

**DRY is about knowledge, not tokens — and premature abstraction is worse than duplication.** Hunt and Thomas's 20th-anniversary edition explicitly warns readers who reduced DRY to "don't copy-paste." Metz's *The Wrong Abstraction* and Abramov's *Goodbye, Clean Code* argue that a near-fit abstraction meeting a new requirement breeds conditionals rather than being backed out; Dodds coined **AHA (Avoid Hasty Abstractions)**, Abramov popularized **WET (Write Everything Twice)**, and the **Rule of Three** is the pragmatic compromise: wait for the third divergent use before extracting. This is the most-misapplied principle in the literature — "DRY violations" is the usual justification for exactly the coupling Metz and Abramov warn against.

**Depend on abstractions, not concretions — but don't pre-declare interfaces you don't need.** Business logic that imports an ORM, HTTP client, or filesystem directly becomes untestable and immovable. Go's implicit interface satisfaction ("accept interfaces, return structs") and Rust's trait system achieve dependency inversion without ceremony; single-implementation interfaces-for-tests that exist only to please SOLID are a code smell.

**Isolate side effects; prefer a pure core.** Push I/O, clock, randomness, and mutation to the edges and keep the core a deterministic function of its inputs. This is Seemann's "Functional Core, Imperative Shell," Hickey's immutability argument, and the common ground between FP and pragmatic OO.

**Errors are values; handle them explicitly at the right layer.** Go's "errors are values" proverb and Rust's `Result<T,E>` force callers to decide at each call site. Exceptions and `panic`/`unwrap` should be reserved for invariant violations. Ousterhout's more controversial guidance — *define errors out of existence* (design APIs that make the error impossible) — is worth taking seriously where it applies. The cross-ecosystem disagreement (Java/Python/C# exceptions vs. Go/Rust values) is real and should be resolved per-language in a project-specific AGENTS.md, but the universal rule survives: **never swallow errors silently.**

**Fail fast on programmer errors; fail soft on environmental errors.** A violated invariant means your model of reality is wrong — continuing corrupts state. An expected fault (network, bad input) is part of the spec. Erlang's "let it crash" is a frequently-misunderstood corollary: it works *inside a supervisor* that will restart the crashed process. Applied to a stateful singleton without supervision, it just loses data.

**Every rule is a default.** The Linux kernel style and PEP 20 are explicit about this. What distinguishes quality engineering from cargo-culting is the ability to articulate *why* you are overriding a rule; silent overrides are the problem.

---

## 2. Readability and self-documenting code

**Code is read far more often than written.** This is the axiom behind Knuth, Kernighan, Ousterhout, and PEP 20's "readability counts." Every trade-off — keystroke savings, clever one-liners, implicit control flow — must account for a read-to-write ratio that is typically 10:1 or worse.

**Minimize cognitive load.** Hickey, Seemann (*Code That Fits in Your Head*), and Linux style ("if you need more than three levels of indentation, you're screwed anyway") converge on 7±2 as the practical working-memory ceiling. The disagreement about *how* to reduce load — many small functions (Martin) vs. fewer deep modules (Ousterhout) — is real, but the target is the same.

**Consistency beats local optimality.** gofmt's reputation — "no one's favorite, yet everyone's favorite" — captures the principle. Google's review guide forbids blocking PRs on personal style. The reviewer-friendly corollary: **do not reformat unrelated lines during a functional change.**

**Clear beats clever.** Kernighan's line — "if you're as clever as you can be when you write it, how will you ever debug it?" — is the most cited reason to prefer an obvious loop to a dense comprehension or a one-liner built from three standard-library functions most readers will have to look up.

**Explicit over implicit.** PEP 20's line applies beyond Python. Default parameters that flip semantics, monkey-patching, import-time side effects, and implicit `None` returns are all hostile to local reasoning. Go, Rust, and modern TypeScript enforce this; Ruby/Rails historically tolerated magic — a trade-off that produced well-documented ergonomic wins and well-documented debugging pain.

**Keep control flow linear with guard clauses.** Early-return validation followed by an unindented happy path is the dominant modern idiom (*Effective Go*, Beck's *Tidy First?* opening chapter). Nested `try/catch` pyramids and deep `if/else` trees raise cognitive load for no gain.

**Separate structural from behavioral changes.** Beck's *Tidy First?* is the definitive source: a commit that both reflows 500 lines and changes behavior is unreviewable. The Fowler "two hats" rule — *refactor* xor *add feature*, never both simultaneously — is the same principle at commit granularity.

---

## 3. Comments and documentation

**The Martin–Ousterhout disagreement is the defining one.** Martin (*Clean Code*): "the proper use of comments is to compensate for our failure to express ourself in code… every time you write a comment, you should grimace." Ousterhout (*Philosophy*): "'Good code is self-documenting' is a delicious myth, like a rumor that ice cream is good for your health." The defensible synthesis — adopted by Google, Rust, and Go style guides — is that **code expresses what and how; comments express why, invariants, units, and rationale; docstrings express the interface contract.**

**Comment why, not what.** The corollary from the Linux kernel style ("tell WHAT your code does at the *function* level; never comment implementation details that are obvious"). `i++; // increment i` is the archetypal failure; so is a docstring that restates the parameter list in prose.

**Write interface docstrings that fully describe the abstraction.** Every public function/class must document behavior, parameter units and ranges, null/zero semantics, return value, errors, and side effects — in the language's canonical format (Google or NumPy style for Python, `# Errors`/`# Panics`/`# Safety` for rustdoc, godoc conventions, TSDoc/JSDoc). A reader should be able to use the function without reading the body.

**Record consequential decisions as Nygard-format ADRs.** Michael Nygard's 2011 blog post established the minimum template: **Title, Status, Context, Decision, Consequences**. Accepted ADRs are immutable; reversals create a new ADR that *supersedes* the old one. MADR and Y-statements add structure but are not required. The ADR test: can the team answer "why did we pick X over Y?" three years later from the repo alone?

**Distinguish audiences: inline comments, docstrings, commit messages, PR descriptions, ADRs, READMEs.** Each serves a different reader at a different moment. The commonest failures are explaining a subtle invariant only in a commit message (invisible in `git blame`), writing an ADR as release notes, or letting a README grow into a manual. **READMEs exist to get a new contributor running in ~5 minutes and point them to deeper docs.**

**Every TODO/FIXME has an owner and a tracked issue.** `TODO(alice): handle unicode edge case (#1234)` is the minimum viable format; bare `TODO: fix this` is debt with no audit trail. Several teams now enforce expiry dates with ESLint `expiring-todo-comments` or equivalent.

**Stale comments are bugs.** Google reviewers explicitly check that comments match code; a lying comment is worse than no comment, because it wastes the next reader's trust as well as their time.

---

## 4. Testing

**The testing pyramid, testing trophy, and Google test sizes describe the same tradeoff differently.** Cohn's 2009 pyramid (many unit, fewer integration, fewest E2E) assumes expensive integration tests. Dodds's 2018 trophy (static → unit → *integration* → E2E) argues that modern tooling makes integration tests cheap enough to be the largest layer. Google avoids the form debate by using Small/Medium/Large — hermetic vs. single-machine vs. multi-machine — because "unit test" means different things to different people. Fowler's 2021 retrospective says the real issue is definitional: few teams write "expressive tests that establish clear boundaries, run quickly and reliably, and only fail for useful reasons."

**Mock only what you don't own, and mock the narrowest possible boundary.** Fowler's *Mocks Aren't Stubs* distinguishes Classicist/Detroit TDD (real objects, state verification) from London/Mockist TDD (mock collaborators, behavior verification). Freeman and Pryce's *GOOS* is the seminal mockist text and is explicit that "we don't mock values" and "only mock peers, not internals." The failure mode — tests that mock the system under test's own public API and thereby prove nothing — is the most common form of AI-generated test debt.

**Prefer property-based tests for invariants.** QuickCheck, Hypothesis, and Hedgehog generate inputs and shrink failures, revealing cases humans do not write. Hillel Wayne's synthesis — PBT plus contracts — is the strongest automated discipline short of formal methods.

**100% line coverage is not quality; mutation score is closer.** Mutation tools (PIT, Stryker, mutmut) flip operators and statements to check whether any test actually fails. Coverage targets, per Goodhart's law, incentivize assertion-free tests. Low coverage is a red flag; high coverage is not a green one.

**Flaky tests are worse than failing tests.** Google's test infrastructure tags and deprioritizes flakes because a sometimes-red suite trains engineers to ignore red. The discipline: quarantine the flake immediately, fix or delete within a bounded window.

**Name tests as specifications; use AAA/Given-When-Then.** A test name that reads like a sentence (`returns_404_when_user_is_not_found`) doubles as documentation when it fails in CI — one reason Google's *Software Engineering at Google* treats test readability as a first-class concern.

---

## 5. Security

**OWASP Top 10:2021 is a floor, not a ceiling.** The ten categories — A01 Broken Access Control, A02 Cryptographic Failures, A03 Injection, A04 Insecure Design, A05 Security Misconfiguration, A06 Vulnerable & Outdated Components, A07 Identification & Authentication Failures, A08 Software & Data Integrity Failures, A09 Security Logging & Monitoring Failures, A10 SSRF — are the current baseline as of April 2026. OWASP ASVS provides the rigorous follow-up standard. Critics who call the Top 10 marketing-rather-than-engineering have a point; use it as the shared vocabulary, then go deeper with ASVS and SAMM.

**Saltzer & Schroeder's 1975 principles remain the foundation.** Economy of mechanism, **fail-safe defaults**, complete mediation, open design, separation of privilege, **least privilege**, least common mechanism, psychological acceptability. NIST SP 800-160 formalizes them into 33 engineering principles; NIST 800-53 AC-6 codifies least privilege. These are not checkboxes — a violation is a signal that the design deserves scrutiny.

**Default to deny, fail closed.** CISA's *Secure by Design* (April 2023, updated October 2023) explicitly states that "secure configuration should be the default baseline… at no extra charge." Its three principles — take ownership of customer security outcomes, embrace radical transparency, lead from the top — shift responsibility from customers to manufacturers. Fail-closed is contested only in availability-critical systems (medical, safety) where explicit, documented exceptions are required.

**Input validation plus contextual output encoding — not either one alone.** Injection (A03) and XSS consistently trace to missing contextual encoding or naive blocklists. A single global `sanitize()` is the archetypal failure: the right answer is allow-list validation at the trust boundary *and* context-aware encoding (HTML body, HTML attribute, JS, URL, CSS, SQL, shell, LDAP) at the sink.

**Use parameterized queries or a vetted ORM — always.** String interpolation into dynamic identifiers (table/column names) is not covered by parameterization; use an allow-listed mapping instead. Stored procedures that themselves concatenate inherit the same flaw.

**Authentication is not authorization.** Broken Access Control is OWASP's #1 risk because teams check auth at the route boundary but let user-supplied IDs bypass resource-level checks (IDOR/BOLA). **Every request** authorizes against policy; the absence of an explicit allow is a deny. RBAC for coarse roles, ABAC/OPA/Cedar for fine-grained context, ReBAC (Zanzibar-style) for graph permissions.

**JWTs demand care.** Pin the algorithm server-side; verify the signature before trusting claims; validate `iss/aud/exp/nbf`; keep lifetimes short; never put secrets in a JWT payload (base64, not encryption). The "stop using JWTs for sessions" camp has a defensible position — opaque server-side session tokens are often simpler and revocable — but JWTs remain appropriate for stateless service-to-service auth.

**Secrets belong in vaults, not repositories.** Load from HashiCorp Vault, AWS/GCP/Azure Secret Manager, or SOPS at runtime; prefer short-lived credentials. The superior pattern is **workload identity via OIDC** (GitHub Actions → cloud IAM), which eliminates stored static keys entirely.

**Follow Latacora's "Cryptographic Right Answers" and don't roll your own.** Symmetric AEAD: AES-GCM or ChaCha20-Poly1305 (XChaCha20-Poly1305 with random nonces). Key exchange: X25519 (hybrid X25519+ML-KEM-768 for post-quantum). Signatures: Ed25519. Password hashing: **Argon2id at current OWASP parameters (m=19 MiB, t=2, p=1 or m=46 MiB, t=1, p=1)**; fall back to scrypt, bcrypt (cost ≥10, ≤72-byte input), or PBKDF2-HMAC-SHA-256 (FIPS only). Tokens: 256-bit from a **CSPRNG** (`secrets.token_urlsafe`, `crypto.randomBytes`). Compare secrets and MACs in **constant time** (`hmac.compare_digest`, `crypto.timingSafeEqual`).

**Threat-model with STRIDE + Shostack's four questions.** *What are we working on? What can go wrong? What are we going to do about it? Did we do a good job?* STRIDE (Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege) enumerates "what can go wrong." DREAD is widely deprecated; PASTA and LINDDUN cover business-risk and privacy respectively. The Threat Modeling Manifesto reframes Q4 as "did we do a *good enough* job?"

**Adopt memory-safe languages for new code.** CISA's "Case for Memory Safe Roadmaps" (December 2023) and CISA/NSA "Memory Safe Languages" (June 2025) cite roughly two-thirds of vulnerabilities in memory-unsafe languages as memory-safety bugs. For existing C/C++, isolate `unsafe` regions behind validated boundaries and publish a roadmap.

**Ship security headers.** Content-Security-Policy (nonce- or hash-based, never `unsafe-inline`), HSTS (`max-age≥31536000; includeSubDomains; preload`), `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, appropriate `Permissions-Policy` and CSP `frame-ancestors`. CSP is the last line of defense against XSS; `X-Frame-Options` is superseded by `frame-ancestors`.

**Never log secrets, session tokens, full PANs, or unnecessary PII.** OWASP A09. Authorization headers, OAuth `code=` query strings, and stack-traced DB connection strings are the commonest leaks. Use field allow-lists rather than blocklists when redacting.

---

## 6. Supply chain integrity

**Vet every new dependency.** Before adding a direct dependency: confirm it exists on the expected registry, has an OSI-approved compatible license, has released in the last ~12 months, has more than one active maintainer (or documented bus factor), and has a defensible install size. A five-minute checklist would have blocked most recorded incidents — event-stream (2018 single-maintainer transfer), ua-parser-js (2021 NPM takeover), and xz-utils (CVE-2024-3094, a 2.5-year social-engineering compromise whose backdoor lived *only in the release tarball*, not in Git).

**OpenSSF Scorecard is a heuristic, not a proof.** Release cadence, signed releases, branch protection, code review, fuzzing, dangerous-workflow detection. xz-utils would have scored well before the attack; Scorecard is necessary, not sufficient.

**"A little copying is better than a little dependency"** (Rob Pike). For utilities under ~100 LOC without security-sensitive logic, inline over depending. The `left-pad` incident (2016) broke a large fraction of npm from 11 lines. The exceptions — **always** take the vetted library — are cryptography, Unicode, date/time, auth, and anything network-facing.

**Commit lockfiles for applications; do not ship lockfiles from libraries.** `package-lock.json`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `poetry.lock`, `uv.lock`, `Gemfile.lock`. Applications need reproducible installs and integrity hashes; libraries that ship locks force resolution conflicts on downstream consumers. Rust documents that `Cargo.lock` in libraries is ignored by downstream builds.

**Pin exact versions in lockfiles; use narrow ranges in manifests.** `^` and `~` balance SemVer's "version lock vs. promiscuity" tension, but the **lockfile's hashes are the actual defense**. `*` or `latest` ships whatever was published in the last minute — that minute is when ua-parser-js compromised consumers in 2021.

**SemVer is a social contract you must honor and a guarantee you cannot rely on.** `semver.org` defines the contract; **Hyrum's Law** defines reality — "with a sufficient number of users of an API, all observable behaviors of your system will be depended on by somebody." Publish SemVer correctly for your own releases; defensively assume downstreams depend on every observable behavior of yours, and assume upstream patches may break you. Rich Hickey's *Spec-ulation* critique — that MAJOR bumps just rename libraries and that pure accretion with renaming is more honest — is worth reading even if you don't adopt it.

**Prevent dependency confusion with scoped names and a locked resolver.** Alex Birsan's 2021 research hit Apple, Microsoft, PayPal, Shopify, Tesla, Netflix, Uber, and ~35 others by registering public packages with names shadowing private ones. Mitigation: publish internal packages under a reserved org scope (`@acme/…`, `com.acme.…`), reserve the names on public registries, and configure clients so that scope resolves *only* from the internal registry. pip's `--index-url`/`--extra-index-url` is a notorious footgun.

**Aim for reproducible builds; target SLSA Build L2 as a minimum and L3 for sensitive artifacts.** Reproducibility (reproducible-builds.org, Nix, Bazel, `SOURCE_DATE_EPOCH`) lets independent rebuilders verify a shipped artifact matches the source — the only technical defense that would have caught the xz-utils tarball-only backdoor. SLSA v1.0 Build Track L1 has provenance but it is forgeable; L2 adds signed provenance from a hosted builder; L3 isolates the builder so signing keys are inaccessible to user build steps. SLSA itself warns that L3 does not cover compromise of the build platform — not a silver bullet against long-con maintainer takeover.

**Generate and publish an SBOM per release.** CycloneDX or SPDX, per EO 14028 / NTIA minimum elements. CycloneDX is often preferred for security; SPDX for licensing. Sign the SBOM; regenerate it per build; don't let it drift from reality.

**Sign everything; verify on consume.** Sigstore (cosign + Fulcio + transparency log Rekor), npm provenance, PyPI trusted publishing, Go checksum database, Maven Central signatures. Keyless Sigstore signatures plus a transparency log make silent republication detectable. Verify signatures in CI before any production install.

**Disable install scripts by default.** `npm --ignore-scripts`, audited `pip` build isolation, `cargo`'s `build.rs` review. Post-install scripts are the most common malware-delivery mechanism in typosquat payloads — Birsan's callbacks exfiltrated data almost entirely via `preinstall`/`postinstall`. Allow-list packages that legitimately need scripts.

---

## 7. Version control and change management

**One logical change per commit; bisectable history; atomic commits.** Don't mix refactor with feature, formatting with logic, or vendored updates with hand-written code. Each commit on the mainline builds and passes tests on its own. `git bisect` is the cheapest regression-localization tool in existence, but only when history is clean.

**Commit messages: Tim Pope's 50/72 rule.** Imperative mood, capitalized, ≤50-char subject; blank line; body wrapped at 72 chars explaining *why*. "Fixed the bug" is the archetypal failure. Google's eng-practices puts it plainly: "reading source code may reveal *what* the software is doing but it may not reveal *why*."

**Adopt Conventional Commits when tooling consumes history.** `<type>[scope]!: description` with at minimum `feat` (→ MINOR), `fix` (→ PATCH), and `!` or `BREAKING CHANGE:` footer (→ MAJOR). Don't inflate types; don't disguise breaking changes as `chore`.

**Trunk-based development with short-lived branches.** DORA's multi-year *Accelerate* research correlates high delivery performance and stability with ≤3 active branches per repo and daily trunk merges. Vincent Driessen's 2020 "note of reflection" explicitly retracted Gitflow for continuous-delivery web apps; Gitflow still fits versioned, multi-release products (mobile, embedded, enterprise on-prem). This is domain-contested — pick deliberately per product.

**Small PRs.** Target ≤200–400 changed lines per PR. Google's *small-cls* guide lists eight concrete benefits. The SmartBear/Cisco 10-month study of 2,500 reviews across 3.2M LOC found defect-detection effectiveness collapses beyond ~400 LOC or above ~500 LOC/hour. IBM data: a defect caught in review costs 10–100× less than in production. When a change genuinely cannot be split (generated code, large rename), preview the large CL with reviewers first.

**Protect `main`.** Required non-author review, green CI, linear history, CODEOWNERS for sensitive paths, no direct pushes, no force-push. Tags are **signed, annotated, and SemVer-matched**, pointing at the exact build commit — never re-tag a published release.

**Revert first, debug second.** Google institutionalizes revert-first because broken trunk blocks everyone and small reverts are cheaper than roll-forward heroics. Roll-forward proponents worry about migration rollback — the answer is to **revert code, handle migrations separately** (see §8's Parallel Change).

**Pick an integration policy and be consistent.** Rebase + fast-forward (linear, every commit atomic), squash-merge (one commit per PR), or merge commits (preserves topology). Kernel and many large projects use rebase; GitHub Flow shops often squash; Gitflow uses merges. Mixing yields a history that is neither bisectable nor topology-readable.

**Use DCO (`Signed-off-by:`) for shared repos and sign commits/tags cryptographically.** DCO is the Linux kernel's provenance assertion (legally useful inbound license signal). Cryptographic signing defends against the trivial impersonation of `git config user.email` — important after xz-utils.

---

## 8. Observability and operability

**Three pillars or high-cardinality wide events?** Peter Bourgon's 2017 "three pillars" (metrics, logs, traces) is the lingua franca. Charity Majors' critique — that the pillars are siloed, multiply storage cost, and can't handle unknown-unknowns because metrics tools collapse cardinality — has shifted the field: "Observability 2.0" treats arbitrarily-wide structured events as the source of truth, from which metrics, logs, and traces are derived. Every major observability vendor founded after 2021 uses this model. For an AGENTS.md the actionable synthesis is: **emit structured events with rich context; propagate trace IDs; keep cardinality high where it helps investigation.**

**Monitoring frameworks apply at different scopes.** Google SRE's **four golden signals** (latency, traffic, errors, saturation) cover user-facing services. Tom Wilkie's **RED** (rate, errors, duration) covers service health. Brendan Gregg's **USE** (utilization, saturation, errors per resource) covers infrastructure. Mature teams use all three.

**Structured logs with trace context.** JSON logs, key-value pairs, W3C `traceparent` headers, OpenTelemetry SDKs. Distinguish log levels (TRACE/DEBUG/INFO/WARN/ERROR/FATAL); never log at DEBUG in production without a deliberate override; never log passwords, full tokens, session IDs, PANs, or unnecessary PII. Use field allow-lists, not blocklists.

**Design for the tail.** Jeff Dean and Luiz André Barroso's 2013 *Tail at Scale* (CACM 56:2): in fan-out systems, rare slow events dominate end-to-end latency. A service whose 100 leaves each have p99=1s sees ~63% of user requests exceed 1s. Mitigations: hedged requests, tied requests, micro-partitioning, queue-management. p99/p99.9 matter more than means.

**Write code that's debuggable in production.** Correlation IDs on every request, runbooks linked from every alert, blameless post-mortems, errors surfaced with context (wrap with `fmt.Errorf("…: %w", err)` or Rust's `?` + `#[from]`). Shipping a log line is the cheapest observability primitive and the first failure mode is lines with no context.

---

## 9. Performance

**Knuth's actual quote, in context.** "Programmers waste enormous amounts of time thinking about, or worrying about, the speed of noncritical parts of their programs, and these attempts at efficiency actually have a strong negative impact when debugging and maintenance are considered. We should forget about small efficiencies, say **about 97% of the time**: premature optimization is the root of all evil. **Yet we should not pass up our opportunities in that critical 3%.**" (*Structured Programming with go to Statements*, CACM 1974.) The irony: Knuth was arguing *for* careful goto-based micro-optimization in hot loops.

**Measure before optimizing.** Profilers (perf, pprof, `cargo flamegraph`, Chrome DevTools), flame graphs (Gregg), microbenchmark harnesses (JMH, criterion.rs) that account for JIT warmup and compiler optimization removal. Commit the benchmark alongside the change that motivated it.

**The data-oriented critique is legitimate.** Casey Muratori's *Clean Code, Horrible Performance*, Mike Acton's CppCon 2014 talk, and Daniel Lemire's 2023 "Hotspot performance engineering fails" argue that the hotspot model is a Pareto fantasy — real apps accumulate thousands of small inefficiencies that no profile highlights, and "premature optimization" has been overused as an excuse for bloat. Acton's core point — understand the data to understand the problem — is compatible with Knuth's full quote, just not the sanitized version.

**Big-O matters, but constant factors and cache effects dominate in practice.** A theoretically-correct `O(log n)` that blows the cache loses to an `O(n)` that doesn't, at realistic sizes. N+1 query patterns are the single commonest performance bug in data-driven applications.

**Performance budgets make decisions.** Alex Russell's 2017 analysis for a $200 Android on 400Kbps gives ~130–170 KB gzipped critical-path for a Time-to-Interactive budget. RAIL (Paul Irish) sets user-centric targets: <100ms response, 10ms/animation-frame, chunks ≤50ms, <5s to interactive on first load. Without a budget, every team ships whatever it happens to ship.

**Readability and performance are in tension only sometimes.** Most performance work is algorithmic or architectural (N+1 → join; chatty RPC → batch) and *improves* readability. Only in the 3% critical path is clever code justified — and then it must be measured and commented.

---

## 10. Areas you may not have listed

### API design and backward compatibility

**Never break userspace** (Linus Torvalds, LKML 2012): "if a change results in user programs breaking, it's a bug in the kernel." The same logic applies to any API with heterogeneous clients. Additive-only changes within a major version; breaking changes require a new major version and a deprecation window (≥180 days for public APIs, per Google AIP-185). **Never renumber, retype, or reuse a Protobuf field number**; on delete, add the number and name to `reserved` — wire format encodes only tag + type, and reuse silently decodes old bytes into new fields, corrupting data.

### Data migration safety

**Parallel Change (expand → migrate → contract)**, Danilo Sato's formulation on martinfowler.com, is the only safe pattern for breaking schema or interface changes. Expand adds the new shape; migrate copies data and switches writers/readers; contract removes the old. Each phase deploys independently and is reversible. **Deploy additive schema changes before code; deploy column-drop code before dropping the column.** The dual-write consistency trap — application code writing to both old and new columns outside a single transaction — produces divergent state on partial failure. Use online tooling (GitHub's gh-ost, pt-online-schema-change, PlanetScale deploy requests, Postgres concurrent indexes) for tables large enough to notice. **Every migration must be reversible, and reversibility must be tested on a production-shaped replica.**

### Feature flags and progressive rollout

Pete Hodgson's taxonomy on martinfowler.com distinguishes **Release, Experiment, Ops, and Permission** toggles — each with a different lifespan and management regime. Release toggles are temporary and must be retired; Fowler's cautionary example is a Linux kernel that required special recompilation to handle enough command-line switches. Inject decisions; don't scatter `if (flags.x)` throughout layers. Couple flags with canary/blue-green/ring deploys and automated SLO-based rollback. Program against **OpenFeature** (CNCF-incubating) rather than a vendor SDK.

### Idempotency

Stripe's idempotency-key pattern: client-generated V4 UUID on every mutating endpoint, full response cached against the key for ≥24 hours, parameter-mismatched reuse rejected. GET/PUT/DELETE are idempotent by HTTP semantics; POST/PATCH need explicit keys. Retries use exponential backoff with jitter and respect `Retry-After`. Assume at-least-once delivery everywhere — exactly-once is effectively unachievable end-to-end; duplicates are inevitable, so handlers must be idempotent by construction.

### Concurrency and race conditions

**Prefer immutability and message passing to shared mutable state.** Effective Go: "do not communicate by sharing memory; instead, share memory by communicating." Rust's `Send`/`Sync`, Java's `@GuardedBy`, and Kotlin's coroutines push the enforcement into the type system. Default to optimistic concurrency (version columns, CAS, `If-Match` ETags); reserve pessimistic locks for measured high-contention paths and **never hold them across network I/O**. Eliminate **TOCTOU** by making check-and-act atomic — `INSERT ... ON CONFLICT`, `SELECT ... FOR UPDATE`, or a single transaction. Assume the **Fallacies of Distributed Computing** (Deutsch/Gosling) are false: every remote call has timeouts, retries, circuit breakers, and first-class observability.

### Internationalization

**UTF-8 everywhere.** Internally, over the wire, on disk, in source files. The UTF-8 Everywhere manifesto is the canonical reference. **Never concatenate localized strings** — route through ICU MessageFormat or Mozilla Fluent, which implement CLDR plural rules (up to six categories: `zero`, `one`, `two`, `few`, `many`, `other`) and grammatical gender `select`. **Store timestamps in UTC; convert at display boundaries**, but for future wall-clock events preserve the originating IANA timezone because DST/zone rules change (Skeet's corollary). Read Noah Sussman's "Falsehoods Programmers Believe About Time" annually. Use ICU/CLDR collation; never sort by byte order. Test RTL with logical CSS properties (`margin-inline-start`, not `margin-left`).

### Accessibility

**Target WCAG 2.2 Level AA; follow POUR** (Perceivable, Operable, Understandable, Robust). Level A is the floor, AA is the legal target under ADA/EAA/Section 508/EN 301 549, AAA is aspirational. **Semantic HTML first; ARIA only to fill genuine gaps** — WebAIM's Million study found pages *with* ARIA averaged ~41% more detectable accessibility errors than pages without. Native `<button>`, `<input type="checkbox">`, `<nav>`, and headings carry role, keyboard support, and state for free. The five WAI rules of ARIA codify this. Keyboard navigation with visible focus on every interactive element (WCAG 2.1.1, 2.4.7, and new 2.2 criterion 2.4.11). Contrast 4.5:1 for body text, 3:1 for large text and non-text UI. **Automated tools catch roughly 30–40% of issues** — Deque's research across 13,000+ pages — so budget for manual keyboard walkthroughs and screen-reader testing (NVDA, JAWS, VoiceOver).

### Licensing and IP hygiene

**Pick an OSI-approved license; put an SPDX identifier in every source file header.** MIT, Apache-2.0 (adds patent grant and NOTICE requirement), BSD-2/3, MPL-2.0 (weak copyleft), LGPL (weak copyleft, dynamic-link OK), GPL-2/3 (strong copyleft), AGPL-3 (extends copyleft to network use). `SPDX-License-Identifier: Apache-2.0` is machine-readable and REUSE.software-compliant. **Source-available licenses (BUSL, Elastic License v2, SSPL, Commons Clause, RSALv2) are not open source** by the OSI Open Source Definition — treat them as proprietary with extra rules. Between 2018 and 2024, MongoDB, Elastic, HashiCorp (Terraform→BUSL, 2023), Redis, and CockroachDB moved away from OSI licenses, producing forks (OpenTofu, Valkey). Distinguish **DCO** (lightweight `Signed-off-by:` attestation) from **CLA** (signed contract granting license/assignment); pick one per project. The AI-training-data IP question — *Doe v. GitHub/Microsoft/OpenAI* — is unsettled as of April 2026; treat AI-generated code's license provenance as unknown and document it in the PR.

### Environmental / carbon

Green Software Foundation principles: **carbon efficiency, energy efficiency, hardware efficiency.** The **Software Carbon Intensity (SCI)** specification (ISO/IEC 21031:2024) defines `SCI = ((E × I) + M) per R` — energy × grid-intensity plus amortized embodied emissions, per functional unit. SCI explicitly does not permit offsets. The three practical levers: **right-size and autoscale** (a server at 10% load draws 40–60% of peak), **carbon-aware scheduling** (time-shift batch/ML training to low-carbon hours, region-shift where latency permits — studies report 30–70% footprint reduction), and **efficiency work** (fewer bytes, fewer cycles, fewer queries). Measure with Cloud Carbon Footprint, Kepler, `scaphandre`, or CodeCarbon — "green" without measurement is vibes.

### AI-agent-specific concerns

This section matters most for an AGENTS.md, because agents systematically fail in specific, documented ways.

**Package hallucination and "slopsquatting."** Spracklen et al. (USENIX Security 2025) tested 16 code-gen models on 576,000 samples: **19.7% of recommended packages did not exist**; open-source models hallucinated at 21.7% vs 5.2% for proprietary; CodeLlama 7B/34B hallucinated >33% of the time; 205,000 unique hallucinated names were observed; **43% of hallucinations repeat across 10 re-queries**, meaning attackers need only observe a handful of outputs to predict registrable names. Seth Larson coined *slopsquatting* in April 2025. Bar Lanyado's proof — registering the hallucinated `huggingface-cli` on PyPI, where it got 30,000+ downloads in three months and was pasted into an Alibaba public README — made the threat concrete. Mitigation: **verify every imported package exists on the real registry with nontrivial history before committing, and pin with hash/lock.**

**Training-cutoff drift.** LLMs emit deprecated patterns — Python 2 `print`, pre-hooks Redux `connect`, `new Buffer()`, `crypto.createCipher` instead of `createCipheriv`, MD5/SHA-1 for passwords, TLS ≤1.1. GitClear's 2024/2025 AI Copilot Code Quality reports (211M lines, 2020–2024) found refactoring fell from 25.1% of changes in 2021 to 9.5% in 2024 while copy-paste grew from 8.3% to 12.3% — AI *amplifies* outdated patterns rather than cleaning them.

**Shallow error handling.** `try: ... except Exception: pass` is the archetypal AI failure because it makes tests pass. Ruff `BLE001`, ESLint `no-empty`, Go errcheck, and Rust `#[must_use]` all flag it.

**Confident wrongness.** Simon Willison (March 2025): "hallucinations in code are the least dangerous form of LLM mistakes" because compile/runtime errors self-announce; **plausible-but-wrong logic** that passes type checks is the real hazard. A 2024 METR RCT found experienced devs were **19% slower** with AI while feeling 20% faster. The mitigation is procedural: run the code, read the diff, re-derive the claim, cite docs for non-obvious assertions.

**Security-naive defaults, over-mocking, scope creep, and convention-ignoring** round out the failure taxonomy. CodeRabbit's 2024 review found AI code had ~2.74× the vulnerability density of human code. The most effective mitigation is also the simplest: **read nearby files before writing; match existing conventions; stay in scope; never edit unrelated files.**

---

## Where principles collide — the tradeoffs, named

- **DRY vs. decoupling.** When extracting a shared helper couples previously-independent callers, stop. Rule of Three. The wrong abstraction is more expensive than duplication (Metz).
- **Clean Code vs. performance.** Small-function decomposition sometimes destroys cache locality and predictability (Muratori). In the critical 3%, measure and accept larger, data-oriented functions.
- **Comprehensive tests vs. shipping speed.** Coverage is a means, not an end; mutation score is a better metric; 100% coverage is both unachievable and not protective. Budget tests against risk: invariants in pure cores get property-based tests, integration boundaries get fakes, UI gets a thin E2E.
- **Fail-fast vs. availability.** Fail-closed on auth and invariants; fail-soft on environmental faults. Let-it-crash only inside a real supervisor.
- **Pinning vs. staying current.** Lockfile pins are a defense; range bumps are a liability until reviewed. Renovate/Dependabot with human-reviewed upgrades is the defensible middle.
- **Trunk-based vs. Gitflow.** TBD wins for SaaS per DORA; Gitflow still fits versioned, multi-release products. Driessen himself retracted for SaaS.
- **Comments helpful vs. harmful.** Martin: failure signal. Ousterhout: essential. Synthesis: comment *why*, docstring the interface, let the code speak for *what*.

---

## Candidate AGENTS.md directives

These are grouped by domain and written in imperative voice so they can be enforced in code review. Each one maps back to a justification in the sections above. **Adopt, reject, or tune per project; this is a menu, not a mandate.**

### Code quality and design

1. Name every symbol for its role; rename before committing if a reader would need the body to infer purpose.
2. Keep functions at a single level of abstraction; extract a helper only when the extraction names a reusable concept, not to satisfy a line count.
3. Prefer deep modules with narrow interfaces; do not introduce shallow pass-through layers or single-implementation interfaces that exist only for testing.
4. Do not introduce an abstraction until at least three divergent concrete uses exist; when an abstraction is straining under conditionals, inline it before re-abstracting.
5. Treat DRY as "one source of knowledge," not "no repeated tokens"; tolerate incidental duplication across unrelated domains.
6. Isolate side effects (I/O, clock, randomness, mutation) at module edges; keep core logic deterministic and pure.
7. Model expected failures as return values (`Result`/`Either`/`(T, error)`); reserve exceptions and `panic`/`unwrap` for invariant violations.
8. Never swallow errors silently; catch the narrowest exception you can handle and re-raise, log with context, or document the intentional swallow with a justification comment.
9. Fail fast on programmer errors; degrade gracefully on environmental ones; apply "let it crash" only inside a real supervisor.

### Readability and documentation

10. Prefer clear over clever; if a line needs a comment to be understood, first try to rewrite the line.
11. Use early-return guard clauses and keep the happy path unindented.
12. Let formatters own formatting (gofmt, rustfmt, black, prettier, clang-format); do not bikeshed style in review or reformat unrelated lines during a functional change.
13. Separate structural changes (rename, extract, reorder) from behavioral changes; ship them as distinct commits.
14. Write comments that explain *why* and capture non-obvious context (invariants, units, nullability, performance assumptions); never restate *what* the code already says.
15. Give every public symbol a docstring in the language's canonical format (Google/NumPy for Python; rustdoc with `# Errors`/`# Panics`/`# Safety`; godoc; TSDoc/JSDoc) that lets a caller use it without reading the body.
16. Record each architecturally significant decision as a Nygard-format ADR (`Title / Status / Context / Decision / Consequences`) in `doc/adr/NNNN-*.md`; supersede rather than edit accepted ADRs.
17. Every TODO/FIXME includes an owner and a tracked issue (`TODO(alice): handle unicode edge case (#1234)`); CI fails on bare TODOs.

### Testing

18. Mock only what you do not own (network, clock, filesystem, third-party APIs); assert observable outcomes, not call structure.
19. Do not mock the system under test's own public API.
20. Write test names as specifications; follow AAA/Given-When-Then; a failing test name alone should explain the failure.
21. Never silence a failing test to make CI pass; fix the cause or mark it `xfail`/`skip` with a linked issue.
22. Prefer property-based tests for invariants in pure cores; prefer fakes to mocks at integration boundaries.
23. Quarantine flaky tests immediately and fix or delete within a bounded window; flaky > failing trains engineers to ignore red.

### Security

24. Use parameterized queries or a vetted ORM; never concatenate user input into SQL, shell, LDAP, or template strings.
25. Validate input against an allow-list at trust boundaries and apply contextual output encoding (HTML, JS, URL, CSS) at the sink — not a single global `sanitize()`.
26. Authorize every request on the server at the resource level; deny by default; absence of an explicit allow is a deny.
27. Hash passwords with Argon2id at OWASP parameters (m=19 MiB, t=2, p=1 or m=46 MiB, t=1, p=1); fall back to scrypt, bcrypt (cost ≥10, ≤72-byte), or PBKDF2-HMAC-SHA-256 (FIPS only).
28. Use AES-GCM or ChaCha20-Poly1305 for symmetric encryption, X25519 for key exchange, Ed25519 for signatures; never roll your own crypto; never reuse a nonce.
29. Generate all tokens, session IDs, and secrets from a CSPRNG (`secrets.token_urlsafe`, `crypto.randomBytes`); never `Math.random()`.
30. Compare secrets, MACs, and tokens in constant time (`hmac.compare_digest`, `crypto.timingSafeEqual`); never `==`.
31. Never commit secrets; load from a vault or secret manager at runtime; prefer GitHub Actions OIDC → cloud IAM over long-lived static keys.
32. For JWTs: pin the algorithm server-side, verify the signature before trusting claims, validate `iss/aud/exp/nbf`, keep lifetimes short, never store secrets in the payload.
33. Never log passwords, full tokens, session cookies, API keys, PANs, or unnecessary PII; redact `Authorization` headers and OAuth `code` parameters; use field allow-lists.
34. Ship CSP (nonce/hash-based, no `unsafe-inline`), HSTS (`max-age≥31536000; includeSubDomains; preload`), `X-Content-Type-Options: nosniff`, and `Referrer-Policy: strict-origin-when-cross-origin` on every HTML response.
35. Prefer memory-safe languages (Rust, Go, TypeScript, Python, Java, C#) for new code; isolate C/C++ unsafe regions behind validated boundaries.

### Supply chain

36. Verify every new dependency exists on the official registry, has released within 12 months, has a non-trivial maintainer count or documented bus factor, and an acceptable OpenSSF Scorecard before adding it.
37. Prefer inlining ≤100-LOC utilities over adding a dependency; never hand-roll cryptography, Unicode, date/time, or auth.
38. Commit lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `poetry.lock`, `uv.lock`) for applications; do not ship lockfiles from libraries.
39. Pin exact versions with integrity hashes in lockfiles; use narrow ranges (`~x.y.z` for apps) in manifests; never use `*` or `latest`.
40. Publish internal packages under a reserved org scope and configure clients so that scope resolves *only* from the internal registry; reserve the names on public registries to preempt dependency confusion.
41. Build on an attested builder that produces signed SLSA provenance at Build L2 minimum (L3 for security-sensitive artifacts); generate a CycloneDX or SPDX SBOM per release; sign releases with Sigstore or equivalent and verify signatures in CI.
42. Disable package-manager lifecycle scripts by default in CI; maintain an explicit allow-list for packages that need them.

### Version control

43. One logical change per commit; never mix refactor + feature, formatting + logic, or vendored + hand-written code.
44. Every commit on `main` builds and passes tests on its own (bisectable).
45. Commit subjects in imperative mood, capitalized, ≤50 chars, no trailing period; blank line; body wrapped at 72 chars explaining *why*.
46. Use Conventional Commits (`feat`, `fix`, `!`/`BREAKING CHANGE:`) when release tooling consumes the history.
47. Default to trunk-based development; branches live ≤1 day and contain ≤~400 changed lines before merge.
48. Never force-push to shared branches; `--force-with-lease` is permitted only on unshared personal branches.
49. Protect `main`: require ≥1 non-author review, green CI, linear history, CODEOWNERS for sensitive paths, no direct pushes.
50. When trunk breaks, revert first and investigate on a branch; do not attempt roll-forward under time pressure.
51. Tag releases as signed, annotated `vMAJOR.MINOR.PATCH`; never re-tag a published release.

### Observability and performance

52. Emit structured logs (JSON or key-value) with a request/trace ID propagated via W3C Trace Context; never log secrets, tokens, or PII.
53. Instrument user-facing services with the four golden signals (latency, traffic, errors, saturation); measure p99/p99.9, not just means.
54. Profile before optimizing; commit the benchmark alongside the optimization; do not micro-optimize without evidence.
55. Fix algorithmic and architectural performance problems (N+1 queries, chatty RPC, missing indexes) before resorting to clever code; document any clever code with its benchmark.

### API, migrations, flags, idempotency, concurrency

56. Additive-only changes within a major version; breaking changes require a new major version and a deprecation window.
57. Never renumber, retype, or reuse a Protobuf field number; on delete, add the number and name to `reserved`.
58. Apply Parallel Change (expand → migrate → contract) to every breaking schema or interface change; deploy additive schema migrations before dependent code and column-drop code before dropping the column; test reversibility on a production-shaped replica.
59. Classify every feature flag as Release, Experiment, Ops, or Permission; tag release flags with an owner and removal date; fail the build on flags past their expiry.
60. Require an idempotency key on every mutating HTTP endpoint; cache the full response ≥24h; reject parameter-mismatched reuse; all retries use exponential backoff with jitter and respect `Retry-After`.
61. Prefer immutable data and message passing over shared mutable state; let the type system enforce thread safety (`Arc<Mutex<T>>`, `Send`/`Sync`, `@GuardedBy`); make check-and-act atomic to eliminate TOCTOU.

### Internationalization, accessibility, licensing, carbon

62. Encode text as UTF-8 end-to-end; store timestamps in UTC and convert at display boundaries; preserve the originating IANA timezone for future wall-clock events.
63. Route all user-facing text through ICU MessageFormat or Fluent with CLDR plural rules; never concatenate localized strings.
64. Meet WCAG 2.2 AA: semantic HTML first with ARIA only to fill gaps, keyboard operability and visible focus on every interactive element, 4.5:1 contrast for body text (3:1 for large and non-text UI), form labels and logical heading hierarchy.
65. Add `SPDX-License-Identifier:` in every new source file header; keep the repo REUSE-compliant; do not introduce AGPL, GPL, SSPL, BUSL, Elastic License, or Commons Clause dependencies without a documented license-compatibility note.
66. Right-size resources, shut down idle environments, and prefer carbon-aware scheduling (time- or region-shifting) for batch, ML training, and other latency-tolerant jobs.

### AI-agent-specific

67. Verify every import resolves to a real, well-established package on its official registry before adding it; reject packages with no history, no linked source repo, or trivial download counts.
68. Never invent CLI flags, function arguments, config keys, env vars, or file paths — run `--help`, grep the source, or read the docs first.
69. Run the code, execute the tests, and reproduce the behavior before claiming a task is done; "looks right" is not done.
70. Read nearby files before writing new code; match existing style, logger, error types, test layout, and naming; do not introduce a second HTTP client, logger, or ORM.
71. Do not modify files outside the task's stated scope; no drive-by formatting, dep bumps, or refactors without explicit approval.
72. Cite the primary source (official docs, RFC, spec, exact source file) for any non-obvious API or behavioral claim; when uncertain, stop and ask rather than fabricate.
73. Treat every AI-generated change as a draft from an over-confident junior: read it, run it, test it, and take responsibility for it before merging.

---

## Conclusion — what actually changes if you adopt this

The surprise in synthesizing this literature is **how much of it converges despite forty years of authorial feuds.** Saltzer and Schroeder's 1975 principles, Knuth's 1974 qualifier, Linus's "never break userspace," and CISA's 2023 *Secure by Design* are the same idea expressed in different vocabularies: the cost of a mistake compounds through every downstream user, so defaults should be safe, interfaces should be stable, and mechanisms should be simple enough to audit. The disagreements that remain — Martin vs. Ousterhout on comments and function size, Classicist vs. Mockist TDD, Charity Majors vs. the three pillars, data-oriented design vs. hotspot optimization — are real and should be resolved per project rather than finessed away.

For an AGENTS.md aimed at AI coding agents, the operative additions are narrow but critical: **verify packages exist, never invent APIs, read nearby code before writing, stay in scope, run the code, and never swallow errors.** These directives are not philosophy; they are direct responses to documented failure modes — Spracklen's 19.7% package-hallucination rate, GitClear's doubling of code churn, METR's 19%-slower-while-feeling-faster RCT, and the slopsquatting proof-of-concepts. The rest of the directives are the accumulated engineering wisdom that human reviewers already expect; the agent's job is to stop needing to be told.

The shortest honest summary of this report is that **quality engineering in 2026 is what it was in 1975, plus supply-chain paranoia, plus whatever is needed to keep AI-generated code from quietly poisoning the codebase.** Those three layers — the classical principles, the supply-chain overlay, and the AI-agent guardrails — are what the candidate directives above try to capture.
