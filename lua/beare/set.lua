-- configure line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

-- Set searches to highlight incrementally as I type
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Color all the things
vim.opt.termguicolors = true

-- Hold a minimum number of lines at the top or bottom of the screen
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
