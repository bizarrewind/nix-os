document.addEventListener('DOMContentLoaded', async () => {
    // Elements
    const elGapsIn = document.getElementById('gaps-in');
    const elGapsOut = document.getElementById('gaps-out');
    const elRounding = document.getElementById('rounding');
    const elWaybarRadius = document.getElementById('waybar-radius');
    const elActiveOpacity = document.getElementById('active-opacity');
    const elInactiveOpacity = document.getElementById('inactive-opacity');
    const toggleBlur = document.getElementById('toggle-blur');
    const toggleAnimations = document.getElementById('toggle-animations');
    const toggleAutoupdate = document.getElementById('toggle-autoupdate');
    const waybarModules = document.getElementById('waybar-modules');
    const grid = document.getElementById('wallpaper-grid');
    const btnSave = document.getElementById('btn-save');
    const btnUpload = document.getElementById('btn-upload');
    const fileUpload = document.getElementById('file-upload');
    const pieSelector = document.getElementById('pie-selector');

    // Display elements
    const valGapsIn = document.getElementById('val-gaps-in');
    const valGapsOut = document.getElementById('val-gaps-out');
    const valRounding = document.getElementById('val-rounding');
    const valWaybarRadius = document.getElementById('val-waybar-radius');
    const valActiveOpacity = document.getElementById('val-active-opacity');
    const valInactiveOpacity = document.getElementById('val-inactive-opacity');

    let currentConfig = {};
    let selectedWallpaper = null;
    let selectedTheme = 'auto'; // 'auto' or 'extracted-dark' etc
    let customPalettes = {};

    const availableWaybarModules = ['tray', 'network', 'bluetooth', 'wireplumber', 'backlight', 'battery', 'custom/notification'];

    const renderWaybarToggles = () => {
        waybarModules.innerHTML = '';
        availableWaybarModules.forEach(mod => {
            const isEnabled = currentConfig.waybar_modules && currentConfig.waybar_modules.includes(mod);
            const div = document.createElement('div');
            div.className = 'list-item';
            div.innerHTML = `
                <span class="label">${mod.replace('custom/', '').charAt(0).toUpperCase() + mod.replace('custom/', '').slice(1)}</span>
                <label class="ios-toggle">
                    <input type="checkbox" id="wb-${mod.replace('/', '-')}" ${isEnabled ? 'checked' : ''}>
                    <span class="slider"></span>
                </label>
            `;
            waybarModules.appendChild(div);

            document.getElementById(`wb-${mod.replace('/', '-')}`).addEventListener('change', (e) => {
                if (!currentConfig.waybar_modules) currentConfig.waybar_modules = [];
                if (e.target.checked) {
                    if (!currentConfig.waybar_modules.includes(mod)) currentConfig.waybar_modules.push(mod);
                } else {
                    currentConfig.waybar_modules = currentConfig.waybar_modules.filter(m => m !== mod);
                }
                sendUpdate({ waybar: currentConfig.waybar_modules });
            });
        });
    };

    const extractMatugenColors = async (wall) => {
        try {
            pieSelector.innerHTML = '<div style="padding: 20px; color: #8e8e93;">Extracting Matugen colors...</div>';
            const res = await fetch('/api/extract', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ wallpaper: wall })
            });
            if (res.ok) {
                customPalettes = await res.json();
                renderPieCharts();
            } else {
                pieSelector.innerHTML = '<div style="padding: 20px; color: #ff453a;">Failed to extract.</div>';
            }
        } catch (e) {
            console.error(e);
        }
    };

    const renderPieCharts = () => {
        pieSelector.innerHTML = '';
        
        // Auto / Default option (Stylix)
        const autoPie = document.createElement('div');
        autoPie.className = `pie-chart ${selectedTheme === 'auto' ? 'active' : ''}`;
        autoPie.style.background = 'conic-gradient(#555 0% 25%, #888 25% 50%, #aaa 50% 75%, #ccc 75% 100%)';
        autoPie.title = "Auto (Stylix)";
        autoPie.onclick = () => selectTheme('auto');
        pieSelector.appendChild(autoPie);

        // Extracted options
        Object.entries(customPalettes).forEach(([themeKey, palette]) => {
            const pie = document.createElement('div');
            pie.className = `pie-chart ${selectedTheme === themeKey ? 'active' : ''}`;
            
            // bg(base00), text(base05), primary(base0D), accent(base08)
            const c1 = '#' + palette['base00'];
            const c2 = '#' + palette['base05'];
            const c3 = '#' + palette['base0D'];
            const c4 = '#' + palette['base08'];

            pie.style.background = `conic-gradient(${c1} 0% 25%, ${c2} 25% 50%, ${c3} 50% 75%, ${c4} 75% 100%)`;
            pie.title = themeKey;
            pie.onclick = () => selectTheme(themeKey);
            pieSelector.appendChild(pie);
        });

        // Hardcoded presets
        const hardcoded = {
            'catppuccin-mocha': { base00: '1e1e2e', base05: 'cdd6f4', base0D: '89b4fa', base08: 'f38ba8' },
            'dracula': { base00: '282a36', base05: 'f8f8f2', base0D: 'bd93f9', base08: 'ff5555' }
        };
        Object.entries(hardcoded).forEach(([themeKey, p]) => {
            const pie = document.createElement('div');
            pie.className = `pie-chart ${selectedTheme === themeKey ? 'active' : ''}`;
            pie.style.background = `conic-gradient(#${p.base00} 0% 25%, #${p.base05} 25% 50%, #${p.base0D} 50% 75%, #${p.base08} 75% 100%)`;
            pie.title = themeKey;
            pie.onclick = () => selectTheme(themeKey);
            pieSelector.appendChild(pie);
        });
    };

    const selectTheme = (themeKey) => {
        selectedTheme = themeKey;
        renderPieCharts(); // update active class
    };

    const loadData = async () => {
        try {
            const res = await fetch('/api/status');
            const data = await res.json();
            currentConfig = data;
            
            elGapsIn.value = data.gaps_in;
            valGapsIn.innerText = data.gaps_in;
            elGapsOut.value = data.gaps_out;
            valGapsOut.innerText = data.gaps_out;
            elRounding.value = data.rounding;
            valRounding.innerText = data.rounding;
            elWaybarRadius.value = data.waybar_radius;
            valWaybarRadius.innerText = data.waybar_radius;
            elActiveOpacity.value = data.active_opacity;
            valActiveOpacity.innerText = data.active_opacity;
            elInactiveOpacity.value = data.inactive_opacity;
            valInactiveOpacity.innerText = data.inactive_opacity;
            
            toggleBlur.checked = data.blur;
            toggleAnimations.checked = data.animations;
            if (toggleAutoupdate) {
                toggleAutoupdate.checked = data.auto_update !== undefined ? data.auto_update : true;
            }
            
            if (data.color_preset) selectedTheme = data.color_preset;

            selectedWallpaper = data.current_wallpaper;

            document.querySelectorAll('.wall-item:not(.upload-btn)').forEach(el => el.remove());

            data.wallpapers.forEach(wall => {
                const div = document.createElement('div');
                div.className = 'wall-item';
                if (wall === selectedWallpaper) div.classList.add('active');
                div.style.backgroundImage = `url('/wallpapers/${wall}')`;
                div.onclick = async () => {
                    document.querySelectorAll('.wall-item').forEach(el => el.classList.remove('active'));
                    div.classList.add('active');
                    selectedWallpaper = wall;
                    sendUpdate({ wallpaper: wall });
                    await extractMatugenColors(wall);
                };
                grid.appendChild(div);
            });

            renderWaybarToggles();
            await extractMatugenColors(selectedWallpaper);
        } catch (e) {
            console.error("Failed to load status:", e);
        }
    };

    await loadData();

    let timeout;
    const sendUpdate = (payload) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => {
            fetch('/api/set', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
        }, 100);
    };

    const setupSlider = (el, valEl, key, isFloat = false) => {
        el.addEventListener('input', (e) => {
            const val = e.target.value;
            valEl.innerText = val;
            currentConfig[key] = isFloat ? parseFloat(val) : parseInt(val);
            sendUpdate({ [key]: currentConfig[key] });
        });
    };

    setupSlider(elGapsIn, valGapsIn, 'gaps_in');
    setupSlider(elGapsOut, valGapsOut, 'gaps_out');
    setupSlider(elRounding, valRounding, 'rounding');
    setupSlider(elWaybarRadius, valWaybarRadius, 'waybar_radius');
    setupSlider(elActiveOpacity, valActiveOpacity, 'active_opacity', true);
    setupSlider(elInactiveOpacity, valInactiveOpacity, 'inactive_opacity', true);

    toggleBlur.addEventListener('change', (e) => {
        currentConfig.blur = e.target.checked;
        sendUpdate({ blur: currentConfig.blur });
    });

    toggleAnimations.addEventListener('change', (e) => {
        currentConfig.animations = e.target.checked;
        sendUpdate({ animations: currentConfig.animations });
    });

    if (toggleAutoupdate) {
        toggleAutoupdate.addEventListener('change', (e) => {
            currentConfig.auto_update = e.target.checked;
            sendUpdate({ auto_update: currentConfig.auto_update });
        });
    }

    btnUpload.addEventListener('click', () => fileUpload.click());
    fileUpload.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = async (ev) => {
            const base64Data = ev.target.result;
            await fetch('/api/upload', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ filename: file.name, data: base64Data })
            });
            await loadData();
        };
        reader.readAsDataURL(file);
    });

    btnSave.addEventListener('click', async () => {
        const originalText = btnSave.innerHTML;
        btnSave.innerHTML = "Saving & Rebuilding...";
        btnSave.disabled = true;
        
        let customPalette = null;
        if (selectedTheme.startsWith('extracted-')) {
            customPalette = customPalettes[selectedTheme];
        }

        try {
            await fetch('/api/save', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    gaps_in: currentConfig.gaps_in,
                    gaps_out: currentConfig.gaps_out,
                    rounding: currentConfig.rounding,
                    active_opacity: currentConfig.active_opacity,
                    inactive_opacity: currentConfig.inactive_opacity,
                    blur: currentConfig.blur,
                    animations: currentConfig.animations,
                    auto_update: toggleAutoupdate ? toggleAutoupdate.checked : true,
                    wallpaper: selectedWallpaper,
                    color_preset: selectedTheme,
                    custom_palette: customPalette
                })
            });
        } catch (e) {
            console.error(e);
        }
        
        setTimeout(() => {
            btnSave.innerHTML = originalText;
            btnSave.disabled = false;
        }, 3000);
    });
});
