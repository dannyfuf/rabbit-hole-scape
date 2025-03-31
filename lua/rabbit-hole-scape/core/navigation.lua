local M = {}

-- Function to jump to the selected location in the jumplist
function M.jump_to_selected()
    local line = vim.fn.line(".")
    local jumplist = require("rabbit-hole-scape.core.jumplist")
    local unique_jumps = jumplist.get_unique_jumps()

    -- Calculate index in unique jumplist
    local jump_index = line

    if not unique_jumps[jump_index] then
        vim.api.nvim_echo({ { "Error: Invalid jump selection", "ErrorMsg" } }, false, {})
        return
    end

    local jump = unique_jumps[jump_index]
    local filepath = jump.filepath

    -- Close the jumplist window
    vim.cmd("close")

    -- Check if file exists
    if vim.fn.filereadable(filepath) == 0 then
        vim.api.nvim_echo({ { "Error: File does not exist: " .. filepath, "ErrorMsg" } }, false, {})
        return
    end

    -- Edit the file
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))

    -- Get the number of lines in the buffer
    local line_count = vim.api.nvim_buf_line_count(0)
    
    -- Ensure the line number is valid
    if jump.lnum > line_count then
        jump.lnum = line_count
    end

    -- Set cursor position
    vim.api.nvim_win_set_cursor(0, { jump.lnum, jump.col })

    -- Center the cursor in the window
    vim.cmd("normal! zz")

    -- Print a message to confirm the jump
    vim.api.nvim_echo({ { "Jumped to " .. filepath, "Normal" } }, false, {})
end

return M 