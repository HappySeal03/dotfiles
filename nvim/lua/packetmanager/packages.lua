local gh = function(repo)
    return "https://github.com/" .. repo
end

vim.pack.add({
    -- Completion
    gh("hrsh7th/nvim-cmp"),
    gh("hrsh7th/cmp-nvim-lsp"),

    -- LSP
    gh("neovim/nvim-lspconfig"),

    -- Mason
    gh("mason-org/mason.nvim"),
    gh("mason-org/mason-lspconfig.nvim"),
    gh("jay-babu/mason-nvim-dap.nvim"),

    -- DAP
    gh("mfussenegger/nvim-dap"),
    gh("rcarriga/nvim-dap-ui"),
    gh("nvim-neotest/nvim-nio"),
    gh("theHamsta/nvim-dap-virtual-text"),
    gh("leoluz/nvim-dap-go"),

    -- UI
    gh("nvim-tree/nvim-web-devicons"),
    gh("akinsho/bufferline.nvim"),
    gh("Mofiqul/vscode.nvim"),
    gh("catppuccin/nvim"),

    -- Editing
    gh("windwp/nvim-autopairs"),
    gh("terrortylor/nvim-comment"),

    -- File tree
    gh("nvim-tree/nvim-tree.lua"),

    -- LaTeX
    gh("lervag/vimtex"),

    -- Git
    gh("NeogitOrg/neogit"),
    gh("nvim-lua/plenary.nvim"),
    gh("sindrets/diffview.nvim"),

    -- Telescope
    gh("nvim-telescope/telescope.nvim"),

    -- Typst
    gh("chomosuke/typst-preview.nvim"),
})

require("plugins.autoclose")
require("plugins.bufferline")
require("plugins.colorscheme")
require("plugins.comment_toggle")

require("plugins.dap")
require("plugins.debugging.go")

require("plugins.filetree")
require("plugins.latex")
require("plugins.lsp")
require("plugins.mason")
require("plugins.neogit")
require("plugins.telescope")
require("plugins.typst")
