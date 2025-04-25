local rt = require("rust-tools")
rt.setup({})
rt.inlay_hints.set()
rt.inlay_hints.enable()

vim.keymap.set("n", "<leader>le", vim.cmd.RustEnableInlayHints)
vim.keymap.set("n", "<leader>ld", vim.cmd.RustDisableInlayHints)
