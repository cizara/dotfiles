return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    enabled = true,
    config = function()
        require("config.ui").setup_theme("catppuccin")
    end
}
