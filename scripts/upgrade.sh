#!/usr/bin/env bash
# =============================================================================
# NixOS / Dotfiles Smart Upgrade Assistant
# Checks git diff between local and remote to selectively rebuild
# =============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles/nixos}"
cd "$DOTFILES_DIR"

echo "======================================================"
echo "          NixOS & Dotfiles Upgrade Assistant          "
echo "======================================================"
echo ""

# Ensure we're on a git repo
if [ ! -d ".git" ]; then
    echo "Error: $DOTFILES_DIR is not a git repository."
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Checking remote repository for changes..."
git fetch origin main --quiet

LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    echo "Your system and dotfiles are already completely up to date!"
    echo ""
    read -p "Press Enter to exit..."
    exit 0
fi

# Get list of changed files
CHANGED_FILES=$(git diff --name-only "$LOCAL_COMMIT" "$REMOTE_COMMIT")

echo "New incoming commits:"
git log --oneline --no-merges "${LOCAL_COMMIT}..${REMOTE_COMMIT}" | sed 's/^/  * /'
echo ""

# Determine if system-level configuration changed
NEEDS_SYSTEM_REBUILD=false
SYSTEM_PATTERNS=("configuration.nix" "hardware-configuration.nix" "pkgs.nix" "coding.nix" "flake.nix" "flake.lock" "pkgs/")

for file in $CHANGED_FILES; do
    for pattern in "${SYSTEM_PATTERNS[@]}"; do
        if [[ "$file" == *"$pattern"* ]]; then
            NEEDS_SYSTEM_REBUILD=true
            break 2
        fi
    done
done

echo "Changes detected in:"
echo "$CHANGED_FILES" | sed 's/^/  - /'
echo ""

if [ "$NEEDS_SYSTEM_REBUILD" = true ]; then
    echo ">> System-level files were modified."
    echo "   Action: NixOS System Rebuild + Home Manager Switch (Requires sudo)"
else
    echo ">> Only user-level dotfiles/configs were modified."
    echo "   Action: Fast Home Manager Switch (No sudo password needed)"
fi
echo ""

read -p "Do you want to apply this update now? [Y/n] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Update cancelled."
    exit 0
fi

echo ""
echo "Pulling latest changes..."
git pull --ff-only origin main

CURRENT_USER="${USER:-$(whoami)}"
CURRENT_HOST="$(hostname 2>/dev/null || echo 'nixos')"

# Check available flake configurations
if [ "$NEEDS_SYSTEM_REBUILD" = true ]; then
    echo ""
    echo "Executing NixOS Rebuild..."
    if sudo nixos-rebuild switch --flake ".#$CURRENT_HOST" 2>/dev/null; then
        :
    else
        sudo nixos-rebuild switch --flake .#nixos
    fi
    
    echo "Executing Home Manager Switch..."
    if home-manager switch --flake ".#$CURRENT_USER" 2>/dev/null; then
        :
    else
        home-manager switch --flake .#vexil
    fi
else
    echo ""
    echo "Executing Home Manager Switch..."
    if home-manager switch --flake ".#$CURRENT_USER" 2>/dev/null; then
        :
    else
        home-manager switch --flake .#vexil
    fi
fi

# Reload UI services if running
if command -v orbit >/dev/null 2>&1; then
    orbit reload-theme >/dev/null 2>&1 || true
fi

if command -v pkill >/dev/null 2>&1 && pgrep -x waybar >/dev/null 2>&1; then
    pkill -SIGUSR2 waybar || true
fi

echo ""
echo "======================================================"
echo "          Update Completed Successfully!              "
echo "======================================================"

if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "NixOS Update" "System Updated" "Your configuration was successfully updated to $(git rev-parse --short HEAD)."
fi

echo ""
read -p "Press Enter to close..."
