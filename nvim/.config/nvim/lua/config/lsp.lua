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

    local on_attach = function(_, bufnr)
        require("keymaps").setup_lsp_keymaps(bufnr)
    end

    -- New API (replaces require("lspconfig"))
    vim.lsp.config["gopls"] = {
        on_attach = on_attach,
    }

    -- Start the server
    vim.lsp.start(vim.lsp.config["gopls"])
end

return M

