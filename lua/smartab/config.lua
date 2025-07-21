local config = {} ---@class SmartTabConfig

config.default = {
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

setmetatable(config, { __index = config.default })

return config
