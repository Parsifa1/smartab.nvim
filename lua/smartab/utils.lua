local M = {}
local position_history = {}
local config = require "smartab.config"

local function find_closing(info, line, col)
    if info.open == info.close then
        return line:find(info.close, col + 1, true)
    end

    local c = 1
    for i = col + 1, #line do
        local char = line:sub(i, i)

        if info.open == char then
            c = c + 1
        elseif info.close == char then
            c = c - 1
        end

        if c == 0 then
            return i
        end
    end
end

local function valid_pair(info, line, l, r)
    if info.open == info.close and line:sub(l, r):find(info.open, 1, true) then
        return true
    end

    local c = 1
    for i = l, r do
        local char = line:sub(i, i)

        if info.open == char then
            c = c + 1
        elseif info.close == char then
            c = c - 1
        end

        if c == 0 then
            return true
        end
    end

    return false
end

---@param info pair
---@param line string
---@param col integer
---
---@return integer | nil
local function find_next_nested(info, line, col) --
    local char = line:sub(col - 1, col - 1)

    if info.open == info.close or info.close == char then
        for i = col, #line do
            char = line:sub(i, i)
            local char_info = M.get_pair(char)

            if char_info then
                return i
            end
        end
    else
        local closing_idx = find_closing(info, line, col - 1)
        local l, r = col, (closing_idx or #line)
        local first

        for i = l, r do
            char = line:sub(i, i)
            local char_info = M.get_pair(char)

            if char_info and char == char_info.open then
                first = first or i
                if valid_pair(char_info, line, i + 1, r) then
                    return i
                end
            end
        end

        return closing_idx or first
    end
end

---@param pair pair
---@param line string
---@param col integer
local function find_next_closing(pair, line, col) --
    local open_char = line:sub(col - 1, col - 1)

    local i
    if pair.open == pair.close then
        i = line:find(pair.close, col, true) --
    elseif open_char ~= pair.close then
        i = find_closing(pair, line, col) --
            or line:find(pair.close, col, true)
    end

    return i or M.find_next_nested(pair, line, col)
end

function M.is_blank_line()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
    local left_of_cursor = current_line:sub(1, col)
    return left_of_cursor:match "^%s*$" ~= nil
end

function M.not_empty_history()
    if #position_history == 0 then
        return false
    else
        return true
    end
end

---@param node_type string
function M.should_skip(node_type)
    for _, skip in ipairs(config.skips) do
        if type(skip) == "string" and skip == node_type then
            return true
        elseif type(skip) == "function" and skip(node_type) then
            return true
        end
    end
    return false
end
---Clear the position history stack
function M.clear_position_history()
    position_history = {}
end

function M.add_history(pos)
    table.insert(position_history, pos)
end

function M.remove_history()
    return table.remove(position_history)
end

---@param x? integer
---@param y? integer
function M.set_cursor(x, y) --
    if not y or not x then
        local pos = vim.api.nvim_win_get_cursor(0)
        x = x or (pos[2] + 1)
        y = y or (pos[1] + 1)
    end
    vim.api.nvim_win_set_cursor(0, { y - 1, x - 1 })
end

function M.get_pair(char)
    if not char then
        return
    end

    -- vim.notify(vim.inspect(config.pairs), vim.log.levels.DEBUG)
    local res = vim.tbl_filter(function(o)
        return o.close == char or o.open == char
    end, config.pairs)

    return not vim.tbl_isempty(res) and res[1] or nil
end


---@param pair pair
---@param line string
---@param col integer
---@param behavior behavior
---
function M.find_next(pair, line, col, behavior) --
    local i

    if behavior == "closing" then
        i = find_next_closing(pair, line, col)
    else
        i = find_next_nested(pair, line, col)
    end

    if i then
        local prev = {
            pos = col - 1,
            char = line:sub(col - 1, col - 1),
        }

        local next = {
            pos = i,
            char = line:sub(i, i),
        }

        return {
            prev = prev,
            next = next,
            pos = math.max(col + 1, i),
        }
    end
end

return M
