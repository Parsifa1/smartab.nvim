---@alias info { pos: integer, char: string }

---@alias pair { open: string, close: string }

---@class out.opts
---@field ignore_beginning? boolean
---@field behavior? behavior

---@alias behavior
---| "nested"
---| "closing"

---@class md
---@field prev info
---@field next info
---@field pos integer

---@class trigger
---@field pairs pair[]
---@field format? string
---@field cond? string
---@field ft? string[]

---@class SmartTabConfig
---@field skips (string|fun(node_type: string):boolean)[]
---@field mapping string|boolean
---@field backward_mapping string|boolean
---@field pairs { open: string, close: string }[]
---@field behavior behavior
---@field exclude_filetype string[]
