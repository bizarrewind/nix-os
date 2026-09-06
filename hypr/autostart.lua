-- ~/.config/hypr/autostart.lua

hl.on("hyprland.start",function()

	hl.exec_cmd("waybar")
	hl.exec_cmd("eww daemon")
	hl.exec_cmd("orbit daemon")
	hl.exec_cmd("swaync")

	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("bash -c 'sleep 0.6 && if [ -f ~/.config/current_wallpaper ]; then awww img \"$(cat ~/.config/current_wallpaper)\"; fi' &")
	hl.exec_cmd("hypridle")

	hl.exec_cmd("/run/current-system/sw/libexec/polkit-kde-authentication-agent-1")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- Ensure environment variables are propagated to systemd/dbus
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    
    -- Start the gnome-keyring secret service daemon
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,ssh,pkcs11")

    -- Check for repository updates in the background
    hl.exec_cmd("~/.dotfiles/nixos/scripts/check-updates.sh &")

    -- Battery warning & auto-suspend daemon
    hl.exec_cmd("~/.dotfiles/nixos/scripts/battery-monitor.sh &")
end)

