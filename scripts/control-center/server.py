import http.server
import socketserver
import json
import subprocess
import os
import re
import base64

PORT = 8123
DIR = os.path.dirname(os.path.realpath(__file__))
DOTFILES = os.path.expanduser("~/.dotfiles/nixos")

def read_json_comments(filepath):
    # simple reader that strips out comments to parse jsonc
    try:
        with open(filepath, 'r') as f:
            content = f.read()
            # remove single line comments
            content = re.sub(r'//.*', '', content)
            # remove multi line comments
            content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
            return json.loads(content)
    except:
        return {}

def write_json(filepath, data):
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.path.join(DIR, 'www'), **kwargs)

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)
        if not post_data:
            self.send_error(400)
            return
            
        data = json.loads(post_data.decode('utf-8'))
        
        if self.path == '/api/set':
            self.handle_set(data)
        elif self.path == '/api/save':
            self.handle_save(data)
        elif self.path == '/api/upload':
            self.handle_upload(data)
        elif self.path == '/api/extract':
            self.handle_extract(data)
        else:
            self.send_error(404)
            
    def handle_extract(self, data):
        wallpaper = data.get('wallpaper')
        if not wallpaper:
            self.send_error(400)
            return
            
        wall_path = os.path.join(DOTFILES, 'wallpapers', wallpaper)
        if not os.path.exists(wall_path):
            self.send_error(404)
            return

        cmd = ['nix', 'run', 'nixpkgs#matugen', '--', 'image', wall_path, '-j', 'hex', '--source-color-index', '0']
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            # Find the JSON block in the output since nix run might print warnings before
            json_str = result.stdout[result.stdout.find('{'):result.stdout.rfind('}')+1]
            matugen_data = json.loads(json_str)
            
            palettes = {}
            for mode in ['dark', 'light']:
                colors = matugen_data['colors']
                def c(name):
                    return colors[name][mode]['color'].replace('#', '')

                palettes[f'extracted-{mode}'] = {
                    'base00': c('surface'),
                    'base01': c('surface_variant'),
                    'base02': c('surface_container'),
                    'base03': c('on_surface_variant'),
                    'base04': c('on_surface'),
                    'base05': c('primary_container'),
                    'base06': c('primary'),
                    'base07': c('on_primary'),
                    'base08': c('error'),
                    'base09': c('tertiary'),
                    'base0A': c('secondary'),
                    'base0B': c('primary'),
                    'base0C': c('secondary_container'),
                    'base0D': c('primary'),
                    'base0E': c('tertiary_container'),
                    'base0F': c('error_container')
                }

            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(palettes).encode('utf-8'))
        except Exception as e:
            print(f"Error extracting with matugen: {e}")
            self.send_error(500)

    def handle_upload(self, data):
        filename = data.get('filename')
        base64_data = data.get('data')
        if filename and base64_data:
            # remove data:image/png;base64, prefix
            if ',' in base64_data:
                base64_data = base64_data.split(',')[1]
            img_data = base64.b64decode(base64_data)
            filepath = os.path.join(DOTFILES, 'wallpapers', filename)
            with open(filepath, 'wb') as f:
                f.write(img_data)
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok"}).encode('utf-8'))

    def handle_set(self, data):
        # On-the-fly preview
        if 'gaps_in' in data:
            subprocess.run(['hyprctl', 'eval', f'hl.config({{general = {{gaps_in = {data["gaps_in"]}}}}})'])
        if 'gaps_out' in data:
            subprocess.run(['hyprctl', 'eval', f'hl.config({{general = {{gaps_out = {data["gaps_out"]}}}}})'])
        if 'rounding' in data:
            subprocess.run(['hyprctl', 'eval', f'hl.config({{decoration = {{rounding = {data["rounding"]}}}}})'])
        if 'active_opacity' in data:
            subprocess.run(['hyprctl', 'eval', f'hl.config({{decoration = {{active_opacity = {data["active_opacity"]}}}}})'])
        if 'inactive_opacity' in data:
            subprocess.run(['hyprctl', 'eval', f'hl.config({{decoration = {{inactive_opacity = {data["inactive_opacity"]}}}}})'])
        if 'blur' in data:
            val = 'true' if data['blur'] else 'false'
            subprocess.run(['hyprctl', 'eval', f'hl.config({{decoration = {{blur = {{enabled = {val}}}}}}})'])
        if 'animations' in data:
            val = 'true' if data['animations'] else 'false'
            subprocess.run(['hyprctl', 'eval', f'hl.config({{animations = {{enabled = {val}}}}})'])
            
        if 'wallpaper' in data:
            wall_path = os.path.join(DOTFILES, 'wallpapers', data['wallpaper'])
            subprocess.run(['swww', 'img', wall_path, '--transition-type', 'fade'])
            
        if 'waybar' in data:
            # Update waybar config and reload
            wb_config_path = os.path.join(DOTFILES, 'waybar', 'config.jsonc')
            wb_data = read_json_comments(wb_config_path)
            if 'group/system' in wb_data:
                wb_data['group/system']['modules'] = data['waybar']
                write_json(wb_config_path, wb_data)
                subprocess.run(['pkill', '-SIGUSR2', 'waybar'])
                
        if 'waybar_radius' in data:
            css_path = os.path.join(DOTFILES, 'waybar', 'custom-vars.css')
            with open(css_path, 'w') as f:
                f.write(f":root {{ --wb-radius: {data['waybar_radius']}px; }}\n")
            subprocess.run(['pkill', '-SIGUSR2', 'waybar'])
            
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok"}).encode('utf-8'))

    def handle_save(self, data):
        # 1. Update hyprland.lua
        hypr_file = os.path.join(DOTFILES, 'hypr', 'hyprland.lua')
        try:
            with open(hypr_file, 'r') as f:
                content = f.read()
            if 'gaps_in' in data:
                content = re.sub(r'gaps_in\s*=\s*\d+,', f'gaps_in = {data["gaps_in"]},', content)
            if 'gaps_out' in data:
                content = re.sub(r'gaps_out\s*=\s*\d+,', f'gaps_out = {data["gaps_out"]},', content)
            if 'rounding' in data:
                content = re.sub(r'rounding\s*=\s*\d+,', f'rounding = {data["rounding"]},', content)
            if 'active_opacity' in data:
                content = re.sub(r'active_opacity\s*=\s*[0-9.]+,', f'active_opacity = {data["active_opacity"]},', content)
            if 'inactive_opacity' in data:
                content = re.sub(r'inactive_opacity\s*=\s*[0-9.]+,', f'inactive_opacity = {data["inactive_opacity"]},', content)
            if 'blur' in data:
                val = 'true' if data['blur'] else 'false'
                content = re.sub(r'blur\s*=\s*\{\s*\n\s*enabled\s*=\s*(true|false),', f'blur = {{\n\t\t\tenabled = {val},', content)
            if 'animations' in data:
                val = 'true' if data['animations'] else 'false'
                content = re.sub(r'animations\s*=\s*\{\s*\n\s*enabled\s*=\s*(true|false),', f'animations = {{\n\t\tenabled = {val},', content)
            with open(hypr_file, 'w') as f:
                f.write(content)
        except Exception as e:
            print("Error saving hyprland.lua:", e)

        # 2. Update stylix.nix
        stylix_file = os.path.join(DOTFILES, 'stylix.nix')
        try:
            with open(stylix_file, 'r') as f:
                content = f.read()
            if 'wallpaper' in data:
                content = re.sub(r'image\s*=\s*\./wallpapers/[^;]+;', f'image = ./wallpapers/{data["wallpaper"]};', content)
            
            if 'color_preset' in data:
                if data['color_preset'].startswith('extracted-') or data['color_preset'] == 'auto':
                    content = re.sub(r'colorPreset\s*=\s*[^;]+;', f'colorPreset = null;', content)
                else:
                    content = re.sub(r'colorPreset\s*=\s*[^;]+;', f'colorPreset = "{data["color_preset"]}";', content)
            
            # Update custom palette override
            if 'custom_palette' in data and data['custom_palette']:
                overrides = "override = {\n"
                for k, v in data['custom_palette'].items():
                    overrides += f'      {k} = "{v}";\n'
                overrides += "    };"
                # replace existing override block
                content = re.sub(r'override\s*=\s*\{[^}]+\};', overrides, content)
            else:
                # restore default override if returning to auto or preset
                default_override = 'override = {\n      base00 = "000000";\n      base01 = "0a0a0f";\n      base02 = "14141d";\n      base03 = "282835";\n    };'
                content = re.sub(r'override\s*=\s*\{[^}]+\};', default_override, content)

            with open(stylix_file, 'w') as f:
                f.write(content)
        except Exception as e:
            print("Error saving stylix.nix:", e)
        
        # 3. Trigger rebuild
        rebuild_cmd = f'cd {DOTFILES}; echo "Applying global themes and colors via NixOS Rebuild..."; sudo nixos-rebuild switch; echo ""; echo "Rebuild complete (if there are errors, they will be listed above)."; read -p "Press ENTER to close window..."'
        subprocess.Popen(['alacritty', '-e', 'bash', '-c', rebuild_cmd])

        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "saving"}).encode('utf-8'))

    def do_GET(self):
        if self.path == '/api/status':
            walls_dir = os.path.join(DOTFILES, 'wallpapers')
            try:
                wallpapers = sorted([f for f in os.listdir(walls_dir) if f.endswith(('.jpg', '.png', '.jpeg'))])
            except:
                wallpapers = []
            
            # defaults
            gaps_in, gaps_out, rounding = 2, 2, 12
            active_opacity, inactive_opacity = 0.93, 0.85
            blur_enabled, animations_enabled = True, True
            current_wallpaper = "default.jpg"
            color_preset = "auto"
            waybar_modules = []
            waybar_radius = 12

            try:
                with open(os.path.join(DOTFILES, 'hypr', 'hyprland.lua'), 'r') as f:
                    content = f.read()
                    match = re.search(r'gaps_in\s*=\s*(\d+)', content)
                    if match: gaps_in = int(match.group(1))
                    match = re.search(r'gaps_out\s*=\s*(\d+)', content)
                    if match: gaps_out = int(match.group(1))
                    match = re.search(r'rounding\s*=\s*(\d+)', content)
                    if match: rounding = int(match.group(1))
                    match = re.search(r'active_opacity\s*=\s*([0-9.]+)', content)
                    if match: active_opacity = float(match.group(1))
                    match = re.search(r'inactive_opacity\s*=\s*([0-9.]+)', content)
                    if match: inactive_opacity = float(match.group(1))
                    match = re.search(r'blur\s*=\s*\{\s*\n\s*enabled\s*=\s*(true|false)', content)
                    if match: blur_enabled = match.group(1) == 'true'
                    match = re.search(r'animations\s*=\s*\{\s*\n\s*enabled\s*=\s*(true|false)', content)
                    if match: animations_enabled = match.group(1) == 'true'
            except: pass

            try:
                with open(os.path.join(DOTFILES, 'stylix.nix'), 'r') as f:
                    content = f.read()
                    match = re.search(r'image\s*=\s*\./wallpapers/([^;]+);', content)
                    if match: current_wallpaper = match.group(1)
                    match = re.search(r'colorPreset\s*=\s*"([^"]+)";', content)
                    if match: color_preset = match.group(1)
            except: pass
            
            try:
                wb_data = read_json_comments(os.path.join(DOTFILES, 'waybar', 'config.jsonc'))
                if 'group/system' in wb_data:
                    waybar_modules = wb_data['group/system'].get('modules', [])
            except: pass

            try:
                with open(os.path.join(DOTFILES, 'waybar', 'custom-vars.css'), 'r') as f:
                    content = f.read()
                    match = re.search(r'--wb-radius:\s*(\d+)px', content)
                    if match: waybar_radius = int(match.group(1))
            except: pass

            data = {
                "wallpapers": wallpapers,
                "current_wallpaper": current_wallpaper,
                "gaps_in": gaps_in,
                "gaps_out": gaps_out,
                "rounding": rounding,
                "active_opacity": active_opacity,
                "inactive_opacity": inactive_opacity,
                "blur": blur_enabled,
                "animations": animations_enabled,
                "color_preset": color_preset,
                "waybar_modules": waybar_modules,
                "waybar_radius": waybar_radius
            }

            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(data).encode('utf-8'))
        elif self.path.startswith('/wallpapers/'):
            filename = self.path.split('/')[-1]
            filepath = os.path.join(DOTFILES, 'wallpapers', filename)
            if os.path.exists(filepath):
                self.send_response(200)
                if filepath.endswith('.png'):
                    self.send_header('Content-type', 'image/png')
                else:
                    self.send_header('Content-type', 'image/jpeg')
                self.end_headers()
                with open(filepath, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404)
        else:
            super().do_GET()

if __name__ == "__main__":
    with socketserver.TCPServer(("127.0.0.1", PORT), MyHandler) as httpd:
        print(f"Serving at http://127.0.0.1:{PORT}")
        httpd.serve_forever()
