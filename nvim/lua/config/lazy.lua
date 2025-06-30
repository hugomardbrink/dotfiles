vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({    
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  { 'VonHeikemen/lsp-zero.nvim', branch = 'v3.x' },
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-path',
  'nvim-lua/plenary.nvim',
  'github/copilot.vim',
  'ThePrimeagen/harpoon',
  'mbbill/undotree',
  'tpope/vim-fugitive',
  'L3MON4D3/LuaSnip',
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  {'simrat39/rust-tools.nvim'},
  { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},
  {"olimorris/onedarkpro.nvim",priority = 1000 },
  {
    'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional
        },
        config = function()
            require("nvim-tree").setup {}
        end
  },
  {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { { 'nvim-lua/plenary.nvim' } }
  },
  {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
  },
  {
    "xiyaowong/transparent.nvim",
        config = function()
            require("transparent").setup({
                extra_groups = {
                    "NormalFloat",   -- plugins which have float panel such as Lazy, Mason, LspInfo
                    "NvimTreeNormal" -- NvimTree
                },
            })
        end
  },
  {
    "unisonweb/unison",
    branch = "trunk",
    config = function(plugin)
        vim.opt.rtp:append(plugin.dir .. "/editor-support/vim")
        require("lazy.core.loader").packadd(plugin.dir .. "/editor-support/vim")
    end,
    init = function(plugin)
         require("lazy.core.loader").ftdetect(plugin.dir .. "/editor-support/vim")
    end,
  },
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = 'general'
    end,
  },
  {
    "nvim-java/nvim-java"
  },
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
        -- Install tries to automatically detect the install method.
        -- if it fails, try calling it with one of these parameters:
        --    "curl", "wget", "bitsadmin", "go"
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup(--[[optional config]])
    end,
  }
})

local lspconfig = require('lspconfig')
lspconfig.gleam.setup({})
require('lspconfig').jdtls.setup({})
