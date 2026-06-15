#!/usr/bin/env bash
set -e

# Check pipx is installed
if ! command -v pipx &> /dev/null; then
    echo "pipx is not installed. Run: sudo apt install pipx && pipx ensurepath"
    exit 1
fi

# Install CLI tools
echo "Installing dev CLI tools via pipx..."
pipx install ruff
pipx install black
pipx install mypy
pipx install pytest
pipx install jupyter

echo "Done. Run 'which ruff' to verify."