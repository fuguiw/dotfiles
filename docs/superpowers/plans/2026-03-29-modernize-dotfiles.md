# Modernize Dotfiles Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild this repository into a reusable one-command dotfiles setup using sanitized personal configuration from the current machine.

**Architecture:** Move managed files into `home/` and `config/` trees that mirror destination roots, then install them through a single shell script that performs backup and symlink creation. Reconstruct imported configs to remove work-specific and sensitive content instead of copying current machine state verbatim.

**Tech Stack:** POSIX shell, zsh config, git config, tmux config, markdown documentation, Make

---

### Task 1: Add repository structure and installer

**Files:**
- Create: `scripts/install.sh`
- Modify: `Makefile`
- Test: manual shell validation against a temporary home directory

- [ ] **Step 1: Write the failing installer check**

Define the expected behavior:

- installer creates links for files under `home/`
- installer creates links for files under `config/`
- installer backs up conflicting destination files

- [ ] **Step 2: Run validation to verify it currently fails**

Run: `test -x scripts/install.sh`
Expected: non-zero because installer does not exist yet

- [ ] **Step 3: Write minimal installer implementation**

Implement:

- repository root detection
- timestamped backup directory
- directory creation
- symlink creation for both trees

- [ ] **Step 4: Run shell validation to verify it passes**

Run:

```bash
bash -n scripts/install.sh
```

Expected: exit code 0

- [ ] **Step 5: Update Make targets**

Replace legacy one-file install targets with:

- `make install`
- `make link`
- optional compatibility aliases if useful

### Task 2: Replace legacy shell and git configuration

**Files:**
- Create: `home/.zshrc`
- Create: `home/.zprofile`
- Create: `home/.p10k.zsh`
- Create: `home/.gitconfig`
- Create: `home/.gitconfig.local.example`
- Create: `config/git/ignore`
- Modify: remove or deprecate legacy `zsh/` and `git/` content from active flow
- Test: `zsh -n home/.zshrc home/.zprofile`

- [ ] **Step 1: Write the failing config validation**

Run:

```bash
test -f home/.zshrc && test -f home/.gitconfig
```

Expected: non-zero because files are not created yet

- [ ] **Step 2: Build sanitized zsh configuration**

Keep:

- optional Oh My Zsh bootstrap
- optional Powerlevel10k loading
- optional fzf, nvm, bun, codex completions
- generic aliases and PATH handling

Remove:

- work SSH aliases
- corp env vars
- internal GOPROXY and private module settings
- local project path exports
- conflicting prompt initialization

- [ ] **Step 3: Build sanitized git configuration**

Keep:

- pull behavior
- editor choice
- global ignore

Move identity to local override:

- `~/.gitconfig.local`

- [ ] **Step 4: Run syntax and content checks**

Run:

```bash
zsh -n home/.zshrc home/.zprofile
git config --file home/.gitconfig --list >/dev/null
```

Expected: exit code 0

### Task 3: Replace tmux configuration with current reusable setup

**Files:**
- Create: `home/.tmux.conf`
- Test: `tmux -f home/.tmux.conf start-server` if available, otherwise static inspection

- [ ] **Step 1: Write the failing existence check**

Run: `test -f home/.tmux.conf`
Expected: non-zero because file does not exist yet

- [ ] **Step 2: Port reusable tmux settings**

Use the current machine's modern tmux settings as source material and keep:

- ergonomic bindings
- theme defaults
- mouse toggle and pane management

Exclude:

- machine-specific shell wrappers that are no longer needed

- [ ] **Step 3: Run basic validation**

Run:

```bash
tmux -f home/.tmux.conf -L dotfiles-test start-server
tmux -L dotfiles-test kill-server
```

Expected: start and stop without syntax errors when tmux is installed

### Task 4: Import selected tool configuration

**Files:**
- Create: `config/gh/config.yml`
- Create: `config/fish/conf.d/uv.env.fish`
- Create: `home/.claude/CLAUDE.md`
- Create: `home/.claude/settings.json`
- Create: `home/.codex/AGENTS.md`
- Create: `home/.codex/config.toml`
- Test: static review of sanitized content

- [ ] **Step 1: Write the failing existence check**

Run:

```bash
test -f config/gh/config.yml && test -f home/.codex/config.toml
```

Expected: non-zero because files do not exist yet

- [ ] **Step 2: Import safe files directly**

Copy with minimal edits:

- `gh/config.yml`
- `fish/conf.d/uv.env.fish`
- `~/.claude/CLAUDE.md`
- `~/.codex/AGENTS.md`

- [ ] **Step 3: Reconstruct sanitized tool settings**

For `~/.claude/settings.json`:

- keep generic permissions and model preference only if not secret-bearing

For `~/.codex/config.toml`:

- keep generic model and sandbox defaults
- remove tokens
- remove work project trust entries
- remove machine-local hooks that depend on private paths

- [ ] **Step 4: Run format and parse checks**

Run:

```bash
python3 -m json.tool home/.claude/settings.json >/dev/null
grep -nE "(_AUTH_TOKEN|_API_KEY|secret)" home/.codex/config.toml && exit 1 || true
```

Expected: JSON parses and secret-bearing keys are absent

### Task 5: Update documentation and verify end-to-end install flow

**Files:**
- Modify: `README.md`
- Modify: `.gitignore` if needed
- Test: installer run in temporary home directory

- [ ] **Step 1: Write the failing documentation/install expectation**

Define required README coverage:

- repository layout
- install command
- local override files
- excluded sensitive files

- [ ] **Step 2: Rewrite README for the new structure**

Document:

- `make install`
- direct installer usage
- how backups work
- what remains local-only

- [ ] **Step 3: Run end-to-end temporary install verification**

Run something equivalent to:

```bash
TMP_HOME="$(mktemp -d)"
HOME="$TMP_HOME" ./scripts/install.sh
find "$TMP_HOME" -maxdepth 3 -type l | sort
```

Expected: symlinks exist for managed files and directories are created correctly

- [ ] **Step 4: Inspect diff for unwanted imports**

Run:

```bash
git diff --stat
git diff
```

Expected: only intended files are added or modified, with no secrets or work-specific values
