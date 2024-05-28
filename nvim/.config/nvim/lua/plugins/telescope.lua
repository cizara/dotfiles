return  {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.6',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()

    local telescope = require('telescope')
    telescope.setup {
      pickers = {
        find_files = {
          hidden = true
        }
      }
    }

    local builtin = require("telescope.builtin")
    vim.keymap.set('n', '<C-p>', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<leader><leader>', builtin.oldfiles, {})

  end
}
