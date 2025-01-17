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

local active_sep = 'arrow'

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
-- Mode Component
metaTable.get_current_mode = function(self)
    local current_mode = vim.api.nvim_get_mode().mode -- match return of vim.api to my table to determine what to render
    if self:is_truncated(self.trunc_width.mode) then
        return string.format(' %s ', self.modes[current_mode][2]):upper() -- Render short
    end

    return string.format(' %s ', self.modes[current_mode[1]]):upper() -- Render full
end

-- Git Component
metaTable.get_git_status = function(self)
    -- Hook into gitsigns plugin to do the more then my brain can take tasks of parsing git information for display
    local signs = vim.b.gitsigns_status_dict or {head = '', added = 0, changed = 0, removed = 0}
    local is_head_empty = signs.head ~= ''

    if self:is_truncated(self.trunc_width.git_status) then
        return is_head_empty and string.format('  %s ', signs.head or '') or '' 
    end

    return is_head_empty and string.format(' +%s ~%s -%s |  %s ', signs.added, signs.changed, signs.removed, signs.head) or ''
end

-- File Component
 metaTable.get_filename = function(self)
  if self:is_truncated(self.trunc_width.filename) then return " %<%f " end
  return " %<%F "
end

-- Filetype Component
metaTable.get_filetype = function()
  local file_name, file_ext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon = require'nvim-web-devicons'.get_icon(file_name, file_ext, { default = true })
  local filetype = vim.bo.filetype

  if filetype == '' then return '' end
  return string.format(' %s %s ', icon, filetype):lower()
end

-- Linecount Component
metaTable.get_line_col = function(self)
    if self:is_truncated(self.trunc_width.line_col) then return ' %l:%c ' end
    return ' Ln %l, Col %c '
end

-- LSP info component
metaTable.get_lsp_diagnostic = function(self)
    local result = {}
    local levels = {
        errors = 'Error',
        warnings = 'Warning',
        info = 'Information',
        hints = 'Hint'
    }

  for k, level in pairs(levels) do
    result[k] = vim.lsp.diagnostic.get_count(0, level)
  end

  if self:is_truncated(self.trunc_width.diagnostic) then
    return ''
  else
    return string.format(
      "| :%s :%s :%s :%s ",
      result['errors'] or 0, result['warnings'] or 0,
      result['info'] or 0, result['hints'] or 0
    )
  end
end

-- Time to do the magic combining everything into the strings to be consumed
metaTable.set_active = function(self)
  local colours = self.colours

  -- Merge the colour and format styles together
  local mode = colours.mode .. self:get_current_mode()
  local mode_alt = colours.mode_alt .. self.separators[active_sep][1]
  local git = colours.git .. self:get_git_status()
  local git_alt = colours.git_alt .. self.separators[active_sep][1]
  local filename = colours.inactive .. self:get_filename()
  local filetype_alt = colours.filetype_alt .. self.separators[active_sep][2]
  local filetype = colours.filetype .. self:get_filetype()
  local line_col = colours.line_col .. self:get_line_col()
  local line_col_alt = colours.line_col_alt .. self.separators[active_sep][2]

  -- organise the components into the order I would like to see then %= is flipping justifications
  -- This will create left justified %= center %= right
  return table.concat({
      colours.active, mode, mode_alt, git, git_alt,
      "%=", filename, "%=",
      filetype_alt, filetype, line_col_alt, line_col
  })
end

metaTable.set_inactive = function(self)
    return self.colours.inactive .. '%= %F $='
end

-- Now everything is configured and formatted pass to vim
Statusline = setmetatable(metaTable, {
    __call = function(statusline, mode)
        if mode == "active" then return statusline:set_active() end
        if mode == "inactive" then return statusline:set_inactive() end
    end
})

-- When we enter a buffer call metaTable for mode active and generate the format
-- when a buffer is left do the same for inactive since most information goes away we would like to reflect that
vim.api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
  augroup END
]], false)
