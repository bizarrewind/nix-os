#!/usr/bin/env bash
# =============================================================================
# NixOS / Dotfiles Update Checker
# Checks remote repo for commits and sends notification with action button
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles/nixos}"
SETTINGS_FILE="$HOME/.config/nixos-auto-update.json"
CACHE_FILE="$HOME/.cache/nixos-last-update-check"

# Check if auto-update setting is enabled (strictly opt-in)
if [ ! -f "$SETTINGS_FILE" ]; then
    exit 0
fi

ENABLED=$(grep -o '"enabled":\s*true' "$SETTINGS_FILE" || true)
if [ -z "$ENABLED" ]; then
    exit 0
fi

# Ensure git is available and dotfiles is a git repository with a configured remote
cd "$DOTFILES_DIR" || exit 0
if ! command -v git >/dev/null 2>&1 || [ ! -d ".git" ]; then
    exit 0
fi

REMOTE_NAME=$(git remote | head -n 1)
if [ -z "$REMOTE_NAME" ]; then
    exit 0
fi

# Optional argument: --rate-limit <minutes> (e.g. for terminal startup checks)
if [ "$1" = "--rate-limit" ]; then
    LIMIT_MINUTES="${2:-30}"
    NOW=$(date +%s)
    if [ -f "$CACHE_FILE" ]; then
        LAST_CHECK=$(cat "$CACHE_FILE" 2>/dev/null || echo 0)
        DIFF=$(( (NOW - LAST_CHECK) / 60 ))
        if [ "$DIFF" -lt "$LIMIT_MINUTES" ]; then
            exit 0
        fi
    fi
    mkdir -p "$(dirname "$CACHE_FILE")"
    echo "$NOW" > "$CACHE_FILE"
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
if [ "$CURRENT_BRANCH" = "HEAD" ]; then
    CURRENT_BRANCH="main"
fi

timeout 3 git fetch "$REMOTE_NAME" "$CURRENT_BRANCH" --quiet 2>/dev/null || exit 0

LOCAL_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "")
REMOTE_COMMIT=$(git rev-parse "${REMOTE_NAME}/${CURRENT_BRANCH}" 2>/dev/null || echo "")

if [ -z "$LOCAL_COMMIT" ] || [ -z "$REMOTE_COMMIT" ] || [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    exit 0
fi

# New commits are available!
COMMIT_COUNT=$(git rev-list --count "${LOCAL_COMMIT}..${REMOTE_COMMIT}")
LATEST_TITLE=$(git log -1 --format="%s" origin/main)
LATEST_AUTHOR=$(git log -1 --format="%an" origin/main)

# Detect if system rebuild or user switch
CHANGED_FILES=$(git diff --name-only "$LOCAL_COMMIT" "$REMOTE_COMMIT")
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

if [ "$NEEDS_SYSTEM_REBUILD" = true ]; then
    UPDATE_TYPE="NixOS System Rebuild Required"
else
    UPDATE_TYPE="Dotfiles / Home Manager Update"
fi

# Notify with action button
if command -v notify-send >/dev/null 2>&1; then
    ACTION=$(notify-send -a "NixOS Update Available" \
        -i system-software-update \
        --action="update=Update Now" \
        "$COMMIT_COUNT New Commit(s) Available" \
        "$LATEST_TITLE\nby $LATEST_AUTHOR ($UPDATE_TYPE)")

    if [ "$ACTION" = "update" ]; then
        if command -v kitty >/dev/null 2>&1; then
            kitty -e bash -c "$DOTFILES_DIR/scripts/upgrade.sh" &
        elif command -v alacritty >/dev/null 2>&1; then
            alacritty -e bash -c "$DOTFILES_DIR/scripts/upgrade.sh" &
        else
            x-terminal-emulator -e bash -c "$DOTFILES_DIR/scripts/upgrade.sh" &
        fi
    fi
fi
