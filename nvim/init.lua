vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.o.autoread = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.fn.isdirectory("/opt/homebrew/bin") == 1 then
  vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH
end

local map = vim.keymap.set

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics quickfix" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>wh", "<C-w>h", { desc = "Window left" })
map("n", "<leader>wj", "<C-w>j", { desc = "Window down" })
map("n", "<leader>wk", "<C-w>k", { desc = "Window up" })
map("n", "<leader>wl", "<C-w>l", { desc = "Window right" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split window" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Vertical split" })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
    map("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
    map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "https://github.com/folke/which-key.nvim.git",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code/lsp" },
        { "<leader>e", desc = "Explorer" },
        { "<leader>f", group = "files/search" },
        { "<leader>g", group = "git" },
        { "<leader>o", group = "opencode" },
        { "<leader>w", group = "windows" },
      },
    },
  },

  {
    "https://github.com/nvim-neo-tree/neo-tree.nvim.git",
    branch = "v3.x",
    dependencies = {
      "https://github.com/nvim-lua/plenary.nvim.git",
      "https://github.com/MunifTanjim/nui.nvim.git",
      "https://github.com/nvim-tree/nvim-web-devicons.git",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
      })

      map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", { desc = "Explorer" })
      map("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Reveal file" })
    end,
  },

  {
    "https://github.com/nvim-telescope/telescope.nvim.git",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")
      local ignored_dirs = {
        "%.git/",
        "node_modules/",
        "%.cache/",
        "dist/",
        "build/",
      }

      require("telescope").setup({
        defaults = {
          file_ignore_patterns = ignored_dirs,
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!**/.git/**",
            "--glob=!**/node_modules/**",
            "--glob=!**/.cache/**",
            "--glob=!**/dist/**",
            "--glob=!**/build/**",
          },
          preview = {
            treesitter = false,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
          },
        },
      })

      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      map("n", "<leader>bb", builtin.buffers, { desc = "Buffers" })
      map("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      map("n", "<leader>gf", builtin.git_files, { desc = "Git files" })
      map("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
    end,
  },

  {
    "https://github.com/lewis6991/gitsigns.nvim.git",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr }

          map("n", "]g", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.nav_hunk("next")
            end)
            return "<Ignore>"
          end, vim.tbl_extend("force", opts, { expr = true, desc = "Next git hunk" }))

          map("n", "[g", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.nav_hunk("prev")
            end)
            return "<Ignore>"
          end, vim.tbl_extend("force", opts, { expr = true, desc = "Previous git hunk" }))

          map("n", "<leader>gp", gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))
          map("n", "<leader>gS", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
          map("n", "<leader>gr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
          map("n", "<leader>gb", gs.blame_line, vim.tbl_extend("force", opts, { desc = "Blame line" }))
        end,
      })
    end,
  },

  {
    "https://github.com/sindrets/diffview.nvim.git",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      require("diffview").setup()

      map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open diff view" })
      map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close diff view" })
      map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File history" })
      map("n", "<leader>gg", function()
        if vim.fn.executable("lazygit") ~= 1 then
          vim.notify("lazygit is not installed", vim.log.levels.WARN)
          return
        end

        local width = math.floor(vim.o.columns * 0.9)
        local height = math.floor(vim.o.lines * 0.9)
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          border = "rounded",
        })

        vim.fn.termopen("lazygit", {
          on_exit = function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
          end,
        })
        vim.cmd.startinsert()
      end, { desc = "LazyGit" })
    end,
  },

  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      require("nvim-treesitter").install({ "bash", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  {
    "https://github.com/mason-org/mason.nvim.git",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "https://github.com/mason-org/mason-lspconfig.nvim.git",
    dependencies = {
      "https://github.com/mason-org/mason.nvim.git",
      "https://github.com/neovim/nvim-lspconfig.git",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff" },
      })
    end,
  },

  {
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim.git",
    dependencies = { "https://github.com/mason-org/mason.nvim.git" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = { "black", "isort", "pyright", "ruff" },
      })
    end,
  },

  {
    "https://github.com/L3MON4D3/LuaSnip.git",
    dependencies = { "https://github.com/rafamadriz/friendly-snippets.git" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  {
    "https://github.com/hrsh7th/nvim-cmp.git",
    dependencies = {
      "https://github.com/hrsh7th/cmp-nvim-lsp.git",
      "https://github.com/hrsh7th/cmp-buffer.git",
      "https://github.com/hrsh7th/cmp-path.git",
      "https://github.com/saadparwaiz1/cmp_luasnip.git",
      "https://github.com/L3MON4D3/LuaSnip.git",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  {
    "https://github.com/neovim/nvim-lspconfig.git",
    dependencies = {
      "https://github.com/hrsh7th/cmp-nvim-lsp.git",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("pyright", {
        capabilities = capabilities,
      })
      vim.lsp.enable("pyright")

      vim.lsp.config("ruff", {
        capabilities = capabilities,
      })
      vim.lsp.enable("ruff")
    end,
  },

  {
    "https://github.com/stevearc/conform.nvim.git",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "isort", "black" },
        },
        format_on_save = function(bufnr)
          if vim.bo[bufnr].filetype == "python" then
            return { lsp_fallback = true, timeout_ms = 3000 }
          end
        end,
      })

      map("n", "<leader>fm", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format" })
    end,
  },

  {
    "https://github.com/mfussenegger/nvim-lint.git",
    config = function()
      require("lint").linters_by_ft = {
        python = { "ruff" },
      }

      local lint = require("lint")
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  {
    "https://github.com/nickjvandyke/opencode.nvim.git",
    version = "*",
    config = function()
      vim.g.opencode_opts = {}

      map("n", "<leader>oa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode" })
      map("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })
    end,
  },
})
