#!/usr/bin/env bash
# =============================================================================
# NixOS & Dotfiles Interactive Setup Assistant
# Sets up hardware configuration, user accounts, and initial preferences
# =============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "======================================================"
echo "          NixOS Dotfiles Setup Assistant              "
echo "======================================================"
echo ""

# 1. HARDWARE CONFIGURATION
echo "[1/4] Checking Hardware Configuration..."
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo "  Found local system hardware configuration at /etc/nixos/hardware-configuration.nix"
    echo "  Linking your machine's exact disk partitions (btrfs/ext4) and kernel modules..."
    cp /etc/nixos/hardware-configuration.nix "$DIR/hardware-configuration.nix"
    echo "  ✓ Hardware configuration successfully synchronized!"
else
    echo "  Notice: /etc/nixos/hardware-configuration.nix not found."
    echo "  Keeping existing repository hardware-configuration.nix."
fi
echo ""

# 2. USER CONFIGURATION
echo "[2/4] Setting up User Account..."
DETECTED_USER="${USER:-$(whoami)}"
if [ "$DETECTED_USER" = "root" ]; then
    DETECTED_USER="nixos"
fi

read -p "Enter your primary username [default: $DETECTED_USER]: " CHOSEN_USER
CHOSEN_USER="${CHOSEN_USER:-$DETECTED_USER}"

echo "  Target username: $CHOSEN_USER"
echo ""

# 3. KEYBOARD REMAPPING (KEYD)
echo "[3/4] Keyboard Remapping Preference..."
echo "  keyd remaps Caps Lock to Control (held) / Escape (tapped)."
echo "  Note: Disabled by default to prevent password entry conflicts."
read -p "Do you want to enable keyd CapsLock remapping? [y/N]: " ENABLE_KEYD_INPUT

if [[ "$ENABLE_KEYD_INPUT" =~ ^[Yy]$ ]]; then
    KEYD_VAL="true"
    echo "  ✓ keyd will be enabled."
else
    KEYD_VAL="false"
    echo "  ✓ keyd will remain disabled (standard keyboard layout)."
fi
echo ""

# Write user-config.nix
cat << CONFIG_EOF > "$DIR/user-config.nix"
{
  username = "$CHOSEN_USER";
  enableKeyd = $KEYD_VAL;
}
CONFIG_EOF

echo "  ✓ Saved configuration to user-config.nix"
echo ""

# 4. PASSWORD & ACTIVATION
echo "[4/4] Finalizing and Building System..."
echo ""
echo "Summary:"
echo "  • Username: $CHOSEN_USER"
echo "  • Keyd CapsLock Remap: $KEYD_VAL"
echo "  • Default password for fresh user: 'nixos' (run 'passwd' after boot to change)"
echo ""

read -p "Ready to build and activate this configuration now? [Y/n]: " RUN_BUILD
if [[ ! "$RUN_BUILD" =~ ^[Nn]$ ]]; then
    # Ensure local updates are visible to Nix flake
    git add hardware-configuration.nix user-config.nix 2>/dev/null || true

    echo ""
    echo "Running NixOS Rebuild..."
    sudo nixos-rebuild switch --flake .#nixos
    
    echo ""
    echo "Running Home Manager Switch..."
    home-manager switch --flake ".#$CHOSEN_USER" || home-manager switch --flake ".#$USER"
    
    echo ""
    echo "======================================================"
    echo "              Setup Completed Successfully!           "
    echo "======================================================"
    echo "You can launch the desktop or reboot your machine now."
else
    echo ""
    echo "Setup files created. You can rebuild whenever you are ready using:"
    echo "  sudo nixos-rebuild switch --flake .#nixos"
fi
