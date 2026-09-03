-- All keymaps. Harpoon keymaps are set inside the harpoon plugin config.
local map = vim.keymap.set

-- ── Tabs ────────────────────────────────────────────────────────────────────
map("n", "<leader>b",    "<cmd>tabnew<CR>",  { desc = "New tab" })
map("n", "<leader><Tab>","gt",               { desc = "Cycle tabs" })
for i = 1, 9 do
  map("n", "<leader>" .. i, i .. "gt", { noremap = true, silent = true, desc = "Tab " .. i })
end

-- ── Buffers ─────────────────────────────────────────────────────────────────
map("n", "<Tab>",   "<cmd>bnext<CR>",  { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprev<CR>",  { desc = "Prev buffer" })

-- ── General ─────────────────────────────────────────────────────────────────
map("n", "<leader>pv", vim.cmd.Ex,              { desc = "File explorer" })
map("n", "<Esc>",      "<cmd>nohlsearch<CR>",   { desc = "Clear search highlight" })
map("n", ";",          ":",                     { desc = "Command mode" })
map("i", "jk",         "<Esc>",                 { desc = "Exit insert mode" })

-- ── Clipboard ───────────────────────────────────────────────────────────────
map("v", "ys", '"+y', { noremap = true, desc = "Yank to system clipboard" })
map("n", "yp", '"+p', { noremap = true, desc = "Paste from system clipboard" })

-- ── Diagnostics ─────────────────────────────────────────────────────────────
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })

-- ── Windows ─────────────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w><C-h>", { desc = "Focus left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Focus right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Focus upper window" })

-- ── Terminal ────────────────────────────────────────────────────────────────
map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
