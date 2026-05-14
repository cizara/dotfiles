local M = {}

function M.setup()
    local telescope = require("telescope")

    local telescopeConfig = require("telescope.config")

    -- Clone default Telescope configuration
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- Include hidden files, but exclude .git
    vim.list_extend(vimgrep_arguments, { "--hidden", "--no-ignore", "--glob", "!**/.git/*" })

    telescope.setup({
        defaults = {
            vimgrep_arguments = vimgrep_arguments,
            preview = {
                treesitter = false,
            },
        },
        pickers = {
            find_files = {
                find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!**/.git/*", "--glob", "!**/.venv/*", "--glob", "!**/node_modules/*" },
            }
        },
    })

    telescope.load_extension('projects')

end

return M

