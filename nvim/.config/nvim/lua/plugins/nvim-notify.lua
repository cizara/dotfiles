return {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
        require("config.notify").setup()
    end,
}
