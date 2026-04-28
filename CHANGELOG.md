# Changelog

All notable user-observable changes to this dotfiles repo are documented here.
Format inspired by [Keep a Changelog](https://keepachangelog.com).
Sections are dated (rolling) instead of versioned — each entry references the git short hash for exact traceability back to `git log`.

## v0.1.10 — 2026-04-27

- Updated the AI models used by the CLI for commit body generation, switching to a higher-capacity model (`openai/gpt-oss-120b`) for more accurate commit message creation.
- Updated the prompt model for changelog generation to `llama-3.3-70b-versatile` for improved output.
- Reordered configuration sections and tag definitions for better readability, explicitly defined `tui.theme` and `tui.use_nerd_fonts`, and removed the unused `change_analyzer_max_diff_size` entry.

## v0.1.9 — 2026-04-27

- Improved the commit body generator prompt to provide more comprehensive guidance for composing commit message bodies.
- Added an expanded instruction set that includes examples of proper and improper commit body formats, specifies present-tense third-person style requirements, and provides length guidelines based on change magnitude.

## v0.1.8 — 2026-04-27

### Changed

- Improved the commit title prompt in CommitCraft to generate more informative and concise titles.
- Introduced more examples for generating titles in common scenarios, such as improvements, fixes, and additions.
- Emphasized capturing the essence of all changes and provided guidance on handling multiple changes without a unifying theme.

## v0.1.7 — 2026-04-27

enhance changelog prompt with guidelines and examples

Improves the prompt for changelog generation in CommitCraft.

### [v0.1.6] - 2026-04-27
- Improves the prompt for synthesizing commit messages into coherent release notes by refining instructions for capitalization, formatting, and organization.
  • Updates the `commit.Body` reference to maintain consistent capitalization.
  • Refines guidelines for organizing release notes into structured sections with past tense, active voice, and bullet points.
    • Instructs users to prefix bullets with `-` instead of `*`
    • Specifies writing commit entries in past tense, active voice
    • Adds guidelines for classifying commit entries based on bracketed tags `[ADD]`, `[IMP]`, `[FIX]`, `[REM]`
  • Standardizes the output format for consolidated entries describing the same capability or incremental fixes.

# [v0.1.5] - 2026-04-27
### Prevents errors
### Added
- Prevents errors by adding a conditional check for the availability of the `go` command before loading the Go path.
  - Adds `if` statement to verify existence of `go` command using `command -v go >/dev/null 2>&1;`
  - Conditional loads Go path only if `go` command exists, preventing PATH updates when `go` is missing

# [v0.1.4] - 2026-04-27

- Updates commit configuration to align with the latest CommitCraft CLI version.

### Added
- `change_analyzer_prompt_file`, `change_analyzer_prompt_model`, `change_analyzer_max_diff_size`, `commit_body_generator_prompt_file`, `commit_body_generator_prompt_model`, `commit_title_generator_prompt_file`, `commit_title_generator_prompt_model`, `only_translate_prompt_model`, `changelog.path`, `changelog.bump_strategy`, `changelog.prompt_file`, `changelog.prompt_model` to `.config/CommitCraft/config.toml`.

### Removed
- Legacy configuration fields from `.config/CommitCraft/config.toml`:
- `summary_prompt_file`, `summary_prompt_model`, `summary_prompt_max_diff_size`, `commit_builder_prompt_file`, `commit_builder_prompt_model`, `outformat_prompt_file`, `outformat_prompt_model`.

## [v0.1.3] - 2026-04-27
-
Adds `cc` alias for `commitcraft` to facilitate easy access via short name.

## [v0.1.2] - 2026-04-27
-
Adds changelog functionality to commit message refiner.
 Introduces `refiner.md` to guide commit message entry generation
Modifies the code to include new refiner configuration section, enabling the functionality

## [v0.1.1] - 2026-04-26
-
Adds new changelog refiner functionality to CommitCraft's CLI.
  - Introduces `changelog_refiner.prompt` file to guide changelog entry generation
  - Modifies `config.toml` to include new changelog configuration section, enabling the functionality

## [v0.1.0] - 2026-04-26
- Removes old fzf-based commit workflow that has been replaced by the Commitcraft CLI, streamlining the commit process in `scripts/fzf-git-custom.sh`.\n  - Refactors `create_commit` function to eliminate intermediary steps and user prompts, simplifying logic and directly interacting with Git for committing changes.\n  - Removes temporary files used by the old workflow, enhancing code maintainability.\n  - Adapts commit process to align with the new CLI tool's functionality, potentially improving performance and reducing user errors.\n

## [Unreleased]

### Fixed
- `s` now tracks the last-sourced `.zshrc` hash **per shell session** (in-memory `_S_ZSHRC_HASH` variable) instead of the global state file, so with multiple terminals open none of them gets skipped just because another already updated the on-disk hash. Adds `-f`/`--force` flag to re-source even when the hash matches. Usage: `s` or `s -f`.

### Added
- `dotfiles force-cli` (alias `-fc`): interactive multi-select prompt (powered by `gum choose --no-limit`) to force-reinstall managed CLI tools — currently `commitcraft` and `cast` — bypassing the cached release tag in `~/.cache/dotfiles/state`. Useful when a binary is broken locally or you want to re-pull the same version. Usage:
  ```bash
  dotfiles force-cli
  # or
  dotfiles -fc
  # then space-toggle the tools you want and press enter
  ```

## [2026-04-26]

### Added
- `commitcraft` integration in the lazygit custom commit workflow: lets you reword a staged commit message via the `commitcraft` CLI from inside lazygit. (`d767813`)
- `cast` plugin enabled in the Neovim CLI integration. (`29fa7d4`)
- Global `cast` configuration so the CLI picks up consistent defaults across shells. (`6b97b70`)
- `.zshrc` support for the `cast` tool (PATH/aliases). Usage: just invoke `cast` in any new shell. (`e2facba`)
- `commitcraft` commit-analysis tooling introduced; available as a standalone CLI plus integration hooks. (`6c37ae4`)
- `.commitcraft.toml` feature configuration consumed by the `commitcraft` CLI. (`6e3e926`)

### Changed
- `scripts/dotfiles.sh`: introduced state file at `~/.cache/dotfiles/state` and the `_dotfiles_update_cli` helper. `dotfiles update` now fetches the latest GitHub release tag for `commitcraft` and `cast`, compares against the cached tag, and skips reinstall when up to date. Usage:
  ```bash
  dotfiles update   # or: dotfiles -u
  ```
  (`8e7797c`)
- `.zshrc`: efficiency checks added; the `s` helper now SHA-compares `.zshrc` against its last-sourced hash and skips re-sourcing when unchanged. Usage: run `s` instead of `source ~/.zshrc`. (`83aaa51`)
- `CommitCraft`: improved commit-title prompt rules. (`f46da84`)
- `CommitCraft`: prevents the model from wrapping output in markdown code blocks. (`e31d5aa`)
- `CommitCraft`: general commit-prompt improvements. (`1b87d1b`)
- `CommitCraft`: commit-message optimization pass. (`ad969e5`)
- `lazygit` custom commit workflow: now exposes a `commitcraft` output option. (`95740be`)
- `templates/`: Odoo 19 support added; initial addon version standardized to `0.0.0`. (`433afa3`)
- `scripts/`: directory-selection validation hardened in the `fzf-make` script. (`6cd0f70`)
