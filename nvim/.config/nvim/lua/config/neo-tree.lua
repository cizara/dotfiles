local M = {}

function M.setup()
    require("neo-tree").setup({
        close_if_last_window = true,
        window = {
            mappings = {
                ["t"] = "open_tabnew",
            },
        },
        filesystem = {
            follow_current_file = {
                enabled = true,
            },

            hijack_netrw_behaviour = "open_current",

            filtered_items = {
                visible = true,
                hide_dotfiles = false,
            },
        },
    })
end

return M
