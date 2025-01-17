local metaTable = {}


-- Set some maximum sizes for components to allow smarter truncation of components if needed
metaTable.trunc_width = setmetatable({
    mode = 80,
    git_status = 90,
    filename = 140,
    line_col = 60,
}, {
    __index = function()
        return 80 -- set a default for edge cases
    end
})

metaTable.is_truncated = function (_, width)
    local current_width = vim.api.nvim_win_get_width(0)
    return current_width < width
end

-- Table of highlight groups to allow colouring via string concatenation with a component
metaTable.colours = {
    active = '%#StatusLine#',
    inactive = '%#StatuslineNC#',
    mode = '%#Mode#',
    mode_alt = '%#ModeAlt#',
    git = '%#Git#',
    git_alt = '%#GitAlt#',
    filetype = '%#Filetype#',
    filetype_alt = '%#FiletypeAlt#',
    line_col = '%#LineCol#',
    line_col_alt = '%#LineColAlt#'
}

-- todo: will set the colours for here now but this section probablly belongs in theme code, will investigate moving them into rosepine.lua
local set_hl = function(group, options)
    local bg = options.bg == nil and '' or 'guibg=' .. options.bg
    local fg = options.fg == nil and '' or 'guifg=' .. options.fg
    local gui = options.gui == nil and '' or 'gui=' .. options.gui

    vim.cmd(string.format('hi %s %s %s', group, bg, fg, gui))
end

local highlights = {
    {'StatusLine', { fg = '#3C3836', bg = '#EBDBB2' }},
    {'StatusLineNC', { fg = '#3C3836', bg = '#928374' }},
    {'Mode', { bg = '#928374', fg = '#1D2021', gui="bold" }},
    {'LineCol', { bg = '#928374', fg = '#1D2021', gui="bold" }},
    {'Git', { bg = '#504945', fg = '#EBDBB2' }},
    {'Filetype', { bg = '#504945', fg = '#EBDBB2' }},
    {'Filename', { bg = '#504945', fg = '#EBDBB2' }},
    {'ModeAlt', { bg = '#504945', fg = '#928374' }},
    {'GitAlt', { bg = '#3C3836', fg = '#504945' }},
    {'LineColAlt', { bg = '#504945', fg = '#928374' }},
    {'FiletypeAlt', { bg = '#3C3836', fg = '#504945' }},
}

for _, highlight in ipairs(highlights) do
    set_hl(highlight[1], highlight[2]) -- pass in the group which maps to vim via metaTable.colours then the colour options that will be set
end

-- Typing icons hurts my brain so I add to tabke to save me
metaTable.separators = {
  arrow = { '', '' },
  rounded = { '', '' },
  blank = { '', '' },
}

local active_setp = 'arrow'

-- Map vim mode codes to full words for presentation
metaTable.modes = setmetatable({
    ['n']  = {'Normal', 'N'};
    ['no'] = {'N·Pending', 'N·P'} ;
    ['v']  = {'Visual', 'V' };
    ['V']  = {'V·Line', 'V·L' };
    [''] = {'V·Block', 'V·B'};
    ['s']  = {'Select', 'S'};
    ['S']  = {'S·Line', 'S·L'};
    [''] = {'S·Block', 'S·B'};
    ['i']  = {'Insert', 'I'};
    ['ic'] = {'Insert', 'I'};
    ['R']  = {'Replace', 'R'};
    ['Rv'] = {'V·Replace', 'V·R'};
    ['c']  = {'Command', 'C'};
    ['cv'] = {'Vim·Ex ', 'V·E'};
    ['ce'] = {'Ex ', 'E'};
    ['r']  = {'Prompt ', 'P'};
    ['rm'] = {'More ', 'M'};
    ['r?'] = {'Confirm ', 'C'};
    ['!']  = {'Shell ', 'S'};
    ['t']  = {'Terminal ', 'T'};
},{

    __index = function()
        return {'Unkown', 'U'}
    end
})

metaTable.get_current_mode = function()
    local current_mode = vim.api.nvim_get_mode().mode -- match return of vim.api to my table to determine what to render
    if self:is_truncated(self.trunc_width.mode) then
        return string.format(' %s ', modes[current_mode][2]):upper() -- Render short
    end

    return string.format(' %s ', modes[current_mode[1]]):upper() -- Render full
end


