local utils = require "smartab.utils"
local config = require "smartab.config"
local tab = require("smartab.tabs").tab
local s_tab = require("smartab.tabs").s_tab

local keymap = function(filetype, buffer)
    local mapping = config.mapping --[[@as string]]
    local backward_mapping = config.backward_mapping --[[@as string]]

    if vim.tbl_contains(config.exclude_filetype, filetype) then
        return
    end
    -- Setup forward tab mapping
    vim.keymap.set("i", mapping, function()
        if utils.is_blank_line() or not tab() then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(mapping, true, true, true), "n", false)
        end
    end, {
        buffer = buffer,
        desc = "smartab-forward",
    })

    -- Setup backward tab mapping
    if backward_mapping then
        vim.keymap.set("i", backward_mapping, function()
            if utils.not_empty_history() and not s_tab() then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(backward_mapping, true, true, true), "n", false)
            end
        end, {
            buffer = buffer,
            desc = "smartab-backward",
        })
    end
end

return keymap
