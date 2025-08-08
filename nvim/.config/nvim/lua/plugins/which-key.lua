return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        require("config.which-key").setup()
    end,
}
