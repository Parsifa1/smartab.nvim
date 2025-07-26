# Smartab.nvim

simple way to jump out of brackets, parentheses, and quotes in Neovim.

## 🚀 Features
- combined *jump out of brackets* with *jump to the end of theTree-sitter node* (like [this](https://helix-editor.com/news/release-23-10-highlights/#smart-tab) in Helix)
- supports nested pairs (thanks to neotab.nvim)

## 📦 Installation

```lua
return {
    "parsifa1/smartab.nvim",
    event = "InsertEnter",
    opts = {
        skips = { "string_content" },
        mapping = "<tab>",
        backward_mapping = "<S-tab>",
        behavior = "nested",
        pairs = {
            { open = "(", close = ")" },
            { open = "[", close = "]" },
            { open = "{", close = "}" },
            { open = "<", close = ">" },
            { open = "'", close = "'" },
            { open = '"', close = '"' },
            { open = "`", close = "`" },
        },
        exclude_filetype = {},
    }
}

```

dependencies:

- luasnip (optional)

## 🙌 Credits

- [tabout.nvim](https://github.com/abecodes/tabout.nvim)
- [neotab.nvim](https://github.com/kawre/neotab.nvim)
