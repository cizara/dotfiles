local M = {}

-- ========================================
-- Global Keymaps
-- ========================================

local function setup_global_keymaps()
    -- ========================================
    -- Essential Editor Keymaps
    -- ========================================

    -- Better window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
    vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
    vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
    vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

    -- Resize windows
    vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', { desc = 'Increase window height' })
    vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', { desc = 'Decrease window height' })
    vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Decrease window width' })
    vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })

    -- Better buffer navigation
    vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer' })
    vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer' })
    vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })
    vim.keymap.set('n', '<leader>bD', ':bdelete!<CR>', { desc = 'Force delete buffer' })

    vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
    vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

    vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
    vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
    vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
    vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

    -- Better search
    vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result centered' })
    vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result centered' })
    vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { desc = 'Clear search highlights' })

    -- Better paste
    vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste without yanking' })

    -- System clipboard
    vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
    vim.keymap.set('n', '<leader>y', '"+yy', { desc = 'Yank line to system clipboard' })
    vim.keymap.set('n', '<leader>Y', '"+Y', { desc = 'Yank line to system clipboard' })
    vim.keymap.set({ 'n', 'v' }, '<leader>x', '"_d', { desc = 'Delete without yanking' })

    -- Replace word under cursor
    vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
        { desc = 'Replace word under cursor' })

    -- Split management
    vim.keymap.set('n', '<leader>-', ':split<CR>', { desc = 'Horizontal split' })
    vim.keymap.set('n', '<leader>|', ':vsplit<CR>', { desc = 'Vertical split' })

    -- Neo-tree keymaps
    vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>', { desc = 'Show Neotree' })
    vim.keymap.set('n', '<leader>bf', ':Neotree buffers reveal float<CR>', { desc = 'Show Neotree buffers' })

    -- ========================================
    -- Telescope keymaps
    -- ========================================
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
        -- File operations
        vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Find files' })
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find word under cursor' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
        vim.keymap.set('n', '<leader><leader>', builtin.oldfiles, { desc = 'Show last open files' })

        -- LSP/Symbols
        vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "Document Symbols" })
        vim.keymap.set("n", "<leader>so", function()
            builtin.lsp_document_symbols({
                symbols = { "Function", "Method" },
            })
        end, { desc = "Outline: Functions & Methods" })

        -- Git integration
        vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
        vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
        vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })

        -- Vim specific
        vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Find commands' })
        vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find keymaps' })
        vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Resume last search' })
    end

    -- ========================================
    -- Utility keymaps
    -- ========================================

    -- Notify keymaps
    vim.keymap.set("n", "<leader>un", function()
        require("notify").dismiss({
            silent = true,
            pending = true
        })
    end, { desc = "Dismiss All Notifications" })

    -- Which-key keymaps
    vim.keymap.set("n", "<leader>?", function()
        require("which-key").show({
            global = false
        })
    end, { desc = "Buffer Local Keymaps (which-key)" })

    vim.keymap.set("n", "<leader>wh", function()
        require("which-key").show({
            global = true
        })
    end, { desc = "Global Keymaps (which-key)" })

    -- ========================================
    -- Quick actions
    -- ========================================

    vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
    vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
    vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { desc = 'Quit all without saving' })

    vim.keymap.set('n', '<leader><C-s>', ':source %<CR>', { desc = 'Source current file' })

    -- Toggle options
    vim.keymap.set('n', '<leader>tw', ':set wrap!<CR>', { desc = 'Toggle word wrap' })
    vim.keymap.set('n', '<leader>tn', ':set number!<CR>', { desc = 'Toggle line numbers' })
    vim.keymap.set('n', '<leader>tr', ':set relativenumber!<CR>', { desc = 'Toggle relative numbers' })
    vim.keymap.set('n', '<leader>ts', ':set spell!<CR>', { desc = 'Toggle spell check' })

    -- Diagnostic keymaps (moved to avoid 'd' conflict)
    vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })
    vim.keymap.set('n', '<leader>dw', vim.diagnostic.setqflist, { desc = 'Open workspace diagnostics' })
end

-- ========================================
-- LSP Keymaps (set up per buffer)
-- ========================================

local function setup_lsp_keymaps(bufnr)
    local lsp_opts = function(desc)
        return { desc = desc, noremap = true, silent = true, buffer = bufnr }
    end

    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
        -- Fallback to basic LSP functions if telescope not available
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, lsp_opts("Go to declaration"))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, lsp_opts("References"))
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, lsp_opts("Definitions"))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, lsp_opts("Implementations"))
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, lsp_opts("Type Definitions"))
    else
        -- Use telescope for navigation if available
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, lsp_opts("Go to declaration"))
        vim.keymap.set("n", "gr", builtin.lsp_references, lsp_opts("References"))
        vim.keymap.set("n", "gd", builtin.lsp_definitions, lsp_opts("Definitions"))
        vim.keymap.set("n", "gi", builtin.lsp_implementations, lsp_opts("Implementations"))
        vim.keymap.set("n", "gt", builtin.lsp_type_definitions, lsp_opts("Type Definitions"))
        vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, lsp_opts("Document Symbols"))
        vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, lsp_opts("Workspace Symbols"))
    end

    -- Documentation
    vim.keymap.set("n", "K", vim.lsp.buf.hover, lsp_opts("Hover documentation"))
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, lsp_opts("Signature help"))

    -- Workspace
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, lsp_opts("Add workspace folder"))
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, lsp_opts("Remove workspace folder"))
    vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, lsp_opts("List workspace folders"))

    -- Code actions
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, lsp_opts("Rename symbol"))
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, lsp_opts("Code action"))

    -- Diagnostics
    vim.keymap.set("n", "gl", vim.diagnostic.open_float, lsp_opts("Show diagnostic"))
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, lsp_opts("Previous diagnostic"))
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, lsp_opts("Next diagnostic"))
end

-- ========================================
-- Gitsigns Keymaps (set up per buffer)
-- ========================================

local function setup_gitsigns_keymaps(bufnr)
    local gitsigns_opts = function(desc)
        return { desc = desc, noremap = true, silent = true, buffer = bufnr }
    end

    local ok, gitsigns = pcall(require, "gitsigns")
    if not ok then
        return
    end

    -- Navigation
    vim.keymap.set('n', ']c', function()
        if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
        else
            gitsigns.nav_hunk('next')
        end
    end, gitsigns_opts("Next hunk"))

    vim.keymap.set('n', '[c', function()
        if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
        else
            gitsigns.nav_hunk('prev')
        end
    end, gitsigns_opts("Previous hunk"))

    -- Actions
    vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, gitsigns_opts('GitSigns Stage Hunk'))
    vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, gitsigns_opts('GitSigns Reset Hunk'))
    vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        gitsigns_opts('GitSigns Stage Hunk'))
    vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        gitsigns_opts('GitSigns Reset Hunk'))
    vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, gitsigns_opts('GitSigns Stage Buffer'))
    vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, gitsigns_opts('GitSigns Undo Stage Hunk'))
    vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, gitsigns_opts('GitSigns Reset Buffer'))
    vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, gitsigns_opts('GitSigns Preview Hunk'))
    vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end,
        gitsigns_opts('GitSigns Blame Line'))
    vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame,
        gitsigns_opts('GitSigns Toggle Current Line Blame'))
    vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, gitsigns_opts('GitSigns Diff This Against Index'))
    vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis('~') end,
        gitsigns_opts('GitSigns Diff This Against Last Commit'))
    vim.keymap.set('n', '<leader>td', gitsigns.toggle_deleted, gitsigns_opts('GitSigns Show Deleted'))

    -- Text object
    vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', gitsigns_opts('GitSigns select hunk'))
end

-- ========================================
-- Module exports
-- ========================================

-- Function to set up LSP keymaps for a specific buffer
M.setup_lsp_keymaps = setup_lsp_keymaps

-- Function to set up Gitsigns keymaps for a specific buffer
M.setup_gitsigns_keymaps = setup_gitsigns_keymaps

-- Function to set up all global keymaps
M.setup_global_keymaps = setup_global_keymaps

return M
