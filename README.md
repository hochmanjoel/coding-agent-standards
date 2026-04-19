# coding-agent-standards

My working agreement for AI coding agents — Claude Code, Codex, Cursor, Aider, and anything else that reads `AGENTS.md` — packaged as versioned markdown templates with a small CLI that keeps them in sync across projects.

## One-time install

```sh
curl -fsSL https://raw.githubusercontent.com/hochmanjoel/coding-agent-standards/main/install.sh | bash
```

That clones this repo to `~/.local/share/coding-agent-standards` and puts an `agent-docs` command on your PATH. Run once per machine.

If you prefer to inspect before running, `install.sh` is short — read it, then run it.

---

## The three scenarios

### 1. Starting a new project

```sh
mkdir my-new-project && cd my-new-project
git init
agent-docs init
```

That's it. `init` does everything:

- Creates all six template files
- Creates a `CLAUDE.md` symlink pointing at `AGENTS.md` (so Claude Code finds it)
- Registers the project so `agent-docs status-all` and `agent-docs sync-all` can find it later

Then fill in `DEVELOPMENT.md` with your install/test/run commands, commit, and you're done.

### 2. Adding the docs to an existing project

Same command.

```sh
cd my-existing-project
agent-docs init
```

If any of the template files already exist unmanaged (e.g. the repo already had its own `CHANGELOG.md`), `agent-docs` leaves them alone and tells you. You'll want to reconcile those manually — usually by backing up the old file, running `init`, then merging content into the new template.

### 3. Updating the docs in an existing project

```sh
cd my-project
agent-docs sync
```

`agent-docs` automatically fetches the latest templates from GitHub before comparing versions, so you don't need to remember to pull anything first. For each file that has upstream changes, it shows you:

- The version bump (`0.1.0 → 0.2.0`)
- The relevant `CHANGES.md` entries explaining what actually changed
- For `durable` files (`AGENTS.md`): a diff, then a y/N prompt
- For `seed-once` and `per-project` files: it bumps the header version but never touches the body, so your `DECISIONS.md` / `RESEARCH.md` / `TODO.md` / `CHANGELOG.md` / `DEVELOPMENT.md` content is always preserved

Want to update *every* project on your machine? `agent-docs sync-all`. Want to preview first? `agent-docs status-all` or `agent-docs check`.

---

## Command reference

| Command | What it does |
|---|---|
| `agent-docs init` | First-time setup in the current project (creates files, CLAUDE.md symlink, registers project) |
| `agent-docs status` | Show local vs upstream versions for the current project |
| `agent-docs check` | Dry-run of what `sync` would change |
| `agent-docs sync` | Apply upgrades (prompts for durable files) |
| `agent-docs sync --force` | Apply without prompting (use carefully) |
| `agent-docs status-all` | One-line status for every registered project |
| `agent-docs sync-all` | Run `sync` across every registered project |
| `agent-docs update` | Just pull the source repo (usually automatic) |
| `agent-docs projects` | List registered projects |
| `agent-docs forget` | Unregister the current project |

All commands are safe to run from anywhere inside a project's directory tree — they act on `$PWD`.

---

## What's in the templates

| File | Kind | Behavior on upgrade |
|---|---|---|
| `AGENTS.md` | durable | Can be overwritten; prompts before doing so. This is the cross-project working agreement itself. |
| `DEVELOPMENT.md` | per-project | Never overwritten. Header version bumps so you stop getting nagged; body is yours. |
| `DECISIONS.md` | seed-once | Never overwritten. Append-only ADR log. |
| `RESEARCH.md` | seed-once | Never overwritten. Exploration log — things tried, dead ends, sources. |
| `TODO.md` | seed-once | Never overwritten. Short priority list (not a bug tracker). |
| `CHANGELOG.md` | seed-once | Never overwritten. Keep-a-Changelog format. |

Each template has a JSON header that the tool reads; don't edit or delete it.

---

## Releasing a new version of a template

1. Edit the template file under `templates/`.
2. Bump the `version` field in that template's JSON header.
3. Add entries to `CHANGES.md` under a new `## X.Y.Z — YYYY-MM-DD` heading. Use the exact filename as the sub-heading (e.g. `### AGENTS.md`).
4. Commit and push.
5. Users pick up the change the next time they run any `agent-docs` command — the tool auto-fetches the source repo before comparing versions.

---

## Configuration

- **Source location:** defaults to `~/.local/share/coding-agent-standards`. Override with `AGENT_DOCS_SOURCE=/path/to/repo`.
- **Registered projects:** stored in `~/.config/coding-agent-standards/projects`, one path per line. Edit freely.
- **Auto-fetch behavior:** the tool runs `git fetch` with a 5-second timeout before any status/sync. If you're offline, it continues silently. To skip entirely: `--no-fetch`.

---

## FAQ

**What if I'm offline?**
Everything still works using the local copy of the templates. The fetch has a 5-second timeout, so you won't be stuck waiting.

**What if I don't want a project registered?**
Run `agent-docs forget` from inside that project.

**What if Windows symlinks don't work?**
`init` falls back to copying `AGENTS.md` to `CLAUDE.md` instead of symlinking. You'll have two files to keep in sync — or run `git config --global core.symlinks true` in Developer Mode and re-run `init` to get the real symlink.

**What if I already have an `AGENTS.md` or `CLAUDE.md`?**
`init` leaves unmanaged files alone. You'll need to back them up, `init` the new template, and merge your content. A proper `adopt` command for this case is a planned improvement.

**Why is `AGENTS.md` "durable" but `DEVELOPMENT.md` "per-project"?**
`AGENTS.md` is the shared working agreement — same principles in every project — so it's worth overwriting to pick up upstream improvements. `DEVELOPMENT.md` is per-project content (install commands, gotchas) that's meaningless to overwrite.

**Why not a GitHub template repo?**
Template repos only help for new projects. They can't push updates to existing repos, which is the main use case for this.
