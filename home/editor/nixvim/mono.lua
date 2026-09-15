-- Monochrome colorscheme driven by the system palette.
-- Reads ~/.config/theme/palette.json and the mode file at load time; the
-- Signal/FocusGained autocmds in theme.nix re-run it when the mode flips.
local cfg = vim.fn.expand("~/.config/theme")
local function read(p) local f = io.open(p); if not f then return nil end; local s = f:read("*a"); f:close(); return s end
local mode = (read(cfg .. "/mode") or "light"):gsub("%s", "")
local ok, palette = pcall(vim.json.decode, read(cfg .. "/palette.json") or "")
if not ok then return end
local c = palette[mode] or palette.light

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "mono"
vim.o.background = mode

local function hi(g, o) vim.api.nvim_set_hl(0, g, o) end
local groups = {
  -- editor
  Normal        = { fg = c.onyx, bg = c.ivory },
  NormalFloat   = { fg = c.onyx, bg = c.linen },
  FloatBorder   = { fg = c.pebble, bg = c.linen },
  CursorLine    = { bg = c.linen },
  CursorLineNr  = { fg = c.onyx, bold = true },
  LineNr        = { fg = c.stone },
  SignColumn    = { bg = c.ivory },
  ColorColumn   = { bg = c.linen },
  Visual        = { bg = c.sand },
  Search        = { bg = c.pebble },
  CurSearch     = { fg = c.ivory, bg = c.basalt },
  IncSearch     = { fg = c.ivory, bg = c.basalt },
  MatchParen    = { bg = c.pebble, bold = true },
  NonText       = { fg = c.silverBirch },
  Whitespace    = { fg = c.silverBirch },
  EndOfBuffer   = { fg = c.ivory },
  WinSeparator  = { fg = c.mist },
  StatusLine    = { fg = c.onyx, bg = c.cream },
  StatusLineNC  = { fg = c.slate, bg = c.linen },
  TabLine       = { fg = c.slate, bg = c.linen },
  TabLineSel    = { fg = c.onyx, bg = c.sand, bold = true },
  TabLineFill   = { bg = c.linen },
  Pmenu         = { fg = c.onyx, bg = c.linen },
  PmenuSel      = { bg = c.sand },
  PmenuSbar     = { bg = c.cream },
  PmenuThumb    = { bg = c.pebble },
  Folded        = { fg = c.graphite, bg = c.cream },
  Directory     = { fg = c.obsidian, bold = true },
  Title         = { fg = c.onyx, bold = true },
  Question      = { fg = c.basalt },
  MoreMsg       = { fg = c.basalt },
  ModeMsg       = { fg = c.basalt },
  WarningMsg    = { fg = c.basalt, bold = true },
  ErrorMsg      = { fg = c.clay, bold = true },
  Conceal       = { fg = c.slate },
  -- syntax: greys only, hierarchy by weight and shade
  Comment       = { fg = c.slate, italic = true },
  Constant      = { fg = c.basalt },
  String        = { fg = c.charcoal },
  Character     = { fg = c.charcoal },
  Number        = { fg = c.basalt },
  Boolean       = { fg = c.basalt, bold = true },
  Identifier    = { fg = c.onyx },
  Function      = { fg = c.onyx, bold = true },
  Statement     = { fg = c.obsidian, bold = true },
  Keyword       = { fg = c.obsidian, bold = true },
  Operator      = { fg = c.basalt },
  PreProc       = { fg = c.basalt },
  Type          = { fg = c.obsidian },
  Special       = { fg = c.charcoal },
  Delimiter     = { fg = c.graphite },
  Underlined    = { underline = true },
  Todo          = { fg = c.onyx, bg = c.sand, bold = true },
  Error         = { fg = c.clay },
  ["@variable"]           = { fg = c.onyx },
  ["@variable.builtin"]   = { fg = c.obsidian, italic = true },
  ["@property"]           = { fg = c.charcoal },
  ["@punctuation"]        = { fg = c.graphite },
  ["@tag"]                = { fg = c.obsidian, bold = true },
  ["@tag.attribute"]      = { fg = c.charcoal },
  ["@markup.heading"]     = { fg = c.onyx, bold = true },
  ["@markup.link.url"]    = { fg = c.basalt, underline = true },
  ["@markup.raw"]         = { fg = c.charcoal, bg = c.linen },
  -- diagnostics / diff
  DiagnosticError = { fg = c.clay },
  DiagnosticWarn  = { fg = c.basalt },
  DiagnosticInfo  = { fg = c.graphite },
  DiagnosticHint  = { fg = c.slate },
  DiagnosticUnderlineError = { undercurl = true, sp = c.clay },
  DiagnosticUnderlineWarn  = { undercurl = true, sp = c.basalt },
  DiagnosticUnderlineInfo  = { undercurl = true, sp = c.graphite },
  DiagnosticUnderlineHint  = { undercurl = true, sp = c.slate },
  DiffAdd     = { fg = c.ansi.green },
  DiffDelete  = { fg = c.ansi.red },
  DiffChange  = { bg = c.linen },
  DiffText    = { bg = c.sand },
  Added       = { fg = c.ansi.green },
  Removed     = { fg = c.ansi.red },
  Changed     = { fg = c.ansi.yellow },
  GitSignsAdd    = { fg = c.ansi.green },
  GitSignsChange = { fg = c.ansi.yellow },
  GitSignsDelete = { fg = c.ansi.red },
  -- plugins
  TelescopeBorder       = { fg = c.pebble, bg = c.linen },
  TelescopeNormal       = { bg = c.linen },
  TelescopeSelection    = { bg = c.sand },
  TelescopeMatching     = { fg = c.onyx, bold = true },
  NeoTreeNormal         = { fg = c.onyx, bg = c.linen },
  NeoTreeNormalNC       = { fg = c.onyx, bg = c.linen },
  NeoTreeCursorLine     = { bg = c.sand },
  NeoTreeDimText        = { fg = c.slate },
  NeoTreeGitModified    = { fg = c.ansi.yellow },
  NeoTreeGitUntracked   = { fg = c.ansi.green },
  WhichKeyBorder        = { fg = c.pebble, bg = c.linen },
  LspReferenceText      = { bg = c.cream },
  LspReferenceRead      = { bg = c.cream },
  LspReferenceWrite     = { bg = c.sand },
  IndentBlanklineChar   = { fg = c.mist },
  IblIndent             = { fg = c.mist },
  IblScope              = { fg = c.pebble },
}
for g, o in pairs(groups) do hi(g, o) end

local order = { "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
  "brightBlack", "brightRed", "brightGreen", "brightYellow", "brightBlue", "brightMagenta", "brightCyan", "brightWhite" }
for i, n in ipairs(order) do vim.g["terminal_color_" .. (i - 1)] = c.ansi[n] end
