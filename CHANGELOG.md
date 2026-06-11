# Changelog

All notable user-observable changes to this dotfiles repo are documented here.
Format inspired by [Keep a Changelog](https://keepachangelog.com).
Versioning is **CalVer** (`vYYYY.MM.DD`, with `.N` suffix when more than one cut lands on the same day). Each entry references a git short hash where available for traceability back to `git log`.

## [v2026.6.10] - 2026-06-10

### Added

- `echo_cli` (Cerebellum-ITM/Echo) is now managed by the dotfiles CLI auto-updater: `dotfiles -u` checks its latest release and installs/updates it, and it can be force-reinstalled via `dotfiles -fc`. Usage:
  ```bash
  dotfiles -u        # updates echo_cli alongside commitcraft/cast/teleport
  dotfiles -fc       # pick echo_cli from the list to force reinstall
  ```
- Added `ec` alias for the `echo_cli` CLI in `.zshrc`. Usage: `ec <args>`.

### Changed

- `dotfiles -u` now prints a consolidated update summary (per-CLI status — up to date / version bump / failed — plus the dotfiles repo status) right before it re-sources `.zshrc`, so the recap survives the screen-clearing newline flush and stays readable in scrollback. Usage: `dotfiles -u`.

## [v2026.5.29] - 2026-05-29

### Changed

- oh-my-posh right prompt now hides segments progressively as the terminal narrows: `sysinfo` hides below 200 cols, `node`/`php`/`npm` below 180, `shell` below 160, `user@host` below 140, `executiontime` below 110, and `time` below 80 — left prompt (path, git, repo-status icons) is always visible at any width. (`prompt_config.toml`)

## [v2026.5.16] - 2026-05-15

### Added

- Added numpad-based keybindings for creating, navigating, and resizing splits in Ghostty, including shortcuts for moving focus and resizing splits.
- Updated `home/.config/ghostty/config` with the new keybindings and documented the reload shortcut.

## [v2026.5.15] - 2026-05-15

### Added

- Added Ghostty keybindings for split management driven by the numpad in a directional cross (4/6/8/2 = left/right/up/down). `cmd+shift+kp_*` creates a split, `cmd+kp_*` moves focus between splits, and `cmd+alt+kp_*` resizes the active split by 10 px. Reload Ghostty's config to apply:
  ```bash
  # in Ghostty
  cmd+shift+,
  ```

## [v2026.5.12] - 2026-05-11
Added a `tp` alias to `.zshrc` that forwards all arguments to the `teleport` command, enabling `tp <args>` as a shortcut for `teleport <args>`.

## [v2026.5.11] - 2026-05-11

### Added

- Added `tp` alias for the `teleport` CLI in `.zshrc`. Usage: `tp <args>`.

## [v2026.5.11] - 2026-05-08

- Fixed the malformed terminal override for `Ms` in `~/.tmux.conf` to correctly propagate OSC 52 clipboard data to Ghostty both locally and over SSH.
- Updated copy-mode-vi bindings for `y` and `MouseDragEnd1Pane` to use `copy-pipe-and-cancel` with a fallback chain of `pbcopy`, `xclip`, or `wl-copy`, ensuring local clipboard synchronization.

## [v2026.5.10] - 2026-05-08

### Fixed

- Tmux clipboard forwarding now actually works end-to-end (locally and over SSH from a Ghostty Mac client). Two issues were fixed: (1) the `Ms` terminal-override was malformed — it hardcoded `c` and only used `%p2%s`, which broke tmux's `set-clipboard on` re-emission; replaced with the canonical `\E]52;%p1%s;%p2%s\7`. (2) `y` and `MouseDragEnd1Pane` in copy-mode-vi now use `copy-pipe-and-cancel` with a `pbcopy → xclip → wl-copy` fallback so the selection lands in the local clipboard tool *and* tmux still emits OSC 52 to the outer terminal — both paths fire, the right one wins per environment. After pulling: ```bash
rm -rf ~/.tmux/plugins/tmux-yank   # only if not already removed
tmux kill-server
```

### Removed

- Removed the `tmux-yank` plugin from `~/.tmux.conf` to prevent interference with OSC 52 clipboard forwarding.

## [v2026.5.9] - 2026-05-05

### Changed

- Enabled programs running inside tmux to emit DCS‑wrapped OSC 52 sequences directly to the outer terminal by setting `allow-passthrough on` in `~/.tmux.conf`.
- Configured Ghostty with unconditional clipboard access by setting `clipboard-write = allow`, `clipboard-read = allow`, and `clipboard-trim-trailing-spaces = true`, stabilizing OSC 52 behavior over SSH and preventing intermittent copy failures.

## [v2026.5.8.2] - 2026-05-05

### Changed

- Tmux now enables `allow-passthrough on`, so programs running inside tmux can emit DCS-wrapped OSC 52 sequences directly to the outer terminal as a fallback when `set-clipboard` forwarding misbehaves.
- Ghostty is configured to accept OSC 52 unconditionally with `clipboard-write = allow`, `clipboard-read = allow`, and `clipboard-trim-trailing-spaces = true` in `home/.config/ghostty/config`. Without this, Ghostty's default policy can silently drop or queue clipboard writes, producing intermittent behavior over SSH. Reload Ghostty (`Cmd+Shift+,`) for the new policy to apply.

## [v2026.5.8] - 2026-05-08
### Added

- Added `teleport` (`Cerebellum-ITM/teleport`) as a managed CLI: it is now updated automatically on `dotfiles update` and available for force-reinstall via `dotfiles force-cli`.

### Fixed
- Fixed OSC 52 clipboard forwarding by relocating the terminal-overrides configuration after TPM loading and broadening the terminal pattern to apply to all terminal types.
- Restored end-to-end clipboard copy from remote tmux/Neovim (over SSH from a Ghostty Mac client) to the local macOS clipboard by removing the `tmux-yank` plugin, which was hijacking `y` and `MouseDragEnd1Pane` to call `pbcopy`/`xclip`/`wl-copy` on the *remote* host and breaking the OSC 52 chain. Native `copy-selection-and-cancel` + `set-clipboard on` now drives both keyboard yank and mouse-drag copy. After pulling, run: ```bash
rm -rf ~/.tmux/plugins/tmux-yank
tmux kill-server
```

## [v2026.5.7] - 2026-05-05

### Fixed

- OSC 52 clipboard forwarding through tmux now actually works. The `set-clipboard on` and `Ms` capability lines were being overwritten at startup by `tmux-sensible` (loaded via TPM), which silently reset `terminal-overrides`. Moved both lines to the end of `home/.tmux.conf`, after `run '~/.tmux/plugins/tpm/tpm'`, and broadened the pattern from `xterm*` to `*` so it also matches `xterm-ghostty`, `screen-*`, etc. Reload with `tmux kill-server` to pick it up.

- Added OSC 52 clipboard synchronization for Neovim over SSH, enabling seamless copy-paste between remote Neovim and the host terminal.
- Configured tmux to forward OSC 52 sequences, enhancing clipboard functionality.

## [v2026.5.6] - 2026-05-05

### Added

- Neovim now syncs its clipboard to the local machine's clipboard over SSH via OSC 52 escape sequences. When `$SSH_TTY` is set, the `+` and `*` registers route through `vim.ui.clipboard.osc52`, so `yy` (with `clipboard=unnamedplus` already on) lands in the local Mac/Linux clipboard. Requires reopening nvim after pulling.
- Tmux now forwards OSC 52 clipboard sequences to the outer terminal, so programs running inside tmux (notably Neovim over SSH) can write to the local clipboard. Verify with:
  ```bash
  printf '\033]52;c;%s\a' "$(printf 'hello' | base64)"
  ```
  inside tmux and pasting locally. Reload with `tmux kill-server` to pick up the new `terminal-overrides`.

### Changed

- Removed the operating system guard from the ~/.local/bin export in .zshrc, allowing the directory to be added to PATH on all supported platforms.

## [v2026.05.05] - 2026-05-05

### Fixed

- `~/.local/bin` is now exported into `PATH` on macOS as well, not only on Linux. Previously the export was guarded by `OSTYPE == linux-gnu*`, so binaries installed there by `tools/install_github_release.sh` (e.g. `commitcraft`, `cast`) were invisible on Macs that didn't have `~/.local/bin/env` (uv/rustup) sourcing the directory as a side effect. Pull the dotfiles and run `s` to pick it up.

## [v2026.5.2] - 2026-05-01

- Reduced the maximum prompt depth in the oh-my-posh configuration to 2, limiting the display to the current folder and its parent directory.

## [v2026.05.01] - 2026-05-01

- Added three new prompt files to the CommitCraft CLI to support automated release-note generation: `release_body.prompt`, `release_refine.prompt`, and `release_title.prompt`.

### Changed

- Oh-my-posh prompt now shows only 2 path levels (current folder and its parent) instead of 3. Edit in `home/.oh-my-posh/prompt_config.toml` (`max_depth = 2`).

## [v2026.04.30] - 2026-04-30

### Added

- New `wt` shell function (`scripts/wt.sh`) to manage git worktrees end-to-end via `gum`. Subcommands: `new` (interactive create, with optional `--go` to build `./bin/<name>` and emit a sourceable `./activate` that prepends `bin/` to `PATH`), `cd` (picker → cd to worktree), `ls` (table with branch + clean/dirty + ★ on the primary), `rm` (picker with confirm and `--force` fallback for dirty/locked worktrees), `main` (cd to the primary worktree), `prune` (`git worktree prune -v`). New worktrees automatically receive `.env` and `.commitcraft.toml` from the source repo if present. Reload with `s -f`, then:
  ```bash
  wt new            # interactive: pick/create branch, confirm, creates <repo>-<branch>
  wt new --go       # also builds Go binary into ./bin and writes ./activate
  wt cd             # pick a worktree and cd into it
  wt ls             # list worktrees with state
  wt rm             # pick worktree(s) to remove
  wt main           # cd to the primary worktree
  wt prune          # garbage-collect worktree refs
  ```

### Fixed

- `wt` was unusable in zsh: a local variable named `path` inside `_wt_cd`/`_wt_rm`/`_wt_list` collided with zsh's tied `path` array (the lowercase mirror of `PATH`), silently emptying `PATH` mid-function and producing confusing errors like `command not found: gum` and `command not found: awk`. Renamed the local to `wt_path` and dropped the `awk` dependency entirely (replaced with `case` + parameter expansion), which also makes the script portable to environments where `awk` is not on `PATH`. As a side effect, `wt rm` is now single-select (Enter on the highlighted row, with a confirm step) instead of the previous space-toggle multi-select that was confusing in practice. (`d6580cd`)

## [v2026.04.29] - 2026-04-29

### Changed

- Rewrote `tools/gum_styles.sh` to emit truecolor ANSI directly via `printf` instead of forking `gum style` once per fragment. Public API is unchanged — every wrapper (`gum_green`, `gum_yellow_bold`, `git_strong_white_dark`, `gum_custom_color_style`, `gum_print_styles`, etc.) keeps the same name, signature, and color, so no call sites in the repo need to change. Each colored log line in `dotfiles update` and similar flows now spawns ~0 extra processes instead of 3–5, making logs feel instant. As a side effect, message bodies passed via `$(gum_color "...")` into `gum log` now actually display in color — previously `gum style` stripped ANSI in command-substitution contexts and only the timestamp/level were colored. `gum` itself is still used everywhere it adds value: `gum log`, `gum spin`, `gum choose`, `gum confirm`, `gum format`. Reload with:
  ```bash
  s -f
  ```
- Refactored `scripts/fzf-git-custom.sh`: `create_commit` is split into `_do_commit <current|parent>` and `_maybe_push <current|parent>` (preserves push-toggle semantics via `/tmp/fzf_git_commit_options`); the `--commit`/`--commit-submodule` branches now share `_run_commit_flow`; the `if/elif` dispatcher in `fzf-git` is now a `case`; tmp-file paths are centralized as `FZF_GIT_*` constants. The legacy `create_commit module|submodule` entry point still works as a shim.
- Stubbed the changelog auto-write inside the commit flow. `_check_for_changelog` and `_write_in_changelog` now emit a `gum_log_debug` "skipped (WIP)" message and do nothing — pending a dedicated changelog flow (TODO in the file).

### Fixed

- Renamed the misspelled log helper `gun_log_fatal` → `gum_log_fatal` across `tools/gum_log_functions.sh`, `tools/lazygit-custom-commit-workflow.sh`, `scripts/fzf-make.sh`, `scripts/odoo.sh`, and `scripts/fzf-git-custom.sh`. No remaining `gun_log_fatal` references.
- Restored per-mode prompt icons in `tools/check_repo_status.sh` that were lost when the three status scripts were unified: `dotfiles` mode now shows `` (`U+EAFD`) when the repo is in sync, and `parent` mode shows `` (`U+F4DC`) when an `*addons*` directory is out of sync. `current` mode keeps `󰊢` for out-of-sync.
- Stopped drawing the offline icon (`󱛅`) in the prompt. The bg `git fetch` still runs and the segment fills in on the next prompt with fresh data; previously every first prompt into a repo with stale/missing fetch cache flashed `󱛅` for ~30 s while the async fetch finished, which was indistinguishable from a real failure.

## [v2026.04.28] - 2026-04-28

### Added

- `gretime` shell function (`scripts/git_retime.sh`) to rewrite the date of an existing commit through a `gum`-based UI: pick a commit from the last N (or pass a hash to skip the picker), choose *Now* (sets author + committer to current time), *Custom* (`YYYY-MM-DD HH:MM:SS`), or *Sync* (align committer to author date). Detects BSD vs GNU `date`, warns when the commit is already pushed, and uses `git rebase -i` programmatically for non-HEAD commits. Usage:
  ```bash
  gretime          # pick from last 20 commits
  gretime 50       # pick from last 50 commits
  gretime <hash>   # re-time that commit directly
  ```
- `T` keybinding in `lazygit` (commits context) that runs `tools/lazygit-gretime.sh` against the selected commit, exposing `gretime` from inside lazygit.
- Visual status icons in `tools/check_repo_status.sh` for synchronized and offline states.

### Changed

- Replaced the three per-prompt status scripts (`check_parent_directory_status.sh`, `check_current_directory_status.sh`, `check_dotfiles_status.sh`) with a single `tools/check_repo_status.sh` that takes a mode argument. Removes the synchronous `ping google.com` call and collapses 4 git invocations per check into 1, dramatically reducing post-command prompt latency. Usage:
  ```bash
  check_repo_status.sh current   # status of the repo at $PWD
  check_repo_status.sh parent    # status of parent repo when $PWD matches *addons*
  check_repo_status.sh dotfiles  # status of $HOME/dotfiles vs origin/main
  ```
- Tuned `home/.oh-my-posh/prompt_config.toml` segment caching: `os`, `sysinfo`, `shell`, `host` cached `24h`; `node`, `php`, `npm` cached `5m`; the three `command` segments cached `30s`. Removed `fetch_upstream_icon` from the `git` segment (now handled by the unified status script).
- Improved zsh startup time in `home/.zshrc`: deferred `zsh-syntax-highlighting`, `zsh-completions`, `zsh-autosuggestions`, and `fzf-tab` via `zinit wait lucid`; cached `compinit` (full rebuild at most once per 24 h); replaced `go env GOPATH` lookup with a direct `$HOME/go/bin` reference; removed duplicate `fzf --zsh` and duplicate `atuin init` invocations; fixed a typo (`"STERM PROGRAM"` → `"$TERM_PROGRAM"`) that prevented oh-my-posh from being skipped on Apple Terminal.
- Refined error output handling in `check_repo_status.sh` to suppress consecutive "no connection" messages.

### Fixed

- Terminal closure error when invoking the alias `s -f` by handling flags locally and preventing unintended termination.

### Removed

- Deleted `tools/check_parent_directory_status.sh`, `tools/check_current_directory_status.sh`, and `tools/check_dotfiles_status.sh` (superseded by `tools/check_repo_status.sh`).

## [v2026.04.27] - 2026-04-27

### Added

- Conditional check for the availability of the `go` command before loading the Go path (only updates `PATH` when `go` is present).
- `change_analyzer_prompt_file`, `change_analyzer_prompt_model`, `change_analyzer_max_diff_size`, `commit_body_generator_prompt_file`, `commit_body_generator_prompt_model`, `commit_title_generator_prompt_file`, `commit_title_generator_prompt_model`, `only_translate_prompt_model`, `changelog.path`, `changelog.bump_strategy`, `changelog.prompt_file`, `changelog.prompt_model` keys to `.config/CommitCraft/config.toml`.

### Changed

- Enhanced the CommitCraft change-analyzer prompt: added a description of the generated output's purpose and refined instruction wording. Documented the output purpose and its downstream consumption. Optimized prompt content for lower token count and improved summary accuracy.
- Switched the CLI commit-body-generation model to `openai/gpt-oss-120b` for more accurate messages, and the changelog-generation model to `llama-3.3-70b-versatile`. Reordered configuration sections and tag definitions for readability, explicitly defined `tui.theme` and `tui.use_nerd_fonts`, removed the unused `change_analyzer_max_diff_size`.
- Improved the commit-body-generator prompt with more comprehensive guidance: examples of proper/improper formats, present-tense third-person style, and length guidelines based on change magnitude.
- Improved the commit-title prompt in CommitCraft: more examples for common scenarios (improvements, fixes, additions), emphasis on capturing the essence of all changes, and guidance on handling multiple changes without a unifying theme.
- Enhanced the changelog-generation prompt with guidelines and examples.
- Refined the release-notes synthesis prompt: consistent capitalization (`commit.Body`), structured sections in past tense / active voice, bullets with `-` instead of `*`, classification by bracketed tags `[ADD]`/`[IMP]`/`[FIX]`/`[REM]`, and a standardized format for consolidated entries.

### Removed

- Legacy fields from `.config/CommitCraft/config.toml`: `summary_prompt_file`, `summary_prompt_model`, `summary_prompt_max_diff_size`, `commit_builder_prompt_file`, `commit_builder_prompt_model`, `outformat_prompt_file`, `outformat_prompt_model`.

## [v2026.04.26] - 2026-04-26

### Added

- `cc` alias for `commitcraft` (short-name access).
- Changelog functionality in the commit-message refiner: `refiner.md` guides commit-message entry generation; new refiner configuration section enables it.
- Changelog refiner functionality in the CommitCraft CLI: `changelog_refiner.prompt` guides changelog entry generation; new section in `config.toml` enables it.
- `commitcraft` integration in the lazygit custom commit workflow: reword a staged commit message via the `commitcraft` CLI from inside lazygit. (`d767813`)
- `cast` plugin enabled in the Neovim CLI integration. (`29fa7d4`)
- Global `cast` configuration so the CLI picks up consistent defaults across shells. (`6b97b70`)
- `.zshrc` support for the `cast` tool (PATH/aliases). (`e2facba`)
- `commitcraft` commit-analysis tooling (standalone CLI plus integration hooks). (`6c37ae4`)
- `.commitcraft.toml` feature configuration consumed by the `commitcraft` CLI. (`6e3e926`)
- `dotfiles force-cli` (alias `-fc`): interactive multi-select prompt (`gum choose --no-limit`) to force-reinstall managed CLI tools (`commitcraft`, `cast`), bypassing the cached release tag in `~/.cache/dotfiles/state`. Usage:
  ```bash
  dotfiles force-cli
  # or
  dotfiles -fc
  ```

### Changed

- Removed the old fzf-based commit workflow (replaced by the CommitCraft CLI) in `scripts/fzf-git-custom.sh`. Refactored `create_commit` to eliminate intermediary steps and prompts; removed temp files used by the old workflow.
- `scripts/dotfiles.sh`: introduced state file at `~/.cache/dotfiles/state` and the `_dotfiles_update_cli` helper. `dotfiles update` now fetches the latest GitHub release tag for `commitcraft` and `cast`, compares against the cached tag, and skips reinstall when up to date. Usage:
  ```bash
  dotfiles update   # or: dotfiles -u
  ```
  (`8e7797c`)
- `.zshrc`: the `s` helper now SHA-compares `.zshrc` against its last-sourced hash and skips re-sourcing when unchanged. Usage: `s` (instead of `source ~/.zshrc`). (`83aaa51`)
- CommitCraft prompt improvements: title-prompt rules (`f46da84`), prevents wrapping output in markdown code blocks (`e31d5aa`), general commit-prompt improvements (`1b87d1b`), commit-message optimization pass (`ad969e5`).
- `lazygit` custom commit workflow: exposes a `commitcraft` output option. (`95740be`)
- `templates/`: Odoo 19 support added; initial addon version standardized to `0.0.0`. (`433afa3`)
- `scripts/`: directory-selection validation hardened in `fzf-make`. (`6cd0f70`)

### Fixed

- `s` now tracks the last-sourced `.zshrc` hash **per shell session** (in-memory `_S_ZSHRC_HASH`) instead of the global state file, so with multiple terminals open none of them gets skipped just because another already updated the on-disk hash. Adds `-f`/`--force` flag to re-source even when the hash matches. Usage: `s` or `s -f`.
