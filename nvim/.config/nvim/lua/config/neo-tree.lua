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
                    -- Refresh neo-tree when a terminal closes (often after git commit)
                    require("neo-tree.sources.manager").refresh("filesystem")
                end,
            },
            {
                event = "buf_write_post",
                handler = function(args)
                    -- Refresh when saving a file
                    require("neo-tree.sources.manager").refresh("filesystem")
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
