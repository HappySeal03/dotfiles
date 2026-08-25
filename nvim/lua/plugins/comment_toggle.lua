-- Comment toggle
require("nvim_comment").setup({
    create_mappings = false,
})

vim.keymap.set({ "n", "v" }, "<leader>\\", "<cmd>CommentToggle<cr>", {
    desc = "Toggle comment",
})
