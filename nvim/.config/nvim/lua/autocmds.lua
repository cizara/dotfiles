local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ========================================
-- General Auto-commands
-- ========================================

-- Highlight on yank
autocmd("TextYankPost", {
    group = augroup("HighlightYank", { clear = true }),
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
    end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
    group = augroup("TrimWhitespace", { clear = true }),
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        pcall(function() vim.cmd([[%s/\s\+$//e]]) end)
        vim.fn.setpos(".", save_cursor)
    end,
})

-- Disable auto-commenting new lines
autocmd("BufEnter", {
    group = augroup("NoAutoComment", { clear = true }),
    pattern = "*",
    command = "set fo-=c fo-=r fo-=o",
})

-- Restore cursor position
autocmd("BufReadPost", {
    group = augroup("RestoreCursor", { clear = true }),
    pattern = "*",
    callback = function()
        local line = vim.fn.line("'\"")
        if line > 1 and line <= vim.fn.line("$") and vim.bo.filetype ~= "commit" and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1 then
            vim.cmd('normal! g`"')
        end
    end,
})

-- Auto-create directories when saving files
autocmd("BufWritePre", {
    group = augroup("AutoCreateDir", { clear = true }),
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- ========================================
-- File Type Specific Auto-commands
-- ========================================

-- Set indentation for specific file types
autocmd("FileType", {
    group = augroup("FileTypeIndent", { clear = true }),
    pattern = { "lua", "javascript", "typescript", "json", "yaml", "html", "css" },
    command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab",
})

autocmd("FileType", {
    group = augroup("FileTypeIndentFour", { clear = true }),
    pattern = { "python", "go", "rust", "c", "cpp" },
    command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab",
})

-- Enable spell checking for text files
autocmd("FileType", {
    group = augroup("SpellCheck", { clear = true }),
    pattern = { "gitcommit", "markdown", "text", "tex" },
    command = "setlocal spell",
})

-- Set wrap for markdown and text files
autocmd("FileType", {
    group = augroup("WrapText", { clear = true }),
    pattern = { "markdown", "text", "tex" },
    command = "setlocal wrap linebreak",
})

-- ========================================
-- Window Management
-- ========================================

-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
    group = augroup("ResizePanes", { clear = true }),
    pattern = "*",
    command = "tabdo wincmd =",
})

-- Close certain filetypes with <q>
autocmd("FileType", {
    group = augroup("CloseWithQ", { clear = true }),
    pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        "man",
        "notify",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "checkhealth",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- ========================================
-- LSP Auto-commands
-- ========================================

-- Show floating diagnostic on cursor hold (moved from LSP plugin)
autocmd("CursorHold", {
    group = augroup("DiagnosticFloat", { clear = true }),
    pattern = "*",
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false })
    end,
})

-- ========================================
-- Performance & Productivity
-- ========================================

-- Large file handling
autocmd("BufReadPre", {
    group = augroup("LargeFile", { clear = true }),
    callback = function(args)
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if ok and stats and stats.size > 100000 then -- 100KB
            vim.bo[args.buf].swapfile = false
            vim.bo[args.buf].undofile = false
            vim.bo[args.buf].syntax = ""
            vim.cmd("IlluminatePauseBuf") -- Disable word highlighting
            -- Disable treesitter for large files
            vim.schedule(function()
                vim.treesitter.stop(args.buf)
            end)
        end
    end,
})

-- Auto-save on focus lost
autocmd("FocusLost", {
    group = augroup("AutoSave", { clear = true }),
    pattern = "*",
    command = "silent! wa",
})

-- Check if file changed outside of vim
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("CheckTime", { clear = true }),
    command = "checktime",
})

-- Turn off relative line numbers in insert mode
local rel_num_group = augroup("RelativeLineNumbers", { clear = true })

autocmd("InsertEnter", {
    group = rel_num_group,
    callback = function()
        if vim.opt.number:get() then
            vim.opt.relativenumber = false
        end
    end,
})

autocmd("InsertLeave", {
    group = rel_num_group,
    callback = function()
        if vim.opt.number:get() then
            vim.opt.relativenumber = true
        end
    end,
})
