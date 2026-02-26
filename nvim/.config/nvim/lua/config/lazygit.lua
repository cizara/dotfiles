local M = {}

function M.setup()
    -- transparency of floating window
    vim.g.lazygit_floating_window_winblend = 0
    -- scaling factor for floating window
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    -- customize lazygit popup window border characters
    vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
    -- use plenary.nvim to manage floating window if available
    vim.g.lazygit_floating_window_use_plenary = 0
    -- do not auto-install lazygit
    vim.g.lazygit_use_custom_config_file_path = 0 
    vim.g.lazygit_config_file_path = '' 
end

return M
