# Load OrbStack shell integration when available.
if [[ -r "$HOME/.orbstack/shell/init.zsh" ]]; then
  source "$HOME/.orbstack/shell/init.zsh"
fi

# Add Obsidian CLI support when the application bundle is installed.
if [[ -d "/Applications/Obsidian.app/Contents/MacOS" ]]; then
  export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi
