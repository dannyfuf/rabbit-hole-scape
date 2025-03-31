local M = {}

-- Store the unique jumps for use in jump_to_selected
local unique_jumps = {}

-- Function to get the jumplist
local function get_jumplist()
	local jumplist = vim.fn.getjumplist()
	return jumplist[1], jumplist[2] -- Returns the list and current position
end

-- Function to find or create the jumplist buffer
local function find_or_create_jumplist_buffer()
	-- Check if buffer already exists
	local bufname = "Rabbit Hole Return - Jumplist"
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

-- Function to jump to the selected location in the jumplist
function M.jump_to_selected()
	local line = vim.fn.line(".")

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

-- Function to create a buffer and display the jumplist
function M.show_jumplist()
	-- Find or create the buffer
	local buf = find_or_create_jumplist_buffer()

	-- Get jumplist
	local jumps, current_jump = get_jumplist()

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
	unique_jumps = {}
	local unique_jump_indices = {}

	-- First pass: collect unique files in order
	for i = #jumps, 1, -1 do
		local jump = jumps[i]
		local filename = vim.fn.bufname(jump.bufnr)
		
		-- Skip [No Name] buffers and oil:// files and jumplist buffers
		if filename == "" or filename == "[No Name]" or filename:match("^oil://") or filename:match("Rabbit Hole Return") then
			goto continue
		end

		-- Get absolute path of the file
		local abs_path = vim.fn.fnamemodify(filename, ':p')

		-- Only include files that are within the project directory
		if vim.fn.fnamemodify(abs_path, ':h'):match(project_dir) then
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
			local rel_path = vim.fn.fnamemodify(filename, ':~:.')

			local line = string.format("%s %3d: %s", marker, i, rel_path)
			table.insert(lines, line)
		end
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

	-- Set buffer options
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "filetype", "rabbit-hole-return")

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
	local buf_opts = { noremap = true, silent = true }
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":lua require('rabbit-hole-return').jump_to_selected()<CR>", buf_opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", buf_opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", ":close<CR>", buf_opts)
end

-- Function to clear the jumplist
function M.clear_jumplist()
	vim.fn.clearmatches()
	vim.api.nvim_echo({ { "Jumplist cleared", "Normal" } }, false, {})
end

-- Setup function to initialize the plugin
function M.setup(opts)
	require("rabbit-hole-return.commands").setup(opts)
end

return M
