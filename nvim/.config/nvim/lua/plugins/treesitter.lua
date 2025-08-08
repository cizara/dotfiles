return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("config.treesitter").setup()
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "VeryLazy",
        enabled = true,
        config = function()
            require("config.treesitter").setup_textobjects_move()
        end,
    }
}
