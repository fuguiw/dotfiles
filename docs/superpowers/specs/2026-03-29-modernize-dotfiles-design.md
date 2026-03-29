# Modernize Dotfiles Design

## Background

The repository currently contains a small set of legacy dotfiles for macOS:

- `git/gitconfig`
- `git/gitignore_global`
- `zsh/zshrc`
- `tmux/tmux.conf`
- `vim/vimrc`
- `iterm2/*`

The existing files are outdated and contain machine-specific assumptions from an older environment. The current machine has a broader set of user preferences spread across home-directory dotfiles and `~/.config`, but those files also include work-specific aliases, internal domains, local project paths, generated state, and potentially sensitive values.

The goal is to rebuild this repository as a maintainable dotfiles source of truth for reusable personal configuration only.

## Goals

- Collect reusable personal and tool configuration from the current machine.
- Exclude work-specific, account-specific, secret, generated, and runtime state.
- Restructure the repository to support a single installation entrypoint.
- Preserve local override capability for values that should never live in git.
- Keep the resulting setup easy to extend for future tools.

## Non-Goals

- Mirroring the full home directory.
- Backing up tokens, cookies, socket paths, caches, histories, or tool databases.
- Preserving obsolete configuration systems purely for nostalgia.
- Managing every installed application on the machine.

## Design Principles

### 1. Repository mirrors destination roots

The repository will separate files by destination root:

- `home/` maps to `~/`
- `config/` maps to `~/.config/`

This keeps installation logic predictable and avoids per-tool ad hoc rules.

### 2. Prefer portable configuration over exact machine clones

Any config copied from the machine must be normalized:

- Replace hard-coded home paths with `$HOME` where appropriate.
- Remove work hostnames, internal domains, corp-only aliases, and project paths.
- Avoid assumptions about a single package manager path when reasonable.
- Guard optional tool initialization behind existence checks.

### 3. Sensitive and runtime state is always excluded

The repository must not contain:

- authentication tokens
- API keys
- tool session history
- host-specific trust databases
- generated caches
- local sockets
- runtime logs
- work-restricted configuration

### 4. Local-only overrides remain possible

Some tools require machine-local identity or secrets. Those settings should be loaded from files that are not tracked by git, such as:

- `~/.gitconfig.local`
- future tool-specific local overrides if needed

## Repository Layout

```text
home/
  .zprofile
  .zshrc
  .p10k.zsh
  .gitconfig
  .gitconfig.local.example
  .tmux.conf
  .claude/
    CLAUDE.md
    settings.json
  .codex/
    AGENTS.md
    config.toml
config/
  fish/
    conf.d/
      uv.env.fish
  gh/
    config.yml
  git/
    ignore
scripts/
  install.sh
README.md
Makefile
```

## Selected Configuration Scope

### Included

- Shell bootstrap: `~/.zshrc`, `~/.zprofile`
- Prompt: `~/.p10k.zsh`
- Git defaults and ignore rules
- Tmux base configuration
- Lightweight CLI tool preferences:
  - `gh`
  - `fish` helper env file
  - selected `claude` files
  - selected `codex` files

### Excluded

- `raycast/extensions/*`
  - installed extension payloads, not user-authored stable preferences
- `~/.claude/history.jsonl`, caches, todos, debug files, telemetry
- `~/.codex/auth.json`, state databases, logs, archived sessions, trust maps with work paths
- `~/.config/gh/hosts.yml`
  - contains authenticated host data
- work aliases and corp environment from current `~/.zshrc`
- work project paths and trusted project lists from current `~/.codex/config.toml`
- old `vim` and `iterm2` content unless later proven worth reviving

## Installation Design

The installation entrypoint will be `scripts/install.sh`.

Responsibilities:

- Detect repository root.
- Create required parent directories.
- Backup existing destination files before replacing them.
- Create symlinks from repository files into `~/` and `~/.config/`.
- Skip installation of files that do not exist in the repository.
- Be safe to re-run.

Backup strategy:

- Existing non-symlink files are moved to a timestamped backup directory under the user's home directory.
- Existing symlinks pointing elsewhere are also backed up before replacement.

## Configuration Decisions

### Zsh

The new `~/.zshrc` will:

- keep a small, explicit plugin set
- use conditional initialization for optional tools
- keep personal productivity aliases only if they are generic
- remove all work SSH aliases and internal Go environment configuration
- use Powerlevel10k consistently instead of mixing prompt systems

### Git

The new `~/.gitconfig` will:

- keep shared behavior only
- include `~/.gitconfig.local` for user identity and machine-local overrides
- point global ignore to `~/.config/git/ignore`

### Codex and Claude

Only stable, user-authored preference files will be kept.

Files copied from current state must be sanitized:

- remove machine-specific project trust entries
- remove tokens and environment secrets
- keep generic defaults and user guidance documents

## Verification Strategy

- Run shell syntax checks on the installer and shell files.
- Run the installer against a temporary home directory to validate symlink creation and backup logic.
- Inspect resulting links and file layout.
- Review `git diff` to confirm no secrets or work-specific values were introduced.

## Risks and Mitigations

### Risk: accidentally committing sensitive values

Mitigation:

- inspect candidate files before import
- prefer reconstructing config over raw copying when necessary
- explicitly exclude runtime and account files

### Risk: installation script overwrites user files unsafely

Mitigation:

- backup before replace
- use idempotent symlink logic
- fail fast on errors

### Risk: overfitting shell config to the current machine

Mitigation:

- guard optional integrations with file existence checks
- avoid package-manager-specific hard failures
- keep local override escape hatches

## Recommendation

Rebuild the repository around `home/` and `config/` with a single installer, migrate only sanitized reusable configuration, and leave identity plus sensitive values in local-only override files.
