-- Mason
require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = {},
    automatic_installation = true,
})

require("mason-nvim-dap").setup({
    automatic_installation = true,
    ensure_installed = {},
})
