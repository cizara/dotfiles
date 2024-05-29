return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = function(_, opts)
      local lazyvim_ok, LazyVim = pcall(require, "lazyvim")
      if lazyvim_ok and not LazyVim.has("noice.nvim") then
        opts.defaults["<leader>sn"] = { name = "+noice" }
      end
    end,
    config = function()
      local wk = require("which-key")
      wk.register(mappings, opts)
      vim.keymap.set('n', '<leader>w', ':WhichKey<CR>')
    end
  }
}
