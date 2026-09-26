-- Debug Adapter
local dap = require("dap")
local dapui = require("dapui")

vim.keymap.set("n", "<F5>", dap.continue, {
    desc = "DAP Continue",
})

vim.keymap.set("n", "<F10>", dap.step_over, {
    desc = "DAP Step Over",
})

vim.keymap.set("n", "<F11>", dap.step_into, {
    desc = "DAP Step Into",
})

vim.keymap.set("n", "<F12>", dap.step_out, {
    desc = "DAP Step Out",
})

vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint, {
    desc = "DAP Breakpoint",
})

vim.keymap.set("n", "<Leader>B", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, {
    desc = "DAP Conditional Breakpoint",
})

-- UI
dapui.setup({})

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-- Language specific configurations
require("plugins.debugging.c_cpp")
require("plugins.debugging.rust")
