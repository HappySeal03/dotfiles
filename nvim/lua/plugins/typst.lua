-- Typst
require("typst-preview").setup({
    open_cmd = "firefox %s",
    dependencies_bin = {
        tinymist = "tinymist",
    },
})

vim.keymap.set("n", "<leader>tc", "<cmd>TypstPreviewToggle<cr>", {
    desc = "Toggle Typst preview",
})
