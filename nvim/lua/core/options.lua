-- Line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Let the terminal decide on the cursor
vim.opt.guicursor = ""

-- Hide command line when not in use
-- vim.opt.cmdheight = 0

-- Tabs and indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Highlight the line with the cursor
vim.opt.cursorline = true

vim.opt.wrap = false

-- Undo configuration
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- TODO: comment
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.inccommand = "split"

-- Ignore case in searches unless there are uppercase letters in the search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Keep 1 status line for split screens
vim.opt.laststatus = 3

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
-- Allow the @ character in filenames
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Highlight a column all the times
-- vim.opt.colorcolumn = "80"

-- Highlight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Set spell language when a .tex file is open
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en"
    end,
})
