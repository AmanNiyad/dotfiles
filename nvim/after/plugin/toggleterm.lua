local toggleterm = require("toggleterm")toggleterm.setup {

    size = 50,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "vertical",
    close_on_exit = false,
    shell = vim.o.shell,
}

local keymap = vim.keymap.set
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
