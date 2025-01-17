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
        })


        vim.cmd('colorscheme rose-pine-moon')
    end
}
