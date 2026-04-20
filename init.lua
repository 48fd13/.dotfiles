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
vim.g.mapleader = " "

if vim.fn.isdirectory("/opt/homebrew/bin") == 1 then
  vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH
end

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "https://github.com/nvim-telescope/telescope.nvim.git",
    dependencies = { "https://github.com/nvim-lua/plenary.nvim.git" },
    config = function()
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")

      require("telescope").setup({
        defaults = {
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
      })

      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
    end,
  },

  {
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})
      require("nvim-treesitter").install({ "bash", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function()
          pcall(vim.treesitter.start)
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

      vim.keymap.set("n", "<leader>fm", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end)
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
})
