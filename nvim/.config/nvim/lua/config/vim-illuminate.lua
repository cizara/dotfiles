local M = {}

function M.setup()
    require("illuminate").setup({
        providers = { "lsp", "treesitter", "regex" },
        delay = 200,
        under_cursor = true,
    })
end

return M
