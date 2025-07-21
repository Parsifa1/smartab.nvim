local M = {}
local utils = require "smartab.utils"
local keymap = require "smartab.keymap"
local config = require "smartab.config"

---setup smartab plugin
---@param opts? SmartTabConfig
function M.setup(opts)
    setmetatable(config, {
        __index = vim.tbl_extend("force", config.default, opts or {}),
    })
    if config.mapping then
        -- Setup FileType autocmd for keymap
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(event)
                keymap(event.match, event.buf)
            end,
        })

        -- Clear position history when leaving insert mode
        vim.api.nvim_create_autocmd("BufLeave", {
            callback = function()
                utils.clear_position_history()
            end,
        })

        -- vim.notify("SmartTab: setup with config: " .. vim.inspect(config))
        -- load `setup_keymap` manually to work with lazy-loading
        local buffer = vim.api.nvim_get_current_buf()
        keymap(vim.bo.filetype, buffer)
    end
end

return M
