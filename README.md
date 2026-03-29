# dotfiles

Personal reusable dotfiles for macOS, organized for one-command installation.

## What is managed

- Home-directory dotfiles under `home/`
- `~/.config` files under `config/`
- A small set of sanitized tool preferences under `home/.claude/` and `home/.codex/`

This repository intentionally excludes:

- secrets and tokens
- work-only aliases and internal hosts
- runtime state, logs, caches, databases, and history files
- authenticated host files such as `~/.config/gh/hosts.yml`

## Repository layout

```text
home/    -> ~/
config/  -> ~/.config/
scripts/ -> installation helpers
```

## Install

Run:

```bash
make install
```

Or:

```bash
./scripts/install.sh
```

The installer:

- installs Oh My Zsh first when `~/.oh-my-zsh` is missing
- creates parent directories as needed
- backs up conflicting files into `~/.dotfiles-backups/<timestamp>/`
- creates symlinks for all tracked files under `home/` and `config/`
- is safe to run repeatedly

## Checks

Run:

```bash
make check
```

This validates installer syntax and basic config parsing.

## Local-only overrides

Some settings should remain outside git.

### Git identity

Copy `home/.gitconfig.local.example` to `~/.gitconfig.local` and fill in your identity:

```ini
[user]
    name = Your Name
    email = you@example.com
```

### Zsh machine-local settings

If you need private aliases, work settings, or machine-specific PATH entries, put them in:

- `~/.zshrc.local`
- `~/.config/zsh/local.zsh`

These files are loaded when present and are not managed by this repository.

## Notes

- Oh My Zsh is treated as an external dependency. The installer bootstraps it automatically when needed.
- `gh` authentication is not managed here. Re-authenticate with `gh auth login` on a new machine.
- `claude` and `codex` configs in this repository are sanitized preference files, not runtime state backups.
- The repository no longer relies on git submodules for shell or vim frameworks.
