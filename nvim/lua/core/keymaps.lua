vim.g.mapleader = " "

-- Change file
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Buffers (next, previous, close)
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")

-- Copy to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

-- Center after scrolling
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Undo tree
vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle the builtin undo tree" })
