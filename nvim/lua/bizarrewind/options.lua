-- ── Editor behaviour ────────────────────────────────────────────────────────
vim.g.have_nerd_font   = true
vim.g.netrw_banner     = 1
vim.g.netrw_altv       = 1
vim.g.netrw_preview    = 1
vim.g.netrw_list_hide  = ".class$"

vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.mouse          = "a"
vim.opt.showmode       = false    -- lualine shows mode
vim.opt.laststatus     = 0
vim.opt.cursorline     = true
vim.opt.scrolloff      = 15
vim.opt.signcolumn     = "yes"
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.updatetime     = 250
vim.opt.timeoutlen     = 300

-- Indentation
vim.opt.tabstop    = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab  = true
vim.opt.breakindent = true

-- Search
vim.opt.ignorecase  = true
vim.opt.smartcase   = true
vim.opt.inccommand  = "split"

-- Files
vim.opt.undofile  = true
vim.o.wildignore  = vim.o.wildignore .. ",*.class"

-- Clipboard (async so it doesn't slow startup)
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- ── Autocmds ────────────────────────────────────────────────────────────────
local augroup = vim.api.nvim_create_augroup

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("bw-yank", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("bw-term", { clear = true }),
  callback = function()
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
  end,
})

-- ── Custom tabline ──────────────────────────────────────────────────────────
vim.o.showtabline = 1
vim.o.tabline     = "%!v:lua.MyTabline()"

function _G.MyTabline()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  local s       = ""
  local current = vim.fn.tabpagenr()

  for i = 1, vim.fn.tabpagenr("$") do
    local hl     = (i == current) and "%#TabLineSel#" or "%#TabLine#"
    local bufnr  = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]
    local name   = vim.fn.bufname(bufnr)
    local fname  = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
    local ext    = vim.fn.fnamemodify(fname, ":e")
    local mod    = vim.fn.getbufvar(bufnr, "&modified") == 1 and " ●" or ""

    s = s .. "%" .. i .. "T" .. hl
    if ok then
      local icon, ihl = devicons.get_icon(fname, ext, { default = true })
      if icon then s = s .. "%#" .. ihl .. "#" .. icon .. " " end
    end
    s = s .. fname .. mod .. " "
  end
  return s .. "%#TabLineFill#"
end

vim.api.nvim_set_hl(0, "TabLine",     { bg = "NONE", fg = "#888888" })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "TabLineSel",  { fg = "#ffffff", bg = "#444444", bold = true })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLine",  { bg = "NONE", fg = "#cccccc" })
    vim.api.nvim_set_hl(0, "StatusLineNC",{ bg = "NONE", fg = "#666666" })
    vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#666666", italic = true })
  end,
})
