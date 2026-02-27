local M = {}

function M.setup()
    local telescope = require("telescope")

    require("project").setup({
        manual_mode = false,
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", ".prow" },
        silent_chdir = true,
        respect_buf_cwd = true,
        update_focused_file = {
            enable = true,
            update_root = true,
        },
        sync_root_with_cwd = true,
        telescope = {
            mappings = {
                i = {
                    ["<CR>"] = "change_working_directory",
                },
                n = {
                    ["<CR>"] = "change_working_directory",
                }
            }
        }
    })

    local telescopeConfig = require("telescope.config")

    -- Clone default Telescope configuration
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- Include hidden files, but exclude .git
    vim.list_extend(vimgrep_arguments, { "--hidden", "--no-ignore", "--glob", "!**/.git/*" })

    telescope.setup({
        defaults = {
            vimgrep_arguments = vimgrep_arguments,
        },
        pickers = {
            find_files = {
                find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!**/.git/*" },
            }
        },
    })

    telescope.load_extension('projects')

end

return M

