{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Hyprland Desktop Shell ---
    waybar                  # Status bar
    rofi            # App launcher & menu
    swaynotificationcenter  # Notification daemon & control center (swaync)
    awww                    # Animated wallpaper daemon (swww)
    brightnessctl

    # --- Screen Lock & Idle ---
    hyprlock                # Lock screen
    hypridle                # Screen sleep & idle manager

    # --- Screenshots & Clipboard ---
    hyprshot                # Screenshot script
    grim                    # Screenshot capture backend
    slurp                   # Region selection backend
    wl-clipboard            # Wayland clipboard utilities
    cliphist                # Clipboard history daemon

    # --- Hardware & System Controls ---
    networkmanagerapplet    # Wi-Fi tray icon (nm-applet)
    pavucontrol             # Audio volume GUI
    playerctl               # Media key handler (play/pause/skip)
    brightnessctl           # Backlight control

    # --- Theming & Integration ---
    nwg-look                # GTK theme and cursor switcher GUI
    bibata-cursors          # Cursor theme
    pywal                   # Wallpaper-based color scheme generator
    xdg-utils               # Desktop URL and MIME handling
    libnotify               # Desktop notifications tool (notify-send)

    # --- Media ---
    mpv
    vlc
    easyeffects

    # --- Terminals ---
    alacritty
    kitty

    # --- Development & Editors ---
    neovim
    vscodium

    # --- CLI Tools & Shell ---
    git
    curl
    btop
    ripgrep
    zsh

    # --- Games & Fun ---
    osu-lazer-bin
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    nerd-fonts.jetbrains-mono
  ];
}
