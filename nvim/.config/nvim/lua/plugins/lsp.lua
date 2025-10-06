return {
    {
        "williamboman/mason.nvim",
        config = true,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = true,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("config.lsp").setup()
        end,
    },
}
