# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

Personal dotfiles managing zsh, Neovim, Ansible playbooks, shell scripts, and a small set of self-managed CLI tools (`commitcraft`, `cast`). Not a public project — no consumers, no SemVer.

## Key files and locations

- `scripts/dotfiles.sh` — `dotfiles` shell function (`update`, `force-cli`, `install`), CLI release-tag state cache at `~/.cache/dotfiles/state`, and the `s` helper for re-sourcing `.zshrc`.
- `tools/install_github_release.sh` — installer used by `_dotfiles_update_cli` to fetch a binary from a GitHub release.
- `ansible/sites.yml` — entrypoint for `dotfiles install`.
- `home/` — files materialized into `$HOME`.
- `templates/` — scaffolding templates (Odoo addons, etc.).

## Commit conventions

Commit messages use a tag prefix:

- `[ADD]` — new feature, file, or capability.
- `[IMP]` — improvement to existing behavior.
- `[FIX]` — bug fix.
- `[STYLE]` — formatting, comments, cosmetic-only changes.
- `[REM]` — removal.

These tags map directly to changelog categories (see below).

## Changelog rule (mandatory)

This repo maintains `CHANGELOG.md` as a complement to `git log`: commits explain *what* changed, the changelog explains *how to use* it.

**When to add an entry:** any change that is observable by the user — a new script, function, flag, command, behavior change, or removal. Skip pure refactors, formatting, comment edits, and `[STYLE]`-only commits unless the user asks.

**Where:** under the `## [Unreleased]` section at the top of `CHANGELOG.md`. Do not create a new dated section unless the user explicitly requests a "cut".

**Language:** English.

**Category mapping (subsection under the dated/Unreleased heading):**

| Commit tag | Changelog section |
|------------|-------------------|
| `[ADD]`    | `### Added`       |
| `[IMP]`    | `### Changed`     |
| `[FIX]`    | `### Fixed`       |
| `[REM]`    | `### Removed`     |
| `[STYLE]`  | (omit)            |

**Entry format:**

```
- <one-line summary of what the user can now do or what changed>. Usage: <inline command, or a fenced ```bash block for multi-line>. (`<git-short-hash>`)
```

- Include the **git short hash** in backticks at the end when the change is already committed. If the change is not yet committed, omit the hash; a follow-up edit (or the next commit) can add it.
- Every entry that introduces a new tool, flag, or invocation **must show a usage example**, not just a description. Use a fenced ` ```bash ` block when the example is more than one line.
- One change = one entry. Don't bundle unrelated changes into a single bullet.

**Cutting a dated section:** only when the user asks, or naturally when `Unreleased` accumulates more than ~5–10 entries. Replace `## [Unreleased]` with `## [YYYY-MM-DD]` and add a fresh empty `## [Unreleased]` above it.

**No SemVer.** No version numbers, no git tags for releases, no `VERSION` file. Sections are dated (rolling).

## Working style in this repo

- Edit existing files; avoid creating new top-level files unless asked.
- After editing `scripts/dotfiles.sh` or anything sourced by `.zshrc`, mention that the user should run `s` (the cached re-source helper) to pick up changes.
- The `gum` CLI is available for interactive prompts (`gum choose`, `gum spin`, `gum_log_*` wrappers defined elsewhere in the repo).
