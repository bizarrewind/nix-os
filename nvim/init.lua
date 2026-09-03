vim.o.shell = "/bin/zsh"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Options must load before plugins so vim settings are available during plugin setup
require("bizarrewind.options")

require("lazy").setup({
  { import = "bizarrewind.plugins" },
}, {
  lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",
  ui = { icons = {} },
  change_detection = { notify = false },
})

require("bizarrewind.keymaps")
require("bizarrewind.custom.transparent_bg")
require("bizarrewind.custom.autoexec")
require("bizarrewind.custom.floaterminal")
