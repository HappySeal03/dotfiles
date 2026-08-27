-- QML specific config
vim.lsp.config("qmlls", {
    cmd = { "/usr/bin/qmlls6" },
    filetypes = { "qml" },
})
vim.lsp.enable("qmlls")
