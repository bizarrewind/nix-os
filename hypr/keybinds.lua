---------------------
---- VARIABLES ------
---------------------
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "rofi -show drun"
local mainMod = "SUPER"
local browser = "firefox"

---------------------
---- KEYBINDINGS ----
---------------------
-- Core Applications & Launchers
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + O",      hl.dsp.exec_cmd("orbit toggle top-right"))

-- Quick Shell Utilities (Clipboard, Notifications, Power, Windows, Wallpaper, Cheatsheet)
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/clipboard.sh"))
hl.bind(mainMod .. " + SHIFT + V",  hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/clipboard.sh"))
hl.bind(mainMod .. " + N",          hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + escape",     hl.dsp.exec_cmd("wlogout -b 4 -c 0 -r 0"))
hl.bind("ALT + Tab",                hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + W",          hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/wallpaper-picker.sh"))
hl.bind(mainMod .. " + slash",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/keybinds-helper.sh"))

-- Window States
hl.bind(mainMod .. " + V",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M",             hl.dsp.window.fullscreen(1)) -- Maximize / expand (retaining bar & gaps)
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())  -- True fullscreen
hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.window.fullscreen(1))
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T",             hl.dsp.layout("togglesplit"))    

-- System & Screen Lock
hl.bind(mainMod .. " + DELETE", hl.dsp.exec_cmd("hyprlock"))


-- ==========================================
-- VIM-STYLE NAVIGATION (H, J, K, L)
-- ==========================================
-- Move focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- ==========================================
-- WORKSPACES
-- ==========================================
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + P",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshot Hotkeys (Region Snip, Fullscreen, Active Window)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/screenshot.sh region"))
hl.bind("Print",                   hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/screenshot.sh fullscreen"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/screenshot.sh region"))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/screenshot.sh window"))


-- ==========================================
-- HARDWARE MEDIA KEYS (With Visual OSD)
-- ==========================================
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/volume.sh up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/volume.sh down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/volume.sh mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),                  { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/brightness.sh up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(os.getenv("HOME") .. "/.dotfiles/nixos/scripts/brightness.sh down"), { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ==========================================
-- MOVE WINDOWS (VIM-STYLE)
-- ==========================================
-- Swap the active window's position with the one next to it
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
-- ==========================================
-- RESIZE MODE (SUBMAP)
-- ==========================================
-- 1. Press SUPER + R to enter Resize Mode
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

-- 2. Define the submap behavior inside a function block
hl.define_submap("resize", function()
    -- 3. Simple keys to use INSIDE the submap (no modifiers needed!)
    hl.bind("H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }),  { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }),  { repeating = true })

    -- 4. Press Escape or Enter to exit Resize Mode and return to normal
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
end)
