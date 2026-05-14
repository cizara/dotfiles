local M = {}

function M.setup()
    require("illuminate").configure({
        providers = { "lsp", "regex" },
        delay = 200,
        under_cursor = true,
    })
end

return M
