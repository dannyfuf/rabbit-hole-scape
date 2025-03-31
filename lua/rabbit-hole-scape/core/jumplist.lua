local M = {}

-- Store the unique jumps for use in jump_to_selected
local unique_jumps = {}

-- Function to get the jumplist
function M.get_jumplist()
    local jumplist = vim.fn.getjumplist()
    return jumplist[1], jumplist[2] -- Returns the list and current position
end

-- Function to clear the jumplist
function M.clear_jumplist()
    vim.fn.clearmatches()
    vim.api.nvim_echo({ { "Jumplist cleared", "Normal" } }, false, {})
end

-- Function to get unique jumps
function M.get_unique_jumps()
    return unique_jumps
end

-- Function to set unique jumps
function M.set_unique_jumps(jumps)
    unique_jumps = jumps
end

return M 