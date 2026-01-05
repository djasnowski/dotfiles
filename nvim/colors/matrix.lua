-- Matrix colorscheme for Neovim
-- Inspired by polybar matrix theme

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "matrix"

-- Palette (pixel-sampled from polybar + derived)
local c = {
  -- Base colors (pixel-sampled)
  bg        = "#001900",
  bg_alt    = "#0A5F00",  -- statusline bg
  bg_btn    = "#0b260b",
  fg        = "#00FF41",  -- neon terminal green
  fg_alt    = "#1eba1e",

  -- Derived greens (varying intensity)
  green_dim     = "#0a7e0a",
  green_bright  = "#1AFF00",  -- bright indicator
  green_pale    = "#7dff7d",
  green_dark    = "#004d00",

  -- Accent colors (keeping matrix feel)
  cyan      = "#00d9d9",
  cyan_dim  = "#007a7a",
  yellow    = "#b5e61d",
  yellow_dim = "#7a9c14",
  orange    = "#e6a400",
  red       = "#ff3333",
  red_dim   = "#992020",
  magenta   = "#00ff9f",

  -- UI colors
  selection  = "#0a4f0a",
  line_nr    = "#0a7e0a",
  comment    = "#1e8a1e",
  visual     = "#0d5a0d",
  search     = "#1a6b1a",
  match      = "#33ff33",
  border     = "#0a4f0a",
  float_bg   = "#001200",

  none = "NONE",
}

-- Helper function
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor UI
hi("Normal",       { fg = c.fg, bg = c.bg })
hi("NormalFloat",  { fg = c.fg, bg = c.float_bg })
hi("FloatBorder",  { fg = c.border, bg = c.float_bg })
hi("Cursor",       { fg = c.bg, bg = c.fg })
hi("CursorLine",   { bg = c.bg_btn })
hi("CursorColumn", { bg = c.bg_btn })
hi("ColorColumn",  { bg = c.bg_btn })
hi("LineNr",       { fg = c.line_nr })
hi("CursorLineNr", { fg = c.fg, bold = true })
hi("SignColumn",   { fg = c.fg_alt, bg = c.bg })
hi("VertSplit",    { fg = c.border, bg = c.bg })
hi("WinSeparator", { fg = c.border, bg = c.bg })
hi("StatusLine",   { fg = c.fg, bg = c.bg_alt })
hi("StatusLineNC", { fg = c.fg_alt, bg = c.bg_btn })
hi("TabLine",      { fg = c.fg_alt, bg = c.bg_btn })
hi("TabLineFill",  { bg = c.bg })
hi("TabLineSel",   { fg = c.fg, bg = c.bg_alt, bold = true })
hi("Pmenu",        { fg = c.fg, bg = c.float_bg })
hi("PmenuSel",     { fg = c.green_bright, bg = c.selection })
hi("PmenuSbar",    { bg = c.bg_btn })
hi("PmenuThumb",   { bg = c.fg_alt })
hi("WildMenu",     { fg = c.bg, bg = c.fg })
hi("Folded",       { fg = c.comment, bg = c.bg_btn })
hi("FoldColumn",   { fg = c.comment, bg = c.bg })
hi("NonText",      { fg = c.green_dark })
hi("SpecialKey",   { fg = c.green_dark })
hi("Whitespace",   { fg = c.green_dark })
hi("EndOfBuffer",  { fg = c.bg })

-- Search & Visual
hi("Visual",       { bg = c.visual })
hi("VisualNOS",    { bg = c.visual })
hi("Search",       { fg = c.bg, bg = c.fg_alt })
hi("IncSearch",    { fg = c.bg, bg = c.fg, bold = true })
hi("CurSearch",    { fg = c.bg, bg = c.green_bright, bold = true })
hi("Substitute",   { fg = c.bg, bg = c.yellow })

-- Messages
hi("ErrorMsg",     { fg = c.red, bold = true })
hi("WarningMsg",   { fg = c.yellow })
hi("ModeMsg",      { fg = c.fg, bold = true })
hi("MoreMsg",      { fg = c.cyan })
hi("Question",     { fg = c.cyan })
hi("Title",        { fg = c.green_bright, bold = true })
hi("Directory",    { fg = c.cyan })

-- Diff
hi("DiffAdd",      { fg = c.green_bright, bg = c.green_dark })
hi("DiffChange",   { fg = c.yellow, bg = "#2a2a00" })
hi("DiffDelete",   { fg = c.red_dim, bg = "#2a0a0a" })
hi("DiffText",     { fg = c.yellow, bg = "#3a3a00", bold = true })
hi("Added",        { fg = c.green_bright })
hi("Changed",      { fg = c.yellow })
hi("Removed",      { fg = c.red })

-- Spell
hi("SpellBad",     { undercurl = true, sp = c.red })
hi("SpellCap",     { undercurl = true, sp = c.yellow })
hi("SpellLocal",   { undercurl = true, sp = c.cyan })
hi("SpellRare",    { undercurl = true, sp = c.magenta })

-- Syntax (basic)
hi("Comment",      { fg = c.comment, italic = true })
hi("Constant",     { fg = c.cyan })
hi("String",       { fg = c.green_pale })
hi("Character",    { fg = c.green_pale })
hi("Number",       { fg = c.cyan })
hi("Boolean",      { fg = c.cyan })
hi("Float",        { fg = c.cyan })
hi("Identifier",   { fg = c.fg })
hi("Function",     { fg = c.green_bright })
hi("Statement",    { fg = c.fg_alt })
hi("Conditional",  { fg = c.fg_alt })
hi("Repeat",       { fg = c.fg_alt })
hi("Label",        { fg = c.fg_alt })
hi("Operator",     { fg = c.fg })
hi("Keyword",      { fg = c.fg_alt, bold = true })
hi("Exception",    { fg = c.red })
hi("PreProc",      { fg = c.yellow_dim })
hi("Include",      { fg = c.yellow_dim })
hi("Define",       { fg = c.yellow_dim })
hi("Macro",        { fg = c.yellow_dim })
hi("PreCondit",    { fg = c.yellow_dim })
hi("Type",         { fg = c.cyan })
hi("StorageClass", { fg = c.fg_alt })
hi("Structure",    { fg = c.cyan })
hi("Typedef",      { fg = c.cyan })
hi("Special",      { fg = c.magenta })
hi("SpecialChar",  { fg = c.magenta })
hi("Tag",          { fg = c.fg_alt })
hi("Delimiter",    { fg = c.fg })
hi("SpecialComment", { fg = c.comment, bold = true })
hi("Debug",        { fg = c.orange })
hi("Underlined",   { fg = c.cyan, underline = true })
hi("Ignore",       { fg = c.comment })
hi("Error",        { fg = c.red, bold = true })
hi("Todo",         { fg = c.bg, bg = c.yellow, bold = true })

-- Treesitter
hi("@variable",              { fg = c.fg })
hi("@variable.builtin",      { fg = c.cyan })
hi("@variable.parameter",    { fg = c.fg, italic = true })
hi("@variable.member",       { fg = c.fg })
hi("@constant",              { fg = c.cyan })
hi("@constant.builtin",      { fg = c.cyan, bold = true })
hi("@constant.macro",        { fg = c.yellow_dim })
hi("@module",                { fg = c.fg_alt })
hi("@label",                 { fg = c.fg_alt })
hi("@string",                { fg = c.green_pale })
hi("@string.documentation",  { fg = c.green_pale, italic = true })
hi("@string.regexp",         { fg = c.magenta })
hi("@string.escape",         { fg = c.magenta })
hi("@string.special",        { fg = c.magenta })
hi("@character",             { fg = c.green_pale })
hi("@character.special",     { fg = c.magenta })
hi("@boolean",               { fg = c.cyan })
hi("@number",                { fg = c.cyan })
hi("@number.float",          { fg = c.cyan })
hi("@type",                  { fg = c.cyan })
hi("@type.builtin",          { fg = c.cyan })
hi("@type.definition",       { fg = c.cyan })
hi("@type.qualifier",        { fg = c.fg_alt })
hi("@attribute",             { fg = c.yellow_dim })
hi("@property",              { fg = c.fg })
hi("@function",              { fg = c.green_bright })
hi("@function.builtin",      { fg = c.green_bright })
hi("@function.call",         { fg = c.green_bright })
hi("@function.macro",        { fg = c.yellow_dim })
hi("@function.method",       { fg = c.green_bright })
hi("@function.method.call",  { fg = c.green_bright })
hi("@constructor",           { fg = c.cyan })
hi("@operator",              { fg = c.fg })
hi("@keyword",               { fg = c.fg_alt })
hi("@keyword.coroutine",     { fg = c.fg_alt })
hi("@keyword.function",      { fg = c.fg_alt })
hi("@keyword.operator",      { fg = c.fg_alt })
hi("@keyword.import",        { fg = c.yellow_dim })
hi("@keyword.storage",       { fg = c.fg_alt })
hi("@keyword.repeat",        { fg = c.fg_alt })
hi("@keyword.return",        { fg = c.fg_alt })
hi("@keyword.debug",         { fg = c.orange })
hi("@keyword.exception",     { fg = c.red })
hi("@keyword.conditional",   { fg = c.fg_alt })
hi("@keyword.directive",     { fg = c.yellow_dim })
hi("@punctuation.delimiter", { fg = c.fg })
hi("@punctuation.bracket",   { fg = c.fg })
hi("@punctuation.special",   { fg = c.magenta })
hi("@comment",               { fg = c.comment, italic = true })
hi("@comment.documentation", { fg = c.comment })
hi("@comment.error",         { fg = c.red, bold = true })
hi("@comment.warning",       { fg = c.yellow, bold = true })
hi("@comment.todo",          { fg = c.bg, bg = c.yellow, bold = true })
hi("@comment.note",          { fg = c.cyan, bold = true })
hi("@markup.strong",         { bold = true })
hi("@markup.italic",         { italic = true })
hi("@markup.strikethrough",  { strikethrough = true })
hi("@markup.underline",      { underline = true })
hi("@markup.heading",        { fg = c.green_bright, bold = true })
hi("@markup.quote",          { fg = c.comment, italic = true })
hi("@markup.math",           { fg = c.cyan })
hi("@markup.link",           { fg = c.cyan })
hi("@markup.link.label",     { fg = c.cyan })
hi("@markup.link.url",       { fg = c.cyan, underline = true })
hi("@markup.raw",            { fg = c.green_pale })
hi("@markup.list",           { fg = c.fg_alt })
hi("@diff.plus",             { fg = c.green_bright })
hi("@diff.minus",            { fg = c.red })
hi("@diff.delta",            { fg = c.yellow })
hi("@tag",                   { fg = c.fg_alt })
hi("@tag.attribute",         { fg = c.fg, italic = true })
hi("@tag.delimiter",         { fg = c.fg })

-- LSP Semantic Tokens
hi("@lsp.type.class",         { link = "@type" })
hi("@lsp.type.decorator",     { link = "@attribute" })
hi("@lsp.type.enum",          { link = "@type" })
hi("@lsp.type.enumMember",    { link = "@constant" })
hi("@lsp.type.function",      { link = "@function" })
hi("@lsp.type.interface",     { link = "@type" })
hi("@lsp.type.macro",         { link = "@function.macro" })
hi("@lsp.type.method",        { link = "@function.method" })
hi("@lsp.type.namespace",     { link = "@module" })
hi("@lsp.type.parameter",     { link = "@variable.parameter" })
hi("@lsp.type.property",      { link = "@property" })
hi("@lsp.type.struct",        { link = "@type" })
hi("@lsp.type.type",          { link = "@type" })
hi("@lsp.type.typeParameter", { link = "@type" })
hi("@lsp.type.variable",      { link = "@variable" })

-- Diagnostics
hi("DiagnosticError",          { fg = c.red })
hi("DiagnosticWarn",           { fg = c.yellow })
hi("DiagnosticInfo",           { fg = c.cyan })
hi("DiagnosticHint",           { fg = c.fg_alt })
hi("DiagnosticOk",             { fg = c.green_bright })
hi("DiagnosticVirtualTextError", { fg = c.red_dim, italic = true })
hi("DiagnosticVirtualTextWarn",  { fg = c.yellow_dim, italic = true })
hi("DiagnosticVirtualTextInfo",  { fg = c.cyan_dim, italic = true })
hi("DiagnosticVirtualTextHint",  { fg = c.green_dim, italic = true })
hi("DiagnosticVirtualTextOk",    { fg = c.green_dim, italic = true })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.cyan })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.fg_alt })
hi("DiagnosticUnderlineOk",    { undercurl = true, sp = c.green_bright })

-- LSP
hi("LspReferenceText",  { bg = c.selection })
hi("LspReferenceRead",  { bg = c.selection })
hi("LspReferenceWrite", { bg = c.selection })
hi("LspSignatureActiveParameter", { fg = c.fg, bg = c.selection, bold = true })
hi("LspCodeLens",       { fg = c.comment })
hi("LspInlayHint",      { fg = c.comment, bg = c.bg_btn, italic = true })

-- Telescope
hi("TelescopeNormal",        { fg = c.fg, bg = c.float_bg })
hi("TelescopeBorder",        { fg = c.border, bg = c.float_bg })
hi("TelescopeTitle",         { fg = c.green_bright, bold = true })
hi("TelescopePromptNormal",  { fg = c.fg, bg = c.bg_btn })
hi("TelescopePromptBorder",  { fg = c.bg_btn, bg = c.bg_btn })
hi("TelescopePromptTitle",   { fg = c.bg, bg = c.fg_alt, bold = true })
hi("TelescopePromptPrefix",  { fg = c.fg })
hi("TelescopePromptCounter", { fg = c.comment })
hi("TelescopeResultsNormal", { fg = c.fg, bg = c.float_bg })
hi("TelescopeResultsBorder", { fg = c.float_bg, bg = c.float_bg })
hi("TelescopeResultsTitle",  { fg = c.float_bg, bg = c.float_bg })
hi("TelescopePreviewNormal", { fg = c.fg, bg = c.bg })
hi("TelescopePreviewBorder", { fg = c.bg, bg = c.bg })
hi("TelescopePreviewTitle",  { fg = c.bg, bg = c.green_bright, bold = true })
hi("TelescopeSelection",     { fg = c.green_bright, bg = c.selection })
hi("TelescopeSelectionCaret", { fg = c.fg, bg = c.selection })
hi("TelescopeMatching",      { fg = c.match, bold = true })

-- Neo-tree / nvim-tree
hi("NeoTreeNormal",        { fg = c.fg, bg = c.float_bg })
hi("NeoTreeNormalNC",      { fg = c.fg, bg = c.float_bg })
hi("NeoTreeDirectoryName", { fg = c.cyan })
hi("NeoTreeDirectoryIcon", { fg = c.cyan })
hi("NeoTreeRootName",      { fg = c.green_bright, bold = true })
hi("NeoTreeFileName",      { fg = c.fg })
hi("NeoTreeFileIcon",      { fg = c.fg })
hi("NeoTreeGitAdded",      { fg = c.green_bright })
hi("NeoTreeGitModified",   { fg = c.yellow })
hi("NeoTreeGitDeleted",    { fg = c.red })
hi("NeoTreeGitConflict",   { fg = c.orange })
hi("NeoTreeGitUntracked",  { fg = c.fg_alt })
hi("NeoTreeIndentMarker",  { fg = c.border })
hi("NeoTreeWinSeparator",  { fg = c.bg, bg = c.bg })
hi("NvimTreeNormal",       { fg = c.fg, bg = c.float_bg })
hi("NvimTreeRootFolder",   { fg = c.green_bright, bold = true })
hi("NvimTreeFolderIcon",   { fg = c.cyan })
hi("NvimTreeFolderName",   { fg = c.cyan })
hi("NvimTreeOpenedFolderName", { fg = c.cyan })
hi("NvimTreeGitDirty",     { fg = c.yellow })
hi("NvimTreeGitNew",       { fg = c.green_bright })
hi("NvimTreeGitDeleted",   { fg = c.red })

-- Git Signs
hi("GitSignsAdd",          { fg = c.green_bright })
hi("GitSignsChange",       { fg = c.yellow })
hi("GitSignsDelete",       { fg = c.red })
hi("GitSignsAddNr",        { fg = c.green_bright })
hi("GitSignsChangeNr",     { fg = c.yellow })
hi("GitSignsDeleteNr",     { fg = c.red })
hi("GitSignsAddLn",        { bg = c.green_dark })
hi("GitSignsChangeLn",     { bg = "#2a2a00" })
hi("GitSignsDeleteLn",     { bg = "#2a0a0a" })
hi("GitSignsCurrentLineBlame", { fg = c.comment, italic = true })

-- Indent Blankline
hi("IblIndent",            { fg = c.green_dark })
hi("IblScope",             { fg = c.border })
hi("IndentBlanklineChar",  { fg = c.green_dark })
hi("IndentBlanklineContextChar", { fg = c.border })

-- Which-key
hi("WhichKey",             { fg = c.fg })
hi("WhichKeyGroup",        { fg = c.cyan })
hi("WhichKeySeparator",    { fg = c.comment })
hi("WhichKeyDesc",         { fg = c.fg_alt })
hi("WhichKeyFloat",        { bg = c.float_bg })

-- Notify
hi("NotifyERRORBorder",    { fg = c.red_dim })
hi("NotifyWARNBorder",     { fg = c.yellow_dim })
hi("NotifyINFOBorder",     { fg = c.cyan_dim })
hi("NotifyDEBUGBorder",    { fg = c.comment })
hi("NotifyTRACEBorder",    { fg = c.fg_alt })
hi("NotifyERRORIcon",      { fg = c.red })
hi("NotifyWARNIcon",       { fg = c.yellow })
hi("NotifyINFOIcon",       { fg = c.cyan })
hi("NotifyDEBUGIcon",      { fg = c.comment })
hi("NotifyTRACEIcon",      { fg = c.fg_alt })
hi("NotifyERRORTitle",     { fg = c.red, bold = true })
hi("NotifyWARNTitle",      { fg = c.yellow, bold = true })
hi("NotifyINFOTitle",      { fg = c.cyan, bold = true })
hi("NotifyDEBUGTitle",     { fg = c.comment, bold = true })
hi("NotifyTRACETitle",     { fg = c.fg_alt, bold = true })
hi("NotifyERRORBody",      { fg = c.fg })
hi("NotifyWARNBody",       { fg = c.fg })
hi("NotifyINFOBody",       { fg = c.fg })
hi("NotifyDEBUGBody",      { fg = c.fg })
hi("NotifyTRACEBody",      { fg = c.fg })

-- Noice
hi("NoiceCmdline",         { fg = c.fg })
hi("NoiceCmdlineIcon",     { fg = c.cyan })
hi("NoiceCmdlinePopup",    { fg = c.fg, bg = c.float_bg })
hi("NoiceCmdlinePopupBorder", { fg = c.border })
hi("NoiceConfirm",         { fg = c.fg, bg = c.float_bg })
hi("NoiceConfirmBorder",   { fg = c.border })

-- Cmp
hi("CmpItemAbbr",          { fg = c.fg })
hi("CmpItemAbbrDeprecated", { fg = c.comment, strikethrough = true })
hi("CmpItemAbbrMatch",     { fg = c.match, bold = true })
hi("CmpItemAbbrMatchFuzzy", { fg = c.match })
hi("CmpItemKind",          { fg = c.fg_alt })
hi("CmpItemKindClass",     { fg = c.cyan })
hi("CmpItemKindFunction",  { fg = c.green_bright })
hi("CmpItemKindMethod",    { fg = c.green_bright })
hi("CmpItemKindVariable",  { fg = c.fg })
hi("CmpItemKindKeyword",   { fg = c.fg_alt })
hi("CmpItemKindSnippet",   { fg = c.magenta })
hi("CmpItemKindText",      { fg = c.fg })
hi("CmpItemMenu",          { fg = c.comment })

-- Lazy
hi("LazyH1",               { fg = c.bg, bg = c.fg, bold = true })
hi("LazyButton",           { fg = c.fg, bg = c.bg_btn })
hi("LazyButtonActive",     { fg = c.bg, bg = c.fg_alt })
hi("LazySpecial",          { fg = c.cyan })
hi("LazyProgressDone",     { fg = c.fg })
hi("LazyProgressTodo",     { fg = c.comment })

-- Mason
hi("MasonNormal",          { fg = c.fg, bg = c.float_bg })
hi("MasonHeader",          { fg = c.bg, bg = c.fg, bold = true })
hi("MasonHighlight",       { fg = c.cyan })
hi("MasonHighlightBlock",  { fg = c.bg, bg = c.cyan })
hi("MasonHighlightBlockBold", { fg = c.bg, bg = c.cyan, bold = true })
hi("MasonMuted",           { fg = c.comment })
hi("MasonMutedBlock",      { fg = c.fg, bg = c.bg_btn })

-- Dashboard / Alpha
hi("DashboardHeader",      { fg = c.fg })
hi("DashboardFooter",      { fg = c.comment, italic = true })
hi("DashboardCenter",      { fg = c.cyan })
hi("DashboardShortCut",    { fg = c.fg_alt })
hi("AlphaHeader",          { fg = c.fg })
hi("AlphaFooter",          { fg = c.comment, italic = true })
hi("AlphaButtons",         { fg = c.cyan })
hi("AlphaShortcut",        { fg = c.fg_alt })

-- Mini
hi("MiniStatuslineDevinfo",     { fg = c.fg, bg = c.bg_alt })
hi("MiniStatuslineFileinfo",    { fg = c.fg, bg = c.bg_alt })
hi("MiniStatuslineFilename",    { fg = c.fg_alt, bg = c.bg_btn })
hi("MiniStatuslineInactive",    { fg = c.comment, bg = c.bg_btn })
hi("MiniStatuslineModeCommand", { fg = c.bg, bg = c.yellow, bold = true })
hi("MiniStatuslineModeInsert",  { fg = c.bg, bg = c.cyan, bold = true })
hi("MiniStatuslineModeNormal",  { fg = c.bg, bg = c.fg, bold = true })
hi("MiniStatuslineModeOther",   { fg = c.bg, bg = c.magenta, bold = true })
hi("MiniStatuslineModeReplace", { fg = c.bg, bg = c.red, bold = true })
hi("MiniStatuslineModeVisual",  { fg = c.bg, bg = c.fg_alt, bold = true })

-- Heirline/Lualine mode colors
hi("HeirlineNormal",       { fg = c.bg, bg = c.fg, bold = true })
hi("HeirlineInsert",       { fg = c.bg, bg = c.cyan, bold = true })
hi("HeirlineVisual",       { fg = c.bg, bg = c.fg_alt, bold = true })
hi("HeirlineReplace",      { fg = c.bg, bg = c.red, bold = true })
hi("HeirlineCommand",      { fg = c.bg, bg = c.yellow, bold = true })
hi("HeirlineTerminal",     { fg = c.bg, bg = c.magenta, bold = true })

-- Flash
hi("FlashBackdrop",        { fg = c.comment })
hi("FlashLabel",           { fg = c.bg, bg = c.fg, bold = true })
hi("FlashMatch",           { fg = c.green_bright })
hi("FlashCurrent",         { fg = c.bg, bg = c.green_bright })

-- Leap
hi("LeapBackdrop",         { fg = c.comment })
hi("LeapMatch",            { fg = c.green_bright, bold = true })
hi("LeapLabelPrimary",     { fg = c.bg, bg = c.fg, bold = true })
hi("LeapLabelSecondary",   { fg = c.bg, bg = c.fg_alt })

-- Navic
hi("NavicText",            { fg = c.fg })
hi("NavicSeparator",       { fg = c.comment })
hi("NavicIconsFile",       { fg = c.fg })
hi("NavicIconsModule",     { fg = c.fg_alt })
hi("NavicIconsNamespace",  { fg = c.fg_alt })
hi("NavicIconsPackage",    { fg = c.fg_alt })
hi("NavicIconsClass",      { fg = c.cyan })
hi("NavicIconsMethod",     { fg = c.green_bright })
hi("NavicIconsProperty",   { fg = c.fg })
hi("NavicIconsField",      { fg = c.fg })
hi("NavicIconsConstructor", { fg = c.cyan })
hi("NavicIconsEnum",       { fg = c.cyan })
hi("NavicIconsInterface",  { fg = c.cyan })
hi("NavicIconsFunction",   { fg = c.green_bright })
hi("NavicIconsVariable",   { fg = c.fg })
hi("NavicIconsConstant",   { fg = c.cyan })
hi("NavicIconsString",     { fg = c.green_pale })
hi("NavicIconsNumber",     { fg = c.cyan })
hi("NavicIconsBoolean",    { fg = c.cyan })
hi("NavicIconsArray",      { fg = c.cyan })
hi("NavicIconsObject",     { fg = c.cyan })
hi("NavicIconsKey",        { fg = c.fg_alt })
hi("NavicIconsNull",       { fg = c.cyan })
hi("NavicIconsEnumMember", { fg = c.cyan })
hi("NavicIconsStruct",     { fg = c.cyan })
hi("NavicIconsEvent",      { fg = c.yellow })
hi("NavicIconsOperator",   { fg = c.fg })
hi("NavicIconsTypeParameter", { fg = c.cyan })

-- Trouble
hi("TroubleNormal",        { fg = c.fg, bg = c.float_bg })
hi("TroubleText",          { fg = c.fg })
hi("TroubleCount",         { fg = c.bg, bg = c.fg_alt })
hi("TroubleFile",          { fg = c.cyan })
hi("TroubleLocation",      { fg = c.comment })
hi("TroublePreview",       { bg = c.selection })

-- Terminal colors
vim.g.terminal_color_0  = c.bg
vim.g.terminal_color_1  = c.red
vim.g.terminal_color_2  = c.fg
vim.g.terminal_color_3  = c.yellow
vim.g.terminal_color_4  = c.cyan
vim.g.terminal_color_5  = c.magenta
vim.g.terminal_color_6  = c.cyan
vim.g.terminal_color_7  = c.fg
vim.g.terminal_color_8  = c.comment
vim.g.terminal_color_9  = c.red
vim.g.terminal_color_10 = c.green_bright
vim.g.terminal_color_11 = c.yellow
vim.g.terminal_color_12 = c.cyan
vim.g.terminal_color_13 = c.magenta
vim.g.terminal_color_14 = c.cyan
vim.g.terminal_color_15 = c.fg
