-- Completion
local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "nvim_lsp" },
    },

    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    }),

    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
})

-- LSP
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("*", {
    capabilities = capabilities,
})

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
        local opts = { buffer = event.buf }
        local border = "rounded"

        vim.diagnostic.config({
            float = { border = border },
        })

        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = border })
        end, opts)

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

        vim.keymap.set("n", "gs", function()
            vim.lsp.buf.signature_help({ border = border })
        end, opts)

        vim.keymap.set("n", "rn", vim.lsp.buf.rename, opts)

        vim.keymap.set({ "n", "x" }, "<F3>", function()
            vim.lsp.buf.format({ async = true })
        end, opts)

        vim.keymap.set("n", "vca", vim.lsp.buf.code_action, opts)

        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)

        local disabled = {
            typst = true,
            markdown = true,
        }

        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = event.buf,
            callback = function()
                if disabled[vim.bo[event.buf].filetype] then
                    return
                end

                vim.lsp.buf.format({
                    async = false,
                })
            end,
        })
    end,
})
