local M = {}

function M.setup()
    require("project").setup({
        manual_mode = false,
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", ".prow" },
        datapath = vim.fn.stdpath("data"),
        silent_chdir = true,
        respect_buf_cwd = true,
        sync_root_with_cwd = false,
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
