local M = {}

function M.setup()
    local config = require("nvim-treesitter.configs")
    config.setup({
        auto_install = true,
        ensure_installed = {
            "bash",
            "dockerfile",
            "go",
            "gotmpl",
            "hcl",
            "html",
            "javascript",
            "jsdoc",
            "json",
            "jsonc",
            "lua",
            "ninja",
            "python",
            "query",
            "regex",
            "toml",
            "sql",
            "vim",
            "xml",
            "yaml"
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<C-space>",
                node_incremental = "<C-space>",
                scope_incremental = false,
                node_decremental = "<bs>",
            },
        },
        textobjects = {
            move = {
                enable = true,
                goto_next_start = {
                    ["]f"] = "@function.outer",
                    ["]c"] = "@class.outer",
                    ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                    ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                },
                goto_next_end = {
                    ["]F"] = "@function.outer",
                    ["]C"] = "@class.outer",
                    ["]S"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                    ["]Z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                },
                goto_previous_start = {
                    ["[f"] = "@function.outer",
                    ["[c"] = "@class.outer",
                    ["[s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                    ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                },
                goto_previous_end = {
                    ["[F"] = "@function.outer",
                    ["[C"] = "@class.outer",
                    ["[S"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                    ["[Z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                },
            },
        },
        highlight = { enable = true },
        indent = { enable = true },
    })
end

function M.setup_textobjects_move()
    local move = require("nvim-treesitter.textobjects.move")
    local configs = require("nvim-treesitter.configs")
    for name, fn in pairs(move) do
        if name:find("goto") == 1 then
            move[name] = function(q, ...)
                if vim.wo.diff then
                    local config = configs.get_module("textobjects.move")[name]
                    for key, query in pairs(config or {}) do
                        if q == query and key:find("[%]%[][cC]") then
                            vim.cmd("normal! " .. key)
                            return
                        end
                    end
                end
                return fn(q, ...)
            end
        end
    end
end

return M
