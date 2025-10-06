local M = {}

function M.setup()
    local lspconfig = require("lspconfig")

    -- Define diagnostic signs (original)
    local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Diagnostic display configuration (original)
    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })

    -- Ensure signcolumn is visible (original)
    vim.o.signcolumn = "yes"

    local on_attach = function(_, bufnr)
        require("keymaps").setup_lsp_keymaps(bufnr)
    end

    -- Original server setup
    lspconfig.gopls.setup({
        on_attach = on_attach,
    })
end

return M
