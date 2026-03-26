local M = {}

function M.setup()
    -- Leader key for vim-visual-multi (default is <C-n>)
    vim.g.VM_leader = "\\"

    -- Theme
    vim.g.VM_theme = "ocean"

    -- Show number of cursors/selections in statusline
    vim.g.VM_set_statusline = 2

    -- Highlight settings
    vim.g.VM_highlight_matches = "underline"
end

return M
