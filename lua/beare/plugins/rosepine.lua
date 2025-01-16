return {
	'rose-pine/neovim',
	name = 'rose-pine',
	config = function()
		require("rose-pine").setup({
			styles = {
				transparency = true,
			},
			highlight_groups = {
				StatusLine = { fg = "love", bg = "love", blend = 10},
				StatusLineNC = {fg = "subtle", bg = "surface"},
			},
		})
		vim.opt.laststatus = 3
		vim.opt.statusline = " %f %m %= %l:%c ♥ "
		vim.cmd('colorscheme rose-pine-moon')
	end
}
