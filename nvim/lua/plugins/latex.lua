-- LaTeX
vim.g.vimtex_view_general_viewer = "okular"

vim.g.vimtex_compiler_latexmk = {
    aux_dir = "./.latexmk/aux",
    out_dir = "./.latexmk/out",
}

vim.keymap.set("n", "<leader>lc", "<cmd>VimtexCompile<cr>", {
    desc = "VimTeX compile",
})

