return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
      },
    },
  },
  vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>', {desc = 'Show Neotree'}),
  vim.keymap.set('n', '<leader>bf', ':Neotree buffers reveal float<CR>', {desc = 'Show Neotree buffers'})
}

