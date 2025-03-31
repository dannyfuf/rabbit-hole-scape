local M = {}

-- Function to create a buffer and display the jumplist
function M.show_jumplist()
	local buffer = require("rabbit-hole-scape.core.buffer")
	local jumplist = require("rabbit-hole-scape.core.jumplist")
	local path = require("rabbit-hole-scape.utils.path")

	-- Find or create the buffer
	local buf = buffer.find_or_create_jumplist_buffer()

	-- Get jumplist
	local jumps, current_jump = jumplist.get_jumplist()

	-- Check if jumplist is empty
	if #jumps == 0 then
		vim.api.nvim_echo({ { "No jump history found", "WarningMsg" } }, false, {})
		return
	end

	-- Get current project directory
	local project_dir = vim.fn.getcwd()

	-- Format jumplist entries
	local lines = {}

	-- Track seen files to avoid duplicates while preserving order
	local seen_files = {}
	-- Clear previous unique jumps
	local unique_jumps = {}
	local unique_jump_indices = {}

	-- First pass: collect unique files in order
	for i = #jumps, 1, -1 do
		local jump = jumps[i]
		local filename = vim.fn.bufname(jump.bufnr)
		
		-- Skip [No Name] buffers and oil:// files and jumplist buffers
		if filename == "" or filename == "[No Name]" or filename:match("^oil://") or filename:match("Rabbit Hole Scape") then
			goto continue
		end

		-- Get absolute path of the file
		local abs_path = path.get_absolute_path(filename)

		-- Only include files that are within the project directory
		if path.is_in_project_dir(abs_path, project_dir) then
			-- Use full path as key to track unique files
			if not seen_files[filename] then
				seen_files[filename] = true
				-- Store filepath instead of buffer reference
				table.insert(unique_jumps, {
					filepath = filename,
					lnum = jump.lnum,
					col = jump.col
				})
				table.insert(unique_jump_indices, i)
			end
		end
		::continue::
	end

	-- Store unique jumps for use in jump_to_selected
	jumplist.set_unique_jumps(unique_jumps)

	-- Check if we found any files in the project
	if #unique_jumps == 0 then
		table.insert(lines, "No files found in current project")
	else
		-- Second pass: display unique files in order
		for i, jump in ipairs(unique_jumps) do
			local original_index = unique_jump_indices[i]
			local marker = (original_index == current_jump + 1) and ">" or " "
			local filename = jump.filepath

			-- Convert to relative path for display
			local rel_path = path.get_relative_path(filename)

			local line = string.format("%s %3d: %s", marker, i, rel_path)
			table.insert(lines, line)
		end
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

	-- Set buffer options
	buffer.setup_buffer_options(buf)

	-- Calculate the width needed for the content
	local max_width = 0
	for _, line in ipairs(lines) do
		max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
	end

	-- Get the current editor dimensions
	local editor_width = vim.o.columns
	local editor_height = vim.o.lines

	-- Calculate popup dimensions
	local popup_width = math.min(math.max(max_width + 4, 60), editor_width - 4)
	local popup_height = math.min(20, editor_height - 4)

	-- Calculate popup position (centered)
	local popup_row = math.floor((editor_height - popup_height) / 2)
	local popup_col = math.floor((editor_width - popup_width) / 2)

	-- Create popup window
	local popup_win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = popup_width,
		height = popup_height,
		row = popup_row,
		col = popup_col,
		style = "minimal",
		border = "rounded",
	})

	-- Set window options
	vim.api.nvim_win_set_option(popup_win, "cursorline", true)
	vim.api.nvim_win_set_option(popup_win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")

	-- Set up buffer-specific keymaps
	buffer.setup_buffer_keymaps(buf)
end

-- Function to jump to selected location
function M.jump_to_selected()
	require("rabbit-hole-scape.core.navigation").jump_to_selected()
end

-- Function to clear the jumplist
function M.clear_jumplist()
	require("rabbit-hole-scape.core.jumplist").clear_jumplist()
end

-- Setup function to initialize the plugin
function M.setup(opts)
	require("rabbit-hole-scape.commands").setup(opts)
end

return M
