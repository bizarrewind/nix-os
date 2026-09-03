# Neovim Configuration

This directory contains the user's Neovim configuration built with `lazy.nvim`. It is designed to be fully integrated with the system's "Crystal UI" aesthetic through dynamic theming.

## Architecture

- `init.lua`: The entry point that bootstraps `lazy.nvim` and loads the configuration.
- `lua/bizarrewind/options.lua`: Core Neovim options (line numbers, indentations, custom highlight groups).
- `lua/bizarrewind/keymaps.lua`: Global keybindings.
- `lua/bizarrewind/plugins.lua`: The master plugin manifest.
- `lua/bizarrewind/custom/floaterminal.lua`: A custom floating terminal plugin that launches a togglable shell inside Neovim.

## Theming

The Neovim colorscheme is dynamically controlled by Stylix. 
1. When you change your wallpaper, Stylix updates `~/.config/dynamic-colors/nvim-palette.lua`.
2. The `mini.base16` plugin reads this file on startup and generates a Base16 colorscheme that matches your wallpaper exactly.
3. Custom highlights (like `BlinkCmpGhostText`) are reapplied automatically via an `autocmd` in `options.lua`.

## Key Plugins

- **Telescope**: Used for fuzzy finding files and text. Note that it runs off the master branch to ensure compatibility with modern Tree-sitter versions.
- **Mason & LSP Config**: Manages language servers (e.g., `lua_ls`, `nil`).
- **Nvim-Treesitter**: Provides syntax highlighting.
