-- Custom shortcuts on top of NvChad's defaults, which already cover most (telescope, file tree).

require "nvchad.mappings"

local map = vim.keymap.set

-- `;` enters command mode without Shift, for the many `:w` and `:q`.
map("n", ";", ":", { desc = "CMD enter command mode" })

-- `jk` leaves insert mode, closer than Esc.
map("i", "jk", "<ESC>")
