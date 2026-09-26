-- Configuration from:
-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

local dap = require("dap")

---------------------------------------------------------------------------
-- Adapter
---------------------------------------------------------------------------

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = {
        "--interpreter=dap",
        "--eval-command",
        "set print pretty on",
    },
}

---------------------------------------------------------------------------
-- DAP terminal
---------------------------------------------------------------------------

-- Show the program's stdin/stdout/stderr in a terminal split.
dap.defaults.fallback.terminal_win_cmd = "belowright 12split new"

-- Don't automatically move focus to the terminal.
dap.defaults.fallback.focus_terminal = false

---------------------------------------------------------------------------
-- Build and Debug
---------------------------------------------------------------------------

-- Temporary executable used by the "Build & Debug" configuration.
--
-- It is stored outside the project so that compiling/debugging does not
-- leave an executable in the source directory.
local build_output = vim.fn.stdpath("cache") .. "/nvim-dap-debug"

-- Tracks whether the current DAP session created build_output.
local cleanup_build = false

-- Build the currently opened C/C++ source file.
local function build_current_file()
    local source = vim.fn.expand("%:p")

    if source == "" then
        vim.notify(
            "No source file is currently open",
            vim.log.levels.ERROR
        )
        return nil
    end

    local extension = vim.fn.expand("%:e")

    local compiler

    if extension == "c" then
        compiler = "gcc"
    elseif extension == "cpp" or extension == "cc" or extension == "cxx" then
        compiler = "g++"
    else
        vim.notify(
            "Unsupported source file extension: ." .. extension,
            vim.log.levels.ERROR
        )
        return nil
    end

    vim.notify(
        "Building " .. vim.fn.fnamemodify(source, ":t") .. "...",
        vim.log.levels.INFO
    )

    local result = vim.system({
        compiler,
        "-g",
        "-Wall",
        "-Wextra",
        source,
        "-o",
        build_output,
    }, {
        text = true,
    }):wait()

    if result.code ~= 0 then
        local output = result.stderr

        if output == nil or output == "" then
            output = result.stdout
        end

        vim.notify(
            "Build failed:\n\n" .. output,
            vim.log.levels.ERROR
        )

        return nil
    end

    cleanup_build = true

    vim.notify(
        "Build successful",
        vim.log.levels.INFO
    )

    return build_output
end

---------------------------------------------------------------------------
-- Make project
---------------------------------------------------------------------------

-- Get the DEBUG_TARGET from make. Expose it from the makefile with:
--  print-debug-target:
--      @printf '%s\n' "$(DEBUG_TARGET)"
-- Assuming there's a DEBUG_TARGET variable
local function get_make_variable(target)
    local result = vim.system({
        "make",
        "-s",
        target,
    }, {
        cwd = vim.fn.getcwd(),
        text = true,
    }):wait()

    if result.code ~= 0 then
        return nil
    end

    return vim.trim(result.stdout)
end

local function make_debug_project()
    local cwd = vim.fn.getcwd()

    vim.notify(
        "Building debug version...",
        vim.log.levels.INFO
    )

    local result = vim.system({
        "make",
        "debug",
    }, {
        cwd = cwd,
        text = true,
    }):wait()

    if result.code ~= 0 then
        local output = result.stdout or ""

        if result.stderr ~= nil and result.stderr ~= "" then
            output = output .. "\n" .. result.stderr
        end

        vim.notify(
            "Debug build failed:\n\n" .. output,
            vim.log.levels.ERROR
        )

        return nil
    end

    local relative_target = get_make_variable("print-debug-target")

    if not relative_target or relative_target == "" then
        vim.notify(
            "Could not determine debug executable",
            vim.log.levels.ERROR
        )

        return nil
    end

    local program = vim.fs.joinpath(
        cwd,
        relative_target
    )

    if vim.fn.executable(program) == 0 then
        vim.notify(
            "Debug executable is not executable:\n" .. program,
            vim.log.levels.ERROR
        )

        return nil
    end

    vim.notify(
        "Starting debugger: " .. program,
        vim.log.levels.INFO
    )

    return program
end

---------------------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------------------

local function cleanup_build_output()
    if not cleanup_build then
        return
    end

    if vim.fn.filereadable(build_output) == 1 then
        vim.fn.delete(build_output)
    end

    cleanup_build = false
end

-- Clean up when the debugged program exits normally.
dap.listeners.after.event_exited["build_and_debug_cleanup"] =
    cleanup_build_output

-- Clean up when the debug session is terminated.
dap.listeners.after.event_terminated["build_and_debug_cleanup"] =
    cleanup_build_output

---------------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------------

dap.configurations.c = {
    -- Existing configuration: Launch executable
    {
        name = "Launch",
        type = "gdb",
        request = "launch",

        program = function()
            return vim.fn.input(
                "Path to executable: ",
                vim.fn.getcwd() .. "/",
                "file"
            )
        end,

        args = {},

        cwd = "${workspaceFolder}",

        stopAtBeginningOfMainSubprogram = false,
    },
    -- Build current C file and debug it
    {
        name = "Build & Debug",
        type = "gdb",
        request = "launch",

        program = function()
            return build_current_file()
        end,

        args = {},

        cwd = "${workspaceFolder}",

        stopAtBeginningOfMainSubprogram = false,
    },
    -- Run make, then select the executable to debug
    {
        name = "Make & Debug",
        type = "gdb",
        request = "launch",

        program = function()
            return make_debug_project()
        end,

        args = {},

        cwd = "${workspaceFolder}",

        stopAtBeginningOfMainSubprogram = false,
    },
    {
        name = "Select and attach to process",
        type = "gdb",
        request = "attach",

        program = function()
            return vim.fn.input(
                "Path to executable: ",
                vim.fn.getcwd() .. "/",
                "file"
            )
        end,

        pid = function()
            local name = vim.fn.input(
                "Executable name (filter): "
            )

            return require("dap.utils").pick_process({
                filter = name,
            })
        end,

        cwd = "${workspaceFolder}",
    },
    {
        name = "Attach to gdbserver :1234",
        type = "gdb",
        request = "attach",

        target = "localhost:1234",

        program = function()
            return vim.fn.input(
                "Path to executable: ",
                vim.fn.getcwd() .. "/",
                "file"
            )
        end,

        cwd = "${workspaceFolder}",
    },
}

-- Use the same configurations for C++.
-- build_current_file() automatically chooses gcc for C and g++ for C++.
dap.configurations.cpp = dap.configurations.c
