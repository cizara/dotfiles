return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- `main` does not support lazy-loading
        build = ":TSUpdate",
        config = function()
            require("config.treesitter").setup()
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("config.treesitter").setup_textobjects()
        end,
    }
}
