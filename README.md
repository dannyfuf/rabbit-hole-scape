# 🐰 Rabbit Hole Return

A vibe-coded Neovim plugin that helps you navigate through your jump history. Built with ✨ vibes ✨ and a sprinkle of chaos.

## ⚠️ Vibe Warning

This plugin was vibe-coded, which means:
- It works... most of the time
- Bugs are features in disguise
- The code is as unpredictable as a rabbit in a hat
- Expect the unexpected

## 🎯 Features

- Show your jump history in a floating window
- Jump back to previously visited locations
- Clear jump history
- Most recent files at the top
- Project-scoped jumps (only shows files in your current project)
- Customizable commands and keymaps

## 🎮 Commands

- `:RabbitHoleList` - Show the jump list
- `:RabbitHoleOpen` - Jump to selected file in the jump list
- `:RabbitHoleClear` - Clear the jump list

## 🎮 Default Keymaps

- `<leader>rl` - Show the jump list
- `ro` - Jump to selected file (when in the jump list)
- `<leader>rc` - Clear the jump list
- `<ESC>` or `q` - Close the jump list

## ⚙️ Configuration

You can customize the plugin's behavior through the setup function:

```lua
require("rabbit-hole-return").setup({
    -- Disable all default keymaps
    disable_keymaps = false,

    -- Customize keymaps
    keymaps = {
        list = "<leader>j",  -- Custom keymap for showing the list
        open = "<leader>o",  -- Custom keymap for opening selected file
        clear = "<leader>c"  -- Custom keymap for clearing the list
    }
})
```

## 🚀 Installation

Using your favorite package manager:

```lua
-- lazy.nvim
{
    "dannyfuf/rabbit-hole-scape",
    config = function()
        require("rabbit-hole-return").setup()
    end,
}
```

## 🤝 Contributing

Feel free to contribute! But remember:
- This is vibe-coded, so keep the vibes high
- Bugs are welcome, they make the plugin more interesting
- If it breaks, it's probably a feature

## 📝 License

MIT License - because vibes should be free 
