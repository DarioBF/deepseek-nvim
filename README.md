# DeepSeek Coder Plugin for Neovim

This plugin integrates DeepSeek Coder with Neovim, providing code suggestions similar to GitHub Copilot.

## Installation

Using `packer.nvim`:

```lua
use({
    "tu_usuario/deepseek-nvim",
    config = function()
        require('deepseek').setup({
            api_key = "tu_api_key_aqui",
        })
    end,
})
