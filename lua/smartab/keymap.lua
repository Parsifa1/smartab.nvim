local utils = require "smartab.utils"
local config = require "smartab.config"
local smart_tab = require("smartab.jump").smart_tab
local smart_tab_backward = require("smartab.jump").smart_tab_backward

local keymap = function(filetype, buffer)
    local mapping = config.mapping --[[@as string]]
    local backward_mapping = config.backward_mapping --[[@as string]]

    if vim.tbl_contains(config.exclude_filetype, filetype) then
        return
    end
    -- Setup forward tab mapping
    vim.keymap.set("i", mapping, function()
        if utils.is_blank_line() or not smart_tab() then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(mapping, true, true, true), "n", false)
        end
    end, {
        buffer = buffer,
        desc = "smartab-forward",
    })

    -- Setup backward tab mapping
    if backward_mapping then
        vim.keymap.set("i", backward_mapping, function()
            if utils.not_empty_history() and not smart_tab_backward() then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(backward_mapping, true, true, true), "n", false)
            end
        end, {
            buffer = buffer,
            desc = "smartab-backward",
        })
    end
end

return keymap
