local M = {}

function M.setup()
    require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
            },
        },
    })
end

return M
