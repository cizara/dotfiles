-- ========================================
-- Vim Options Configuration
-- ========================================

-- Leader key (must be set before lazy.nvim)
vim.g.mapleader = " "

-- ========================================
-- Indentation
-- ========================================
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- ========================================
-- Line Numbers
-- ========================================
vim.opt.number = true          -- Print line number
vim.opt.relativenumber = false -- Relative line numbers to cursor

-- ========================================
-- Window Management
-- ========================================
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
