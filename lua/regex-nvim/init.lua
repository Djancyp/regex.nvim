local M = {}
local api = vim.api
require('regex-nvim.split')
local popup = require("plenary.popup")
local opts = {
    paths = {
        Empty = ""
    }
}
local augroup = vim.api.nvim_create_augroup("Regex-nvim", {})
M.main_win = nil
M.main_buf = nil
M.regex = nil
M.backup_win = nil
M.current_cursor = nil
M.List = {}
M.list_buffer = nil

M.list_name = nil
M.toggle = false
M.setup = function(config)
    if config and config.paths then
        opts.paths = vim.tbl_deep_extend("force", opts.paths, config.paths or {})
    end

    api.nvim_create_user_command("RegexHelper", function()
        M.Togggle()
    end, {})
end
function M.Togggle()
    if M.toggle == false then
        M.toggle = true
    else
        M.toggle = false
    end
    M.Run()
end

M.Run = function()
    if M.toggle == true then
        M.current_win = api.nvim_get_current_win()
        M.current_buf = api.nvim_get_current_buf()
        M.current_line = api.nvim_get_current_line()
        if M.list_buffer == nil then
            local regex, err = M.validateRegex()
            if err then
                return
            end

            M.regex = regex
            M.Example_list = Get_paths()
            List_Selector(M.Example_list)
        else
            local regex, err = M.validateRegex()
            if err then
                regex = '//'
            end
            M.regex = regex
            M.highlight()
        end
    else
        M.Reset()
    end

end
function M.RunSameRegex()

end

function M.validateRegex()
    local err = false
    local regex = M.current_line
    local valid_regex = regex:match("/(.*)/")
    if not valid_regex or valid_regex == "" then
        err = true
        return regex, err
    end
    regex = "'" .. valid_regex .. "'"
    return regex, err
end

function List_Selector(lists)
    M.main_buf = api.nvim_create_buf(false, true)
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local win_id, _ = popup.create(M.main_buf, {
        title = "Regex - Select from the list",
        highlight = "Regex",
        line = math.floor(((vim.o.lines - 5) / 2) - 1),
        col = math.floor((vim.o.columns - 50) / 2),
        minwidth = 50,
        minheight = 5,
        borderchars = borderchars,
    })
    M.main_win = win_id
    api.nvim_buf_set_lines(M.main_buf, 0, #(lists), false, lists)
    Set_Keys(M.main_win, M.main_buf)
end

Set_Keys = function(win, buf)
    api.nvim_buf_set_keymap(buf, 'n', '<CR>',
        string.format([[:<C-U>lua require'regex-nvim'.Open()<CR>]], win, buf),
        { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua require"regex-nvim".Close()<CR>',
        { nowait = true, noremap = true, silent = true })
end
Get_paths = function()
    local list = {}
    for k, _ in pairs(opts.paths) do
        table.insert(list, k)
    end
    return list
end
M.Open = function()
    local text = api.nvim_get_current_line()
    local path = ""
    if text ~= "Empty" then
        path = opts.paths[text]
    end
    local buf = api.nvim_create_buf(false, false)
    M.list_buffer = buf
    vim.cmd "vsplit"
    vim.cmd(string.format("buffer %d", buf))
    if text ~= "Empty" then
        local cmd = string.format("cat %s", path)
        local full_list = vim.fn.system(cmd)
        M.table_list = full_list:split("\n")
    else
        M.table_list = {
            "Example list:",
            "email@email.com",
            "27-03-1989",
            "Hello World"
        }
        api.nvim_buf_set_lines(buf, 0, #(M.table_list), false, M.table_list)
    end
    api.nvim_buf_set_lines(buf, 0, #(M.table_list), false, M.table_list)


    api.nvim_buf_set_option(buf, "buftype", "nofile")
    api.nvim_buf_set_option(buf, "swapfile", false)
    api.nvim_buf_set_option(buf, "buflisted", false)
    api.nvim_buf_set_option(buf, "filetype", "regexnvim")
    api.nvim_buf_set_var(buf, "regexnvim", 0)
    api.nvim_win_set_option(0, "spell", false)
    api.nvim_win_set_option(0, "number", false)
    api.nvim_win_set_option(0, "relativenumber", false)
    api.nvim_win_set_option(0, "cursorline", false)
    api.nvim_set_current_win(M.current_win)
    vim.api.nvim_clear_autocmds { group = augroup, buffer = M.current_buf }
    vim.api.nvim_clear_autocmds { group = augroup, buffer = M.list_buffer }

    vim.api.nvim_create_autocmd("BufWinLeave", {
        group = augroup,
        buffer = M.list_buffer,
        callback = function()
            M.Reset()
        end,
        desc = "Regex: highlight node",
    })
    vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
        group = augroup,
        buffer = M.list_buffer,
        callback = function()
            local lines = api.nvim_buf_get_lines(M.list_buffer, 0, -1, false)
            M.table_list = lines
            M.highlight()

        end,
        desc = "Regex: highlight node",
    })

    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        group = augroup,
        buffer = M.current_buf,
        callback = function()
            local new_line = api.nvim_get_current_line()
            if M.current_line ~= new_line then
                M.Run()
            end
        end,
        desc = "Regex: highlight node",
    })
    vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
        group = augroup,
        buffer = M.current_buf,
        callback = function()
            M.Run()
        end,
        desc = "Regex: highlight node",
    })

    M.highlight()
    M.Close()
end

function M.highlight()
    if M.list_buffer ~= nil then
        api.nvim_buf_clear_namespace(M.list_buffer, 0, 0, -1)
    end
    vim.api.nvim_set_hl(0, "reg_hg", {
        fg = "black",
        bg = "green",
        bold = true,
    })
    for k, v in pairs(M.table_list) do

        if v ~= "" then
            local regex_cmd = string.format("echo '%s' | command rg --pcre2 %s", v, M.regex)
            vim.fn.jobstart(regex_cmd, {
                on_stdout = function(_, data)
                    for i, line in ipairs(data) do
                        if line ~= "" then
                            print(line)
                            api.nvim_buf_add_highlight(M.list_buffer, 0, "reg_hg", k - 1, 0, -1)
                        end
                    end
                end,
            })
        end
    end
end

function M.Reset()
    vim.api.nvim_clear_autocmds { group = augroup, buffer = M.current_buf }
    vim.api.nvim_clear_autocmds { group = augroup, buffer = M.list_buffer }
    if M.list_buffer then
        api.nvim_buf_delete(M.list_buffer, {})
    end
    M.toggle = false
    M.current_win = nil
    M.current_buf = nil
    M.current_line = nil
    M.main_buf = nil
    M.main_win = nil
    M.list_buffer = nil
    M.regex = nil

end

M.Close = function()
    if M.main_win then
        api.nvim_win_close(M.main_win, false)
        api.nvim_buf_delete(M.main_buf, {})
    end
    M.main_win = nil
    M.main_buf = nil

end

return M
