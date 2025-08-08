local M = {}

-- Load configuration modules
M.lsp = require("config.lsp")
M.treesitter = require("config.treesitter")
M.ui = require("config.ui")
M.gitsigns = require("config.gitsigns")
M.which_key = require("config.which-key")
M.window_picker = require("config.window-picker")
M.neo_tree = require("config.neo-tree")
M.telescope = require("config.telescope")
M.notify = require("config.notify")

-- Main setup function
function M.setup()
    -- This is just for organization - actual setup is called from individual plugin files
    -- No additional setup needed here since plugins call their respective config modules directly
end

return M
