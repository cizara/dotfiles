local M = {}

function M.setup()
    require("neo-tree").setup({
        close_if_last_window = true,
        window = {
            mappings = {
                ["t"] = "open_tabnew",
            },
        },
        event_handlers = {
            {
                event = "terminal_exit",
                handler = function(args)
                    -- Refresh both the file list AND the git status indicators
                    require("neo-tree.sources.manager").refresh("filesystem")
                    require("neo-tree.sources.manager").refresh("git_status")
                end,
            },
            {
                event = "neo_tree_buffer_enter",
                handler = function()
                    require("neo-tree.sources.manager").refresh("git_status")
                end,
            },
        },
        filesystem = {
            use_libuv_file_watcher = true,
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
