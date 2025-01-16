return {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
        require("rose-pine").setup({
            extend_background_behind_borders = true,
            enable = {
                terminal = true,
            },
            styles = {
                transparency = true,
            },
            highlight_groups = {
                StatusLine = { fg = "Love", bg = "Rose", blend = 5 },
                StatusLineNC = { fg = "subtle", bg = "surface" },
            },
        })
        vim.opt.laststatus = 3
        -- %f file in buffer with path
        -- %m is the file modified? [-] [+]
        -- %= justify to the right from here
        -- %l line number
        -- %c column number
        vim.opt.statusline = " %{fugitive#statusline()} > %.50f %m - FileType: %y %= %{mode()} [%l↓ %c→] 🐻 "
        vim.cmd('colorscheme rose-pine-moon')
    end
}
