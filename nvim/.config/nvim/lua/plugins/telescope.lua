return {
    {
        'DrKJeff16/project.nvim',
        --tag = '0.1.8',
        dependencies = {
            'nvim-telescope/telescope.nvim',
            dependencies = {
                'nvim-lua/plenary.nvim',
            },
            config = function()
                require("config.telescope").setup()
            end
        },
    }
}
