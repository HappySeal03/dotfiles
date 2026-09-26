-- Configuration from:
-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

local dap = require("dap")

---------------------------------------------------------------------------
-- GDB adapter
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

-- Show stdout/stderr/stdin of the debugged Rust program.
dap.defaults.fallback.terminal_win_cmd = "belowright 12split new"
dap.defaults.fallback.focus_terminal = false

---------------------------------------------------------------------------
-- Cargo helpers
---------------------------------------------------------------------------

local function cargo_metadata()
    local result = vim.system({
        "cargo",
        "metadata",
        "--format-version",
        "1",
        "--no-deps",
    }, {
        cwd = vim.fn.getcwd(),
        text = true,
    }):wait()

    if result.code ~= 0 then
        local output = result.stderr or result.stdout or ""

        vim.notify(
            "cargo metadata failed:\n\n" .. output,
            vim.log.levels.ERROR
        )

        return nil
    end

    local ok, metadata = pcall(
        vim.json.decode,
        result.stdout
    )

    if not ok then
        vim.notify(
            "Failed to parse cargo metadata",
            vim.log.levels.ERROR
        )

        return nil
    end

    return metadata
end

---------------------------------------------------------------------------
-- Find Cargo binary
---------------------------------------------------------------------------

local function cargo_binary()
    local metadata = cargo_metadata()

    if not metadata then
        return nil
    end

    if not metadata.packages or #metadata.packages == 0 then
        vim.notify(
            "No Cargo package found",
            vim.log.levels.ERROR
        )

        return nil
    end

    local package = metadata.packages[1]

    local binaries = {}

    for _, target in ipairs(package.targets or {}) do
        for _, kind in ipairs(target.kind or {}) do
            if kind == "bin" then
                table.insert(binaries, target)
                break
            end
        end
    end

    if #binaries == 0 then
        vim.notify(
            "No binary target found in Cargo project",
            vim.log.levels.ERROR
        )

        return nil
    end

    -----------------------------------------------------------------------
    -- One binary: use it automatically.
    -----------------------------------------------------------------------

    if #binaries == 1 then
        return binaries[1].name
    end

    -----------------------------------------------------------------------
    -- Multiple binaries: ask which one to debug.
    -----------------------------------------------------------------------

    local choices = {}

    for _, binary in ipairs(binaries) do
        table.insert(choices, binary.name)
    end

    local choice = vim.fn.inputlist(
        vim.tbl_extend(
            "list",
            { "Select Cargo binary:" },
            choices
        )
    )

    if choice < 1 or choice > #choices then
        vim.notify(
            "No Cargo binary selected",
            vim.log.levels.ERROR
        )

        return nil
    end

    return choices[choice]
end

---------------------------------------------------------------------------
-- Cargo build + find executable
---------------------------------------------------------------------------

local function cargo_build()
    local binary = cargo_binary()

    if not binary then
        return nil
    end

    vim.notify(
        "Building Rust project...",
        vim.log.levels.INFO
    )

    local result = vim.system({
        "cargo",
        "build",
    }, {
        cwd = vim.fn.getcwd(),
        text = true,
    }):wait()

    if result.code ~= 0 then
        local output = result.stdout or ""

        if result.stderr ~= nil and result.stderr ~= "" then
            output = output .. "\n" .. result.stderr
        end

        vim.notify(
            "Cargo build failed:\n\n" .. output,
            vim.log.levels.ERROR
        )

        return nil
    end

    -----------------------------------------------------------------------
    -- Cargo's normal debug output directory.
    -----------------------------------------------------------------------

    local program = vim.fs.joinpath(
        vim.fn.getcwd(),
        "target",
        "debug",
        binary
    )

    if vim.fn.executable(program) == 0 then
        vim.notify(
            "Cargo built successfully, but executable was not found:\n"
            .. program,
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
-- Rust configuration
---------------------------------------------------------------------------

dap.configurations.rust = {
    -- Cargo build + debug
    {
        name = "Cargo Build & Debug",
        type = "gdb",
        request = "launch",

        program = function()
            return cargo_build()
        end,

        args = {},

        cwd = "${workspaceFolder}",

        stopAtBeginningOfMainSubprogram = false,
    },
    -- Launch existing executable
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
    -- Attach to process
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
    -- Attach to gdbserver
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
