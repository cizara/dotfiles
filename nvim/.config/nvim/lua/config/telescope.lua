local M = {}

function M.setup()
    local telescope = require("telescope")
    local telescopeConfig = require("telescope.config")

    -- Clone default Telescope configuration
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- Include hidden files, but exclude .git
    vim.list_extend(vimgrep_arguments, { "--hidden", "--glob", "!**/.git/*" })

    telescope.setup({
        defaults = {
            vimgrep_arguments = vimgrep_arguments,
        },
        pickers = {
            find_files = {
                find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!**/.git/*" },
            }
        }
    })
end

return M

