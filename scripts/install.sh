#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$HOME/.dotfiles-backups}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
BACKUP_CREATED=0
OH_MY_ZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# Print a log message to stderr.
log() {
  printf '%s\n' "$*" >&2
}

# Ensure the parent directory for a target path exists.
ensure_parent_dir() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
}

# Create the backup directory lazily on first use.
ensure_backup_dir() {
  if [[ "$BACKUP_CREATED" -eq 0 ]]; then
    mkdir -p "$BACKUP_DIR"
    BACKUP_CREATED=1
  fi
}

# Install Oh My Zsh when the standard installation directory is missing.
ensure_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return
  fi

  log "Installing Oh My Zsh into $HOME/.oh-my-zsh"
  sh -c "$(curl -fsSL "$OH_MY_ZSH_INSTALL_URL")"
}

# Move an existing target into the timestamped backup directory.
backup_target() {
  local target="$1"
  local relative_path
  local backup_path

  ensure_backup_dir

  if [[ "$target" == "$HOME/"* ]]; then
    relative_path="${target#"$HOME/"}"
  else
    relative_path="$(basename "$target")"
  fi

  backup_path="$BACKUP_DIR/$relative_path"
  mkdir -p "$(dirname "$backup_path")"
  mv "$target" "$backup_path"
  log "Backed up $target -> $backup_path"
}

# Link a repository file into the destination tree with backup-on-conflict.
install_link() {
  local source_path="$1"
  local target_path="$2"
  local current_target

  ensure_parent_dir "$target_path"

  if [[ -L "$target_path" ]]; then
    current_target="$(readlink "$target_path")"
    if [[ "$current_target" == "$source_path" ]]; then
      log "Unchanged $target_path"
      return
    fi
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    backup_target "$target_path"
  fi

  ln -s "$source_path" "$target_path"
  log "Linked $target_path -> $source_path"
}

# Install all regular files from a source tree into the matching destination root.
install_tree() {
  local source_root="$1"
  local destination_root="$2"
  local source_path
  local relative_path
  local target_path

  [[ -d "$source_root" ]] || return

  while IFS= read -r source_path; do
    relative_path="${source_path#"$source_root/"}"
    target_path="$destination_root/$relative_path"
    install_link "$source_path" "$target_path"
  done < <(find "$source_root" -type f | LC_ALL=C sort)
}

# Install all managed files from the repository into the current HOME.
main() {
  ensure_oh_my_zsh
  install_tree "$REPO_ROOT/home" "$HOME"
  install_tree "$REPO_ROOT/config" "$HOME/.config"

  if [[ "$BACKUP_CREATED" -eq 1 ]]; then
    log "Backups stored in $BACKUP_DIR"
  else
    log "No backups were needed"
  fi
}

main "$@"
