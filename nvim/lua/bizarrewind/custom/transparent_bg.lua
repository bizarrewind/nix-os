local function set_transparent_bg()
	local highlights = {
		NonText = { ctermbg = nil, guibg = nil },
		Normal = { guibg = nil, ctermbg = nil },
		NormalNC = { guibg = nil, ctermbg = nil },
		SignColumn = { ctermbg = nil, ctermfg = nil, guibg = nil },
		Pmenu = { ctermbg = nil, ctermfg = nil, guibg = nil },
		FloatBorder = { ctermbg = nil, ctermfg = nil, guibg = nil },
		NormalFloat = { ctermbg = nil, ctermfg = nil, guibg = nil },
		TabLine = { ctermbg = nil, ctermfg = nil, guibg = nil },
		NeoTreeNormal = { guibg = nil, ctermbg = nil },
		NeoTreeNormalNC = { guibg = nil, ctermbg = nil },
		NeoTreeCursorLine = { guibg = nil, ctermbg = nil },
		NeoTreeIndentMarker = { guibg = nil, ctermbg = nil },
		NeoTreeStatusLine = { guibg = nil, ctermbg = nil },
	}

	local ok, dyn_palette = pcall(dofile, os.getenv("HOME") .. "/.config/dynamic-colors/nvim-palette.lua")
	local palette = ok and dyn_palette or {
		fire_gold   = "#e8a83a",
		fire_amber  = "#c87f3e",
		ember       = "#d4622a",
		ice_blue    = "#9ab0c8",
		smoke       = "#8a8070",
		ash_dark    = "#1a1510",
		ash_medium  = "#2a2018",
		text_bright = "#f5f0e8",
		text_muted  = "#9a9080",
		bg_black    = "#050404",
	}

	-- Apply the transparent highlights
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end

	local hl = vim.api.nvim_set_hl

	-- Liquid Glass highlights
	hl(0, "LineNr",           { fg = palette.smoke })
	hl(0, "CursorLineNr",     { fg = palette.fire_gold, bold = true })
	hl(0, "CursorLine",       { bg = palette.ash_dark })
	hl(0, "Search",           { fg = palette.bg_black, bg = palette.fire_gold })
	hl(0, "IncSearch",        { fg = palette.bg_black, bg = palette.ember })
	hl(0, "CurSearch",        { fg = palette.bg_black, bg = palette.fire_amber })
	hl(0, "Visual",           { bg = "#1e2a38" })
	hl(0, "VisualNOS",        { bg = "#1e2a38" })
	hl(0, "StatusLine",       { fg = palette.text_bright, bg = palette.ash_dark })
	hl(0, "StatusLineNC",     { fg = palette.smoke,       bg = palette.bg_black })
	hl(0, "MatchParen",       { fg = palette.fire_gold, bg = palette.ash_medium, bold = true })
	hl(0, "PmenuSel",         { fg = palette.bg_black,    bg = palette.fire_gold })
	hl(0, "PmenuSbar",        { bg = palette.ash_medium })
	hl(0, "PmenuThumb",       { bg = palette.smoke })
	hl(0, "DiagnosticError",  { fg = palette.ember })
	hl(0, "DiagnosticWarn",   { fg = palette.fire_amber })
	hl(0, "DiagnosticInfo",   { fg = palette.ice_blue })
	hl(0, "DiagnosticHint",   { fg = palette.smoke })
	hl(0, "DiffAdd",          { fg = "#8ec87a" })
	hl(0, "DiffChange",       { fg = palette.fire_amber })
	hl(0, "DiffDelete",       { fg = palette.ember })
	hl(0, "WinSeparator",     { fg = palette.ash_medium })
end

-- Call the function to apply transparency
set_transparent_bg()
