local M = {}

function M.setup()
    -- Diagnostic signs
    local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Diagnostic display config
    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })

    vim.o.signcolumn = "yes"

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(args)
            require("keymaps").setup_lsp_keymaps(args.buf)
        end,
    })

    vim.lsp.config("gopls", {})
    vim.lsp.enable("gopls")
end

return M

