local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' }) -- Searches ALL files from root down
vim.keymap.set('n', '<C-p>', builtin.git_files, {}) -- Searches only files that get tracks
vim.keymap.set('n', '<leader>ps', function ()
	builtin.grep_string({search = vim.fn.input("Grep > ") } );
end)
