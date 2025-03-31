-- Plugin initialization file for Rabbit Hole Return

-- Check if Neovim version is compatible
if vim.fn.has("nvim-0.7.0") == 0 then
	vim.api.nvim_err_writeln("Rabbit Hole Return requires at least Neovim 0.7.0")
	return
end

-- Prevent loading the plugin multiple times
if vim.g.loaded_rabbit_hole_return == 1 then
	return
end
vim.g.loaded_rabbit_hole_return = 1

-- Setup the plugin
local rabbit_hole = require("rabbit-hole-return")
rabbit_hole.setup()

-- Create a global function for easier debugging
_G.RabbitHoleJump = function()
	rabbit_hole.jump_to_selected()
end
