-- auto install packer if not installed
--
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])

-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
  return
end

-- add list of plugins to install
return packer.startup(function(use)
  -- packer can manage itself
  use("wbthomason/packer.nvim")

  use("nvim-lua/plenary.nvim") -- lua functions that many plugins use
  use("mfussenegger/nvim-dap")
  use("MunifTanjim/nui.nvim")

  use("BurntSushi/ripgrep")

  use("sharkdp/fd")

  use("bluz71/vim-nightfly-guicolors") -- preferred colorscheme

  -- use({ "catppuccin/nvim", as = "catppuccin" }) -- catppuccin colorscheme
  use({ "maxmx03/fluoromachine.nvim" })

  use("christoomey/vim-tmux-navigator") -- tmux & split window navigation

  use("szw/vim-maximizer")              -- maximizes and restores current window

  -- essential plugins
  use("tpope/vim-surround")               -- add, delete, change surroundings (it's awesome)
  use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)

  -- commenting with gc
  use("numToStr/Comment.nvim")

  -- file explorer
  use("nvim-tree/nvim-tree.lua")

  -- vs-code like icons
  use("nvim-tree/nvim-web-devicons")

  -- statusline
  use("nvim-lualine/lualine.nvim")

  -- fuzzy finding w/ telescope
  use("junegunn/fzf.vim")
  use({
    "junegunn/fzf",
    run = function()
      vim.fn["fzf#install"]()
    end,
  })
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
  use({
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    requires = {
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
    end,
  }) -- fuzzy finder

  -- Dev environment
  use("barrett-ruth/live-server.nvim")
  -- autocompletion
  use("hrsh7th/nvim-cmp")   -- completion plugin
  use("hrsh7th/cmp-buffer") -- source for text in buffer
  use("hrsh7th/cmp-path")   -- source for file system paths

  -- snippets
  use({ "L3MON4D3/LuaSnip", run = "make install_jsregexp" })
  use("saadparwaiz1/cmp_luasnip")     -- for autocompletion
  use("rafamadriz/friendly-snippets") -- useful snippets

  -- managing & installing lsp servers, linters & formatters
  use("williamboman/mason.nvim")           -- in charge of managing lsp servers, linters & formatters
  use("williamboman/mason-lspconfig.nvim") -- bridges gap b/w mason & lspconfig

  -- configuring lsp servers
  use("neovim/nvim-lspconfig") -- easily configure language servers
  use("hrsh7th/cmp-nvim-lsp")  -- for autocompletion

  use({
    "nvimdev/lspsaga.nvim",
    branch = "main",
    requires = {
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-treesitter/nvim-treesitter" },
    },
  })                                        -- enhanced lsp uis
  use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
  use("onsails/lspkind.nvim")               -- vs-code like icons for autocompletion

  -- formatting & linting
  -- use({"jose-elias-alvarez/null-ls.nvim",requires = { { "nvim-lua/plenary.nvim" }}}) -- configure formatters & linters
  -- use("jayp0521/mason-null-ls.nvim") -- bridges gap b/w mason & null-ls
  use("mfussenegger/nvim-lint")
  use("rshkarin/mason-nvim-lint")
  use("dense-analysis/ale")
  use({
    "psf/black",
    branch = "stable",
  })
  -- treesitter configuration
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  })

  -- auto closing
  use({ "windwp/nvim-autopairs", event = "InsertEnter" }) -- autoclose parens, brackets, quotes, etc...
  use({
    "windwp/nvim-ts-autotag",
    config = function()
      require("sufu.plugins.treesitter")
    end,
  }) -- autoclose tags

  -- git integration
  use("lewis6991/gitsigns.nvim") -- show line modifications on left hand side

  -- Rust Plugin
  use("rust-lang/rust.vim")
  use({
    "cordx56/rustowl",
    requires = {
      "neovim/nvim-lspconfig",
    }
  })

  -- Flutter Plugins
  use("dart-lang/dart-vim-plugin")
  use("thosakwe/vim-flutter")

  use("natebosch/vim-lsc")
  use({
    "natebosch/vim-lsc-dart",
    run = function()
      vim.g.lsc_auto_map = true
    end,
  })
  -- vim Script
  use("iamcco/vim-language-server")
  use({
    "akinsho/flutter-tools.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
  })

  -- huge file support
  use({
    "LunarVim/bigfile.nvim",
  })
  -- gradle Plugin
  use("microsoft/vscode-gradle")

  -- DataBase
  use("tpope/vim-dadbod")
  use("kristijanhusak/vim-dadbod-ui")
  use("kristijanhusak/vim-dadbod-completion")
  use({
    "VonHeikemen/lsp-zero.nvim",
    requires = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      -- "L3MON4D3/LuaSnip",
    },
  })

  -- AI & MCP
  use 'stevearc/dressing.nvim'
  use 'MeanderingProgrammer/render-markdown.nvim'
  use 'HakonHarnes/img-clip.nvim'
  use ({
    "zbirenbaum/copilot.lua",
   })
  use({
    'yetone/avante.nvim',
    branch = 'main',
    run = 'make',
  })
  use({ "nomnivore/ollama.nvim", requires = { "nvim-lua/plenary.nvim" } })
  use({
    "ravitemer/mcphub.nvim",
    run = 'lua bundled_build.lua',
    dependencies = {
      "nvim-lua/plenary.nvim",
    }})

  -- FTP
  use("tpope/vim-vinegar")

  if packer_bootstrap then
    require("packer").sync()
  end
end)
