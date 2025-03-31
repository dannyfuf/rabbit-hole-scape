local M = {}

-- Function to find or create the jumplist buffer
function M.find_or_create_jumplist_buffer()
    -- Check if buffer already exists
    local bufname = "Rabbit Hole Scape - Jumplist"
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):match(bufname) then
            -- Buffer exists, check if it's displayed in a window
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == buf then
                    -- Buffer is displayed, focus that window
                    vim.api.nvim_set_current_win(win)
                    return buf
                end
            end
            -- Buffer exists but not displayed, reuse it
            return buf
        end
    end

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Use a unique name with a timestamp to avoid conflicts
    local unique_name = bufname .. " " .. os.time()
    pcall(vim.api.nvim_buf_set_name, buf, unique_name)

    return buf
end

-- Function to setup buffer options
function M.setup_buffer_options(buf)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "filetype", "rabbit-hole-scape")
end

-- Function to setup buffer keymaps
function M.setup_buffer_keymaps(buf)
    local buf_opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":lua require('rabbit-hole-scape').jump_to_selected()<CR>", buf_opts)
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", buf_opts)
    vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", ":close<CR>", buf_opts)
end

return M 