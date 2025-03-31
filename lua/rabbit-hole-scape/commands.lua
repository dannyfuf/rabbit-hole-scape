local M = {}

-- Command units that can be remapped
M.commands = {
    list = {
        name = "RabbitHoleList",
        description = "Show the jump list",
        callback = function()
            require("rabbit-hole-scape").show_jumplist()
        end
    },
    open = {
        name = "RabbitHoleOpen",
        description = "Jump to selected file in the jump list",
        callback = function()
            require("rabbit-hole-scape").jump_to_selected()
        end
    },
    clear = {
        name = "RabbitHoleClear",
        description = "Clear the jump list",
        callback = function()
            require("rabbit-hole-return").clear_jumplist()
        end
    }
}

-- Default keymaps that can be overridden
M.default_keymaps = {
    list = "<leader>rl",
    open = "ro",
    clear = "<leader>rc"
}

-- Function to create commands and keymaps
function M.setup(opts)
    opts = opts or {}
    
    -- Create commands
    for _, cmd in pairs(M.commands) do
        vim.api.nvim_create_user_command(cmd.name, cmd.callback, {})
    end

    -- Set up keymaps if not disabled
    if opts.disable_keymaps ~= true then
        local keymap = vim.keymap.set
        local map_opts = { noremap = true, silent = true }

        -- Use custom keymaps if provided, otherwise use defaults
        local keymaps = opts.keymaps or M.default_keymaps

        -- Set up keymaps
        keymap('n', keymaps.list, M.commands.list.callback, map_opts)
        
        -- Special handling for the open command since it's only active in the jumplist buffer
        keymap('n', keymaps.open, function()
            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname:match("Rabbit Hole Return") then
                M.commands.open.callback()
            end
        end, map_opts)

        keymap('n', keymaps.clear, M.commands.clear.callback, map_opts)
    end

    -- Set up buffer-specific keymaps for the jumplist buffer
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "rabbit-hole-return",
        callback = function(ev)
            local buf_opts = { noremap = true, silent = true, buffer = ev.buf }
            vim.api.nvim_buf_set_keymap(ev.buf, "n", "<CR>", ":lua require('rabbit-hole-return').jump_to_selected()<CR>", buf_opts)
            vim.api.nvim_buf_set_keymap(ev.buf, "n", "q", ":close<CR>", buf_opts)
            vim.api.nvim_buf_set_keymap(ev.buf, "n", "<ESC>", ":close<CR>", buf_opts)
        end
    })
end

return M 