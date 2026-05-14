local M = {}

function M.setup()
    require("project").setup({
        manual_mode = false,
        lsp = { enabled = true },
        patterns = { ".git", ".prow" },
        history = { save_dir = vim.fn.stdpath("data") },
        silent_chdir = true,
        telescope = {
            mappings = {
                i = {
                    ["<CR>"] = "change_working_directory",
                },
                n = {
                    ["<CR>"] = "change_working_directory",
                },
            },
        },
    })
end

return M
