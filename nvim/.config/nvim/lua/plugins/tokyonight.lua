return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    enabled = false,
    config = function()
        require("config.ui").setup_theme("tokyonight")
    end
}
