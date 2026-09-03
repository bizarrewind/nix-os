import re
import glob

radius = "12"

files = [
    "/home/vexil/.dotfiles/nixos/wlogout/style-dark.css",
    "/home/vexil/.dotfiles/nixos/wlogout/style-light.css",
    "/home/vexil/.dotfiles/nixos/eww/eww.scss",
    "/home/vexil/.dotfiles/nixos/waybar/style-dark.css",
    "/home/vexil/.dotfiles/nixos/home.nix",
    "/home/vexil/.dotfiles/nixos/waybar/style-light.css",
    "/home/vexil/.dotfiles/nixos/swaync/style.css",
    "/home/vexil/.dotfiles/nixos/rofi/themes/liquid-glass-light.rasi",
    "/home/vexil/.dotfiles/nixos/rofi/themes/liquid-glass-dark.rasi",
]

for fpath in files:
    with open(fpath, "r") as f:
        lines = f.readlines()
    
    with open(fpath, "w") as f:
        for line in lines:
            if "border-radius:" in line:
                # Replace any number before 'px' with our new radius
                new_line = re.sub(r'\b\d+px\b', f'{radius}px', line)
                f.write(new_line)
            else:
                f.write(line)

# Handle hyprland.lua rounding
with open("/home/vexil/.dotfiles/nixos/hypr/hyprland.lua", "r") as f:
    hl_lines = f.readlines()
with open("/home/vexil/.dotfiles/nixos/hypr/hyprland.lua", "w") as f:
    for line in hl_lines:
        if re.search(r'^\s*rounding\s*=\s*\d+', line):
            line = re.sub(r'rounding\s*=\s*\d+', f'rounding = {radius}', line)
        f.write(line)

print("Done")
