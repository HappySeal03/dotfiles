-- File tree
require("nvim-tree").setup({})

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", {
    desc = "Toggle nvim-tree",
})
