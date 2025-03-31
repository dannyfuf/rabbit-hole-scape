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

## 🎮 Keymaps

- `<leader>rl` - Show the jump list
- `ro` - Jump to selected file (when in the jump list)
- `<leader>rc` - Clear the jump list
- `<ESC>` or `q` - Close the jump list

## 🚀 Installation

Using your favorite package manager:

```lua
-- lazy.nvim
{
    "dannyfuf/rabbit-hole-return",
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
