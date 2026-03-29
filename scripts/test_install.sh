#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SCRIPT="$REPO_ROOT/scripts/install.sh"
OH_MY_ZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# Print a failure message and exit.
fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

# Assert that a file contains a fixed string.
assert_contains() {
  local file="$1"
  local expected="$2"
  grep -F "$expected" "$file" >/dev/null || fail "expected '$expected' in $file"
}

# Assert that a file does not contain a fixed string.
assert_not_contains() {
  local file="$1"
  local unexpected="$2"
  if grep -F "$unexpected" "$file" >/dev/null; then
    fail "did not expect '$unexpected' in $file"
  fi
}

# Create a fake PATH entry for curl and sh so installer behavior can be observed without network access.
setup_fake_commands() {
  local fake_bin="$1"

  mkdir -p "$fake_bin"

  cat >"$fake_bin/curl" <<'EOF'
#!/usr/bin/env bash
printf 'curl:%s\n' "$*" >>"$TEST_LOG"
cat <<'SCRIPT'
mkdir -p "$HOME/.oh-my-zsh"
printf 'installed\n' >"$HOME/.oh-my-zsh/.install-marker"
SCRIPT
EOF
  chmod +x "$fake_bin/curl"

  cat >"$fake_bin/sh" <<'EOF'
#!/usr/bin/env bash
printf 'sh:%s\n' "$*" >>"$TEST_LOG"
exec /bin/sh "$@"
EOF
  chmod +x "$fake_bin/sh"
}

# Verify installer auto-installs Oh My Zsh when missing.
test_installs_oh_my_zsh_when_missing() {
  local tmp_home
  local fake_bin
  local log_file

  tmp_home="$(mktemp -d)"
  fake_bin="$tmp_home/fake-bin"
  log_file="$tmp_home/install.log"

  setup_fake_commands "$fake_bin"
  : >"$log_file"

  HOME="$tmp_home" TEST_LOG="$log_file" PATH="$fake_bin:$PATH" "$INSTALL_SCRIPT" >/dev/null 2>&1

  [[ -d "$tmp_home/.oh-my-zsh" ]] || fail "expected ~/.oh-my-zsh to be created"
  [[ -f "$tmp_home/.oh-my-zsh/.install-marker" ]] || fail "expected install marker to be created"
  assert_contains "$log_file" "curl:-fsSL $OH_MY_ZSH_INSTALL_URL"
  assert_contains "$log_file" 'sh:-c mkdir -p "$HOME/.oh-my-zsh"'
}

# Verify installer skips Oh My Zsh bootstrap when already present.
test_skips_oh_my_zsh_install_when_present() {
  local tmp_home
  local fake_bin
  local log_file

  tmp_home="$(mktemp -d)"
  fake_bin="$tmp_home/fake-bin"
  log_file="$tmp_home/install.log"

  mkdir -p "$tmp_home/.oh-my-zsh"
  setup_fake_commands "$fake_bin"
  : >"$log_file"

  HOME="$tmp_home" TEST_LOG="$log_file" PATH="$fake_bin:$PATH" "$INSTALL_SCRIPT" >/dev/null 2>&1

  [[ -d "$tmp_home/.oh-my-zsh" ]] || fail "expected ~/.oh-my-zsh to remain present"
  [[ ! -f "$tmp_home/.oh-my-zsh/.install-marker" ]] || fail "did not expect install marker when already present"
  assert_not_contains "$log_file" "curl:-fsSL $OH_MY_ZSH_INSTALL_URL"
}

test_installs_oh_my_zsh_when_missing
test_skips_oh_my_zsh_install_when_present
