local M = {}

function M.setup_theme(theme_name)
    theme_name = theme_name or "catppuccin"

    if theme_name == "catppuccin" then
        vim.cmd.colorscheme("catppuccin-mocha")
    elseif theme_name == "tokyonight" then
        vim.cmd.colorscheme("tokyonight")
    end
end

function M.setup_statusline()
    require('lualine').setup({
        options = {
            theme = 'dracula'
        }
    })
end

function M.setup_noice()
    require("noice").setup({
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
            }
        },
        presets = {
            bottom_search = true,   -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false,     -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false  -- add a border to hover docs and signature help
        }
    })
end

return M
