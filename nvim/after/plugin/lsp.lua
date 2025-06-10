local lsp_zero = require('lsp-zero')

require('java').setup()

vim.diagnostic.config({
    severity_sort = true
})

vim.o.updatetime = 250  -- Reduce delay

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
      scope = 'cursor',
    })
  end,
})

lsp_zero.on_attach(function(client, bufnr)
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gr", function() require 'telescope.builtin'.lsp_references() end, opts)
    vim.keymap.set("n", "<leader>ds", function() require 'telescope.builtin'.lsp_document_symbols() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vt", function() vim.cmd.TroubleToggle() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

local on_attach = function(client, bufnr)
  vim.o.signcolumn = 'yes'

  vim.o.updatetime = 250

  vim.diagnostic.config({virtual_text=false})

  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })

  vim.keymap.set('n', 'K', vim.lsp.buf.hover)

end

require('lspconfig')['unison'].setup {
    on_attach = on_attach,
}

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'rust_analyzer', 'clangd' },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
                require('lspconfig').lua_ls.setup(lua_opts)
            end,

            clangd = function()
            require('lspconfig').clangd.setup ({ 
                    cmd = {
                        "clangd",
                        "--enable-config",
                        "--header-insertion=never",
                        "--compile-commands-dir=${workspaceFolder}/",
                        "--query-driver=**",
                    } 
                })
            end,
    }
})


local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    formatting = lsp_zero.cmp_format(),
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
    },
})


vim.keymap.set("n", "<leader>lm", vim.cmd.Mason);
vim.keymap.set("n", "<leader>li", vim.cmd.LspInfo);
vim.keymap.set("n", "<leader>lI", vim.cmd.LspInstall);
