local M = { position_history = {} }
local utils = require "smartab.utils"
local config = require "smartab.config"

---@param lines string[]
---@param pos integer[]
---@param opts? out.opts
---@return md | nil
local function tab_out(lines, pos, opts)
    opts = vim.tbl_extend("force", {
        ignore_beginning = false,
        behavior = config.behavior,
        skip_prev = false,
    }, opts or {})

    local line = lines[pos[1]]

    if not opts.ignore_beginning then
        local before_cursor = line:sub(0, pos[2])
        if vim.trim(before_cursor) == "" then
            return
        end
    end

    -- convert from 0 to 1 based indexing
    local col = pos[2] + 1

    if not opts.skip_prev then
        local prev_pair = utils.get_pair(line:sub(col - 1, col - 1))
        if prev_pair then
            local md = utils.find_next(prev_pair, line, col, opts.behavior)
            if md then
                return md
            end
        end
    end

    local curr_pair = utils.get_pair(line:sub(col, col))
    if curr_pair then
        local prev = {
            pos = col,
            char = line:sub(col, col),
        }

        local md = {
            prev = prev,
            next = prev,
            pos = col + 1,
        }

        return md
    end
end

---smart tab
---returns false if TS not available/parent doesn't exist
---@return boolean
function M.tab()
    local node_ok, node = pcall(vim.treesitter.get_node)
    -- ignore if treesitter is not available
    if not node_ok then
        return false
    end
    while node and utils.should_skip(node:type()) do
        node = node:parent()
    end
    -- ignore if can't find parent node
    if not node then
        return false
    end
    -- ignore if luaSnip is available and can expand
    -- INFO: disabled for now, might add config later
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    if luasnip_ok and luasnip.expand_or_locally_jumpable() then
        luasnip.expand {}
        return true
    end

    ---@type md|nil
    local md = nil
    -- local tab_ok, tab = pcall(require, "neotab.tab")
    local current_pos = vim.api.nvim_win_get_cursor(0)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    md = tab_out(lines, current_pos)
    if md then
        -- if neotab.md is available, set cursor for jump out bracket
        local ok = pcall(utils.set_cursor, md.pos)
        utils.add_history(current_pos)
        return ok
    else
        -- if not neotab.md, set cursor to end of ts-node
        local row, col = node:end_()
        local ok = pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })

        -- Only save position if we actually moved
        if ok then
            utils.add_history(current_pos)
        else
            ok = pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
        end
        return ok
    end
end

---Jump back to the previous cursor position
---@return boolean
function M.s_tab()
    local prev_pos = utils.remove_history()
    local ok = pcall(vim.api.nvim_win_set_cursor, 0, prev_pos)
    return ok
end
return M
