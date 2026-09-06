<div align="center">

# ❄️ Crystal UI — NixOS Dotfiles

**A premium, glassmorphic NixOS desktop built on Hyprland.**  
Stylix-powered dynamic theming · Waybar · Neovim · Rofi · SwayNC · wlogout

[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos)](https://nixos.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-latest-purple?logo=linux)](https://hyprland.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

</div>

---

## ✨ Features

| Feature | Details |
|---------|---------|
| 🖥️ **Hyprland** | Smooth animations, floating PiP rules, master layout |
| 🎨 **Stylix** | Wallpaper-derived palette applied to every app automatically |
| 📊 **Waybar** | Translucent pill capsules, dynamic Stylix color CSS |
| 📝 **Neovim** | Lazy.nvim + Telescope + Treesitter + live palette sync |
| 🔔 **SwayNC** | Glassmorphic notification center |
| 🚀 **Orbit Menu** | Custom Rust/GTK Bluetooth & Wi-Fi overlay |
| 🔋 **Battery Guard** | Multi-stage low battery alerts + auto-suspend |
| 🔄 **Auto-updates** | Optional remote push notifications when you commit |
| ⌨️ **keyd** | Keyboard remapping (togglable, off by default) |
| 📐 **Unified Geometry** | 12px border-radius synced across every UI component |

---

## 📸 Gallery

> Screenshots coming soon — replace this section with your own!

---

## 📂 Directory Structure

```
.
├── configuration.nix        # NixOS system configuration
├── home.nix                 # Home Manager user environment
├── flake.nix                # Nix flake (inputs + outputs)
├── stylix.nix               # Global theme settings
├── pkgs.nix                 # System-wide packages
├── coding.nix               # Dev tools (optional packages)
├── user-config.example.nix  # Template for your user-config.nix
├── setup.sh                 # 🚀 Interactive first-time setup
├── replace_radius.py        # Sync border-radius across all components
├── hypr/                    # Hyprland config (Lua-based)
├── waybar/                  # Waybar modules & CSS
├── nvim/                    # Neovim (Lua, lazy.nvim)
├── rofi/                    # App launcher themes
├── swaync/                  # Notification center
├── wlogout/                 # Power menu
├── eww/                     # Eww widgets (volume)
├── wallpapers/              # Wallpapers (Stylix reads these)
└── scripts/                 # Upgrade, battery monitor, control center
```

---

## 🚀 Getting Started

### Prerequisites

- A fresh NixOS install (flakes enabled)
- Git

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO ~/.dotfiles/nixos
cd ~/.dotfiles/nixos

# 2. Run the interactive setup assistant
#    This will:
#      - Ask for your username
#      - Copy your machine's hardware-configuration.nix
#      - Create user-config.nix
#      - Optionally apply the config immediately
bash setup.sh
```

> [!IMPORTANT]
> **Do not skip `setup.sh`.** NixOS requires a `hardware-configuration.nix` that matches
> your machine's disks and UUIDs. The one in this repo is intentionally excluded from git.
> Running `setup.sh` copies the correct one from `/etc/nixos/`.

### Manual Setup (if you prefer)

```bash
# Copy your machine's hardware config
cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/nixos/

# Create your user config
cp user-config.example.nix user-config.nix
# Edit user-config.nix and set your username

# Apply system configuration
sudo nixos-rebuild switch --flake .#nixos

# Apply user environment
home-manager switch --flake .#$USER
```

---

## 🎨 Theming

Everything is driven by **Stylix**. To change the color palette:

1. **Change your wallpaper** — Stylix auto-extracts a palette from any image.
   - Replace `wallpapers/default.jpg` with your image.
2. **Use a preset scheme** — Edit `stylix.nix` and set `colorPreset`:
   ```nix
   colorPreset = "tokyo-night-dark"; # or dracula, nord, catppuccin-mocha …
   ```
3. **Rebuild:**
   ```bash
   home-manager switch --flake .#$USER
   ```

### Sync Border Radius

To change the `12px` border radius across every component:

```bash
python replace_radius.py 16   # set to 16px
```

---

## 🔄 Updates

This repo ships a smart upgrade script and optional auto-notification system.

```bash
dotfiles-update        # pull + smart rebuild (system or home-manager only)
```

The shell alias `dotfiles-update` is available after applying the config.

If you want to be notified when the upstream repo has updates, enable
**Remote Update Notifications** in the Web Control Center:

```bash
bash scripts/control-center/run.sh
```

---

## ⌨️ Key Bindings

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + D` | App launcher (Rofi) |
| `Super + M` | Maximize window |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + [1-9]` | Switch workspace |
| `Super + Shift + [1-9]` | Move window to workspace |

---

## 🗂️ Machine-Specific Configuration

| File | Role |
|------|------|
| `hardware-configuration.nix` | Synchronized from `/etc/nixos/` by `setup.sh` for your machine's drive UUIDs |
| `user-config.nix` | Generated by `setup.sh` with your username and keyd preferences |
| `private.nix` | Git credentials (excluded from git via `.gitignore`) |
| `*.log` | Runtime logs (excluded from git) |

---

## 📋 Requirements

- NixOS (unstable channel)
- Nix Flakes enabled (`experimental-features = nix-command flakes` in `/etc/nix/nix.conf`)
- Home Manager (installed by `setup.sh` or manually)

---

## 🤝 Contributing

Feel free to open issues or PRs. If you use this config as a base, a star ⭐ is appreciated!

---

<div align="center">
<sub>Built with ❄️ NixOS, ♥ and too many late nights.</sub>
</div>
