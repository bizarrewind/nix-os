-- All plugins in one file. lazy.nvim scans this directory automatically.
-- Each return value is one plugin spec.

return {

  -- ── Icons ──────────────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Which-key (show keybind hints) ─────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { "<leader>s", group = "[S]earch" },
        { "<leader>t", group = "[T]oggle" },
      },
    },
  },

  -- ── Statusline ──────────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
        globalstatus = false,
        always_show_tabline = false,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "buffers", show_filename_only = true, symbols = { modified = " ●" } } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      tabline = {},
    },
  },

  -- ── Git signs in the gutter ─────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- ── Treesitter syntax highlighting ──────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "nix", "bash", "lua", "luadoc", "vim", "vimdoc",
          "c", "java", "kotlin", "python",
          "html", "typescript", "javascript",
          "json", "yaml", "toml",
          "diff", "markdown", "markdown_inline", "query",
        },
        auto_install = true,
        highlight    = { enable = true },
        indent       = { enable = true },
      })
    end,
  },

  -- ── Telescope fuzzy finder ──────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    event        = "VimEnter",
    branch       = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make",
        cond = function() return vim.fn.executable("make") == 1 end },
      "nvim-telescope/telescope-ui-select.nvim",
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
        defaults = {
          file_ignore_patterns = { "%.class$", "%.out" },
        },
      })
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local b = require("telescope.builtin")
      local map = vim.keymap.set
      map("n", "<leader>sh", b.help_tags,  { desc = "[S]earch [H]elp" })
      map("n", "<leader>sk", b.keymaps,    { desc = "[S]earch [K]eymaps" })
      map("n", "<leader>sf", b.find_files, { desc = "[S]earch [F]iles" })
      map("n", "<leader>ss", b.builtin,    { desc = "[S]earch [S]elect Telescope" })
      map("n", "<leader>sw", b.grep_string,{ desc = "[S]earch current [W]ord" })
      map("n", "<leader>sg", b.live_grep,  { desc = "[S]earch by [G]rep" })
      map("n", "<leader>sd", b.diagnostics,{ desc = "[S]earch [D]iagnostics" })
      map("n", "<leader>sr", b.resume,     { desc = "[S]earch [R]esume" })
      map("n", "<leader>s.", b.oldfiles,   { desc = '[S]earch Recent Files' })
      map("n", "<leader><leader>", b.buffers, { desc = "[ ] Find buffers" })
      map("n", "<leader>sn", function()
        b.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })
      map("n", "<leader>/", function()
        b.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10, previewer = false,
        }))
      end, { desc = "[/] Fuzzy search buffer" })
    end,
  },

  -- ── LSP ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },   -- LSP progress in corner
      { "folke/lazydev.nvim", ft = "lua", opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } } },
      "saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("bw-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          local b = require("telescope.builtin")
          map("grn", vim.lsp.buf.rename,        "[R]e[n]ame")
          map("ga",  vim.lsp.buf.code_action,   "Code [A]ction", { "n", "x" })
          map("gr",  b.lsp_references,          "[G]oto [R]eferences")
          map("gi",  b.lsp_implementations,     "[G]oto [I]mplementation")
          map("gd",  b.lsp_definitions,         "[G]oto [D]efinition")
          map("gD",  vim.lsp.buf.declaration,   "[G]oto [D]eclaration")
          map("gO",  b.lsp_document_symbols,    "Document Symbols")
          map("gW",  b.lsp_dynamic_workspace_symbols, "Workspace Symbols")
          map("grt", b.lsp_type_definitions,    "[G]oto [T]ype Definition")
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, "[T]oggle Inlay [H]ints")

          -- Highlight symbol under cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local function supports(method)
            if vim.fn.has("nvim-0.11") == 1 then
              return client and client:supports_method(method, event.buf)
            else
              return client and client.supports_method(method, { bufnr = event.buf })
            end
          end
          if supports(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local hl_group = vim.api.nvim_create_augroup("bw-lsp-hl", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf, group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf, group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("bw-lsp-detach", { clear = true }),
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "bw-lsp-hl", buffer = ev.buf })
              end,
            })
          end
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN]  = "󰀪 ",
            [vim.diagnostic.severity.INFO]  = "󰋽 ",
            [vim.diagnostic.severity.HINT]  = "󰌶 ",
          },
        },
        virtual_text = { source = "if_many", spacing = 2 },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local servers = {
        lua_ls = {
          settings = { Lua = { completion = { callSnippet = "Replace" } } },
        },
        nil_ls      = {},  -- Nix
        pyright     = {},  -- Python
        kotlin_language_server = {},
      }

      require("mason-tool-installer").setup({
        ensure_installed = vim.list_extend(vim.tbl_keys(servers), { "stylua" }),
      })
      require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local cfg = servers[server_name] or {}
            cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
            require("lspconfig")[server_name].setup(cfg)
          end,
        },
      })
    end,
  },

  -- ── Completion ──────────────────────────────────────────────────────────────
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = {
      keymap = { preset = "enter" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        ghost_text = { enabled = true },
        menu = {
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
      },
      signature = { enabled = true },
    },
  },

  -- ── Autoformat ──────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd   = "ConformInfo",
    keys  = {
      { "<leader>f", function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = "", desc = "[F]ormat buffer" },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local slow = { c = true }
        return {
          timeout_ms = 500,
          lsp_format = slow[vim.bo[bufnr].filetype] and "never" or "fallback",
        }
      end,
      formatters_by_ft = {
        lua    = { "stylua" },
        python = { "black" },
        c      = { "clang-format" },
        java   = { "google-java-format" },
        kotlin = { "ktlint" },
      },
    },
  },

  -- ── Autopairs ───────────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = { check_ts = true },
  },

  -- ── Harpoon (quick file switching) ──────────────────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      local map = vim.keymap.set
      map("n", "<leader>a", function() harpoon:list():add() end,           { desc = "Harpoon add" })
      map("n", "<C-e>",     function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      map("n", "<C-1>",     function() harpoon:list():select(1) end,       { desc = "Harpoon 1" })
      map("n", "<C-2>",     function() harpoon:list():select(2) end,       { desc = "Harpoon 2" })
      map("n", "<C-3>",     function() harpoon:list():select(3) end,       { desc = "Harpoon 3" })
      map("n", "<C-4>",     function() harpoon:list():select(4) end,       { desc = "Harpoon 4" })
      map("n", "<C-S-P>",   function() harpoon:list():prev() end,          { desc = "Harpoon prev" })
      map("n", "<C-S-N>",   function() harpoon:list():next() end,          { desc = "Harpoon next" })
    end,
  },

  -- ── Todo comments (TODO/FIXME/HACK highlights) ───────────────────────────────
  {
    "folke/todo-comments.nvim",
    event        = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = { signs = false },
  },

  -- ── Indent guides ───────────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope  = { enabled = false },
    },
  },

  -- ── Mini utilities (various small modules) ──────────────────────────────────
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
    end,
  },

}
