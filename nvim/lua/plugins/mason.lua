return {
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {}
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },

    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            automatic_installation = true,
            ensure_installed = {
                -- add debuggers you want here
            },
        },
    },
}
