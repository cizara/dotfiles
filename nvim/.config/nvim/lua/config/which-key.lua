local M = {}

function M.setup()
    require("which-key").setup({
        preset = "modern"
    })

    -- Set up timeout options
    vim.o.timeout = true
    vim.o.timeoutlen = 300
end

return M
