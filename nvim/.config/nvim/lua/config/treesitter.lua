local M = {}

-- Parsers to install. The `main` branch has no auto_install, so the list is
-- explicit. `jsonc` has no parser of its own (the plugin maps it to `json`).
local languages = {
    "bash",
    "comment",
    "css",
    "csv",
    "diff",
    "dockerfile",
    "editorconfig",
    "gitcommit",
    "git_config",
    "gitignore",
    "go",
    "gomod",
    "gosum",
    "gotmpl",
    "helm",
    "hcl",
    "html",
    "hyprlang",
    "ini",
    "javascript",
    "jsdoc",
    "json",
    "kdl",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "nginx",
    "ninja",
    "php",
    "python",
    "qmljs",
    "query",
    "regex",
    "requirements",
    "terraform",
    "toml",
    "sql",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
}

function M.setup()
    require("nvim-treesitter").install(languages)

    -- Every filetype these parsers are registered for, e.g. sh/bash -> bash,
    -- dosini -> ini, help -> vimdoc, gotmplyaml -> yaml (see autocmds.lua).
    local filetypes = {}
    for _, lang in ipairs(languages) do
        vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
    end

    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function()
            -- syntax highlighting, provided by Neovim
            vim.treesitter.start()
            -- indentation, provided by nvim-treesitter
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end

function M.setup_textobjects()
    require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
    })

    local move = require("nvim-treesitter-textobjects.move")
    local maps = {
        goto_next_start = { ["]f"] = { "@function.outer", "textobjects" }, ["]]"] = { "@class.outer", "textobjects" }, ["]s"] = { "@local.scope", "locals" }, ["]z"] = { "@fold", "folds" } },
        goto_next_end = { ["]F"] = { "@function.outer", "textobjects" }, ["]["] = { "@class.outer", "textobjects" }, ["]S"] = { "@local.scope", "locals" }, ["]Z"] = { "@fold", "folds" } },
        goto_previous_start = { ["[f"] = { "@function.outer", "textobjects" }, ["[["] = { "@class.outer", "textobjects" }, ["[s"] = { "@local.scope", "locals" }, ["[z"] = { "@fold", "folds" } },
        goto_previous_end = { ["[F"] = { "@function.outer", "textobjects" }, ["[]"] = { "@class.outer", "textobjects" }, ["[S"] = { "@local.scope", "locals" }, ["[Z"] = { "@fold", "folds" } },
    }

    for fn, keys in pairs(maps) do
        for lhs, spec in pairs(keys) do
            local query, group = spec[1], spec[2]
            vim.keymap.set({ "n", "x", "o" }, lhs, function()
                move[fn](query, group)
            end, { desc = fn:gsub("goto_", "Go to "):gsub("_", " ") .. " " .. query })
        end
    end
end

return M
