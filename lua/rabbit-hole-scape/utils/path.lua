local M = {}

-- Function to check if a path is within a project directory
function M.is_in_project_dir(path, project_dir)
    return vim.fn.fnamemodify(path, ':h'):match(project_dir)
end

-- Function to get relative path from absolute path
function M.get_relative_path(path)
    return vim.fn.fnamemodify(path, ':~:.')
end

-- Function to get absolute path from filename
function M.get_absolute_path(filename)
    return vim.fn.fnamemodify(filename, ':p')
end

return M 