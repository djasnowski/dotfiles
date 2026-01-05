-- Matrix theme configuration for AstroNvim
-- Colors sampled from polybar + user's preferred palette
local C = {
  bg       = "#0A5F00",  -- dark forest green (statusline bg)
  bg_dark  = "#001900",  -- darker bg for editor
  fg       = "#00FF41",  -- neon terminal green (text)
  fg_bright = "#1AFF00", -- brighter green (indicator)
  fg_dim   = "#1eba1e",  -- muted green
  cyan     = "#00d9d9",
  yellow   = "#b5e61d",
  red      = "#ff3333",
  magenta  = "#00ff9f",
}

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "matrix",
    status = {
      colors = {
        -- Base colors
        fg = C.fg,
        bg = C.bg,
        section_fg = C.fg,
        section_bg = C.bg,

        -- Mode colors
        normal = C.fg,
        insert = C.cyan,
        visual = C.fg_dim,
        replace = C.red,
        command = C.yellow,
        terminal = C.magenta,
        inactive = C.fg_dim,

        -- Git
        git_branch_fg = C.fg,
        git_added = C.fg_bright,
        git_changed = C.yellow,
        git_removed = C.red,

        -- Diagnostics
        diag_ERROR = C.red,
        diag_WARN = C.yellow,
        diag_INFO = C.cyan,
        diag_HINT = C.fg_dim,

        -- Scrollbar
        scrollbar = C.fg_bright,

        -- Treesitter
        treesitter_fg = C.fg,

        -- Winbar
        winbar_fg = C.fg_dim,
        winbar_bg = C.bg_dark,
        winbarnc_fg = C.fg_dim,
        winbarnc_bg = C.bg_dark,

        -- Tabline/bufferline
        tabline_bg = C.bg_dark,
        tabline_fg = C.fg_dim,
        buffer_fg = C.fg_dim,
        buffer_path_fg = C.fg_dim,
        buffer_close_fg = C.fg_dim,
        buffer_bg = C.bg_dark,
        buffer_active_fg = C.fg,
        buffer_active_path_fg = C.fg_dim,
        buffer_active_close_fg = C.red,
        buffer_active_bg = C.bg,
        buffer_visible_fg = C.fg,
        buffer_visible_path_fg = C.fg_dim,
        buffer_visible_close_fg = C.red,
        buffer_visible_bg = C.bg,
        buffer_overflow_fg = C.fg_dim,
        buffer_overflow_bg = C.bg_dark,
        buffer_picker_fg = C.red,
        tab_close_fg = C.red,
        tab_close_bg = C.bg_dark,
        tab_fg = C.fg_dim,
        tab_bg = C.bg_dark,
        tab_active_fg = C.bg_dark,
        tab_active_bg = C.fg,

        -- Nav
        nav_icon_bg = C.fg,
        nav_fg = C.fg,
      },
      attributes = {
        buffer_active = { bold = true, italic = true },
        buffer_picker = { bold = true },
        macro_recording = { bold = true },
        git_branch = { bold = true },
        git_diff = { bold = true },
        mode = { bold = true },
      },
    },
    highlights = {
      init = {
        -- Mode highlight groups used by heirline
        HeirlineNormal = { fg = C.bg_dark, bg = C.fg, bold = true },
        HeirlineInsert = { fg = C.bg_dark, bg = C.cyan, bold = true },
        HeirlineVisual = { fg = C.bg_dark, bg = C.fg_dim, bold = true },
        HeirlineReplace = { fg = C.bg_dark, bg = C.red, bold = true },
        HeirlineCommand = { fg = C.bg_dark, bg = C.yellow, bold = true },
        HeirlineTerminal = { fg = C.bg_dark, bg = C.magenta, bold = true },
        HeirlineInactive = { fg = C.fg_dim, bg = C.bg },
      },
    },
  },
}
