return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            require("config.telescope").setup()
        end,
    },
    {
        'DrKJeff16/project.nvim',
        config = function()
            require("config.project").setup()
        end,
    },
}
