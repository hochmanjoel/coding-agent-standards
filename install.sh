#!/usr/bin/env bash
# install.sh — one-line installer for coding-agent-standards.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<you>/coding-agent-standards/main/install.sh | bash
#
# Or with a custom repo:
#   REPO=https://github.com/<you>/coding-agent-standards curl -fsSL .../install.sh | bash
#
# What it does:
#   1. Clones the repo to ~/.local/share/coding-agent-standards (or pulls if already there)
#   2. Symlinks ~/.local/bin/agent-docs → the script in the repo
#   3. Checks whether ~/.local/bin is on PATH, and if not, prints the line to add

set -euo pipefail

REPO="${REPO:-https://github.com/hochmanjoel/coding-agent-standards}"
INSTALL_DIR="$HOME/.local/share/coding-agent-standards"
BIN_DIR="$HOME/.local/bin"
BIN_LINK="$BIN_DIR/agent-docs"

color_green() { printf '\033[32m%s\033[0m' "$1"; }
color_yellow() { printf '\033[33m%s\033[0m' "$1"; }
color_dim() { printf '\033[2m%s\033[0m' "$1"; }

echo "Installing coding-agent-standards"
echo "  Source: $REPO"
echo "  Path:   $INSTALL_DIR"
echo "  Binary: $BIN_LINK"
echo

# 1. Clone or update.
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "  $(color_dim "Repo already present — pulling latest")"
  git -C "$INSTALL_DIR" pull --ff-only --quiet
else
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone --quiet "$REPO" "$INSTALL_DIR"
fi
echo "  $(color_green '✓') repo installed"

# 2. Symlink the binary.
mkdir -p "$BIN_DIR"
if [[ -L "$BIN_LINK" ]]; then
  rm "$BIN_LINK"
elif [[ -e "$BIN_LINK" ]]; then
  echo "  $(color_yellow '!') $BIN_LINK exists and is not a symlink; not overwriting"
  echo "      Remove it manually and re-run the installer."
  exit 1
fi
ln -s "$INSTALL_DIR/agent-docs" "$BIN_LINK"
echo "  $(color_green '✓') binary linked"

# 3. Check PATH.
if ! command -v agent-docs >/dev/null 2>&1; then
  echo
  echo "  $(color_yellow '!') $BIN_DIR is not on your PATH."
  echo "      Add this to your shell rc (~/.bashrc, ~/.zshrc, etc.):"
  echo
  echo '      export PATH="$HOME/.local/bin:$PATH"'
  echo
  echo "      Then restart your shell or run: source ~/.bashrc"
else
  echo "  $(color_green '✓') agent-docs is on PATH"
fi

echo
echo "$(color_green 'Installed.')  Try it:"
echo "  cd your-project && agent-docs init"
