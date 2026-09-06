"""
replace_radius.py — Synchronize border-radius across all Crystal UI components.

Usage:
    python replace_radius.py [RADIUS]

    RADIUS defaults to 12 (pixels). Change it here or pass as a CLI argument.

This script is safe to run from any working directory; all paths are resolved
relative to the directory this file lives in (the dotfiles root).
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent.resolve()

radius = sys.argv[1] if len(sys.argv) > 1 else "12"

css_files = [
    ROOT / "wlogout" / "style-dark.css",
    ROOT / "wlogout" / "style-light.css",
    ROOT / "eww" / "eww.scss",
    ROOT / "waybar" / "style-dark.css",
    ROOT / "waybar" / "style-light.css",
    ROOT / "waybar" / "style.css",
    ROOT / "swaync" / "style.css",
    ROOT / "rofi" / "themes" / "crystal-ui-dark.rasi",
    ROOT / "rofi" / "themes" / "crystal-ui-light.rasi",
    ROOT / "rofi" / "themes" / "crystal-ui.rasi",
]

for fpath in css_files:
    if not fpath.exists():
        print(f"  skip (not found): {fpath.name}")
        continue
    text = fpath.read_text()
    new_text = re.sub(
        r'(?<=border-radius:\s)(\d+)(?=px)',
        radius,
        text,
    )
    fpath.write_text(new_text)
    print(f"  updated: {fpath.name}")

# Handle hyprland.lua rounding value
hl_path = ROOT / "hypr" / "hyprland.lua"
if hl_path.exists():
    text = hl_path.read_text()
    new_text = re.sub(r'(rounding\s*=\s*)\d+', rf'\g<1>{radius}', text)
    hl_path.write_text(new_text)
    print(f"  updated: hyprland.lua (rounding = {radius})")

print(f"\nDone — border-radius set to {radius}px across all Crystal UI files.")
