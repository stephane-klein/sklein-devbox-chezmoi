-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove some LazyVim default keymaps {{{

-- Move to window using the <ctrl> hjkl keys
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-l>")

-- Windows
vim.keymap.del("n", "<leader>-")
vim.keymap.del("n", "<leader>|")

-- better up/down
vim.keymap.del({ "n", "x" }, "j")
vim.keymap.del({ "n", "x" }, "k")

-- }}}

-- cutlass.nvim equivalent {{{
-- Delete/change operations don't yank (use "m" for cut/move instead)
vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set({ "n", "x" }, "D", '"_D', { desc = "Delete to end of line without yanking" })
vim.keymap.set({ "n", "x" }, "c", '"_c', { desc = "Change without yanking" })
vim.keymap.set({ "n", "x" }, "C", '"_C', { desc = "Change to end of line without yanking" })
vim.keymap.set({ "n", "x" }, "x", '"_x', { desc = "Delete character without yanking" })
vim.keymap.set({ "n", "x" }, "X", '"_X', { desc = "Delete character before without yanking" })

-- "m" for move/cut (delete with yank)
vim.keymap.set({ "n", "x" }, "m", "d", { desc = "Cut (move)" })
vim.keymap.set("n", "mm", "dd", { desc = "Cut line (move)" })
vim.keymap.set({ "n", "x" }, "M", "D", { desc = "Cut to end of line (move)" })

-- "d" for delete without yanking
vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set({ "n", "x" }, "D", '"_D', { desc = "Delete to end of line without yanking" })

-- "c" for change without yanking
vim.keymap.set({ "n", "x" }, "c", '"_c', { desc = "Change without yanking" })
vim.keymap.set({ "n", "x" }, "C", '"_C', { desc = "Change to end of line without yanking" })

-- Preserve marks functionality with "gm"
vim.keymap.set("n", "gm", "m", { desc = "Set mark" })

vim.keymap.set('n', '<leader><leader>D', 'gg"_dG', { desc = "Delete all lines without yanking" })

-- }}}

-- Move to windows and split windows {{{
vim.keymap.set("n", "<Leader><Up>", "<C-W><C-K>", { desc = "Move to up window" })
vim.keymap.set("n", "<Leader><Left>", "<C-W><C-H>", { desc = "Move to left window" })
vim.keymap.set("n", "<Leader><Right>", "<C-W><C-L>", { desc = "Move to right window" })
vim.keymap.set("n", "<Leader><Down>", "<C-W><C-J>", { desc = "Move to down window" })

vim.keymap.set("n", "<Leader><Leader><Up>", "<Cmd>:sp<CR><C-W><C-K>", { desc = "Split on the top" })
vim.keymap.set("n", "<Leader><Leader><Left>", "<Cmd>:vs<CR><C-W><C-H>", { desc = "Split on the left" })
vim.keymap.set("n", "<Leader><Leader><Right>", "<Cmd>:vs<CR>", { desc = "Split on the right" })
vim.keymap.set("n", "<Leader><Leader><Down>", "<Cmd>:sp<CR>", { desc = "Split on the bottom" })

vim.keymap.set("n", "<Leader><Leader>c", "<C-W><C-C>", { desc = "Close window" })
vim.keymap.set("n", "<Leader><Leader>z", function() Snacks.zen.zoom() end, { desc = "Zoom window" })
-- }}}

-- Disable macro recording (not useful for my daily workflow)
vim.keymap.set('n', 'q', '<Nop>', { desc = 'Disable macro recording' })

vim.keymap.set("n", "<leader>sj", function() require("snacks").picker.jumps() end, { desc = "Jump List" })
