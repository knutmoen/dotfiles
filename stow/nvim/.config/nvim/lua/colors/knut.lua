local M = {}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.load()
  vim.o.termguicolors = true
  vim.o.background = "dark"

  local c = {
    bg = "#141F2E",
    bg_alt = "#1B2B40",
    fg = "#E6E6E6",
    line_nr = "#808080",
    indent = "#273E5C",
    selection = "#FFFFFF",
    selection_fg = "#000000",
    caret_row = "#1B2B40",
    keyword = "#949ECA",
    type = "#91CCFF",
    func = "#6363FD",
    identifier = "#FFAAC4",
    field = "#DDCBDD",
    param = "#FFFAB1",
    const = "#746574",
    string = "#A0FFA0",
    number = "#FF8080",
    accent = "#FFCC33",
    comment = "#50F050",
    error = "#F05050",
    warn = "#FFCC33",
    info = "#83A6C1",
    hint = "#80FF80",
    border = "#273E5C",
  }

  hi("Normal", { fg = c.fg, bg = c.bg })
  hi("NormalFloat", { fg = c.fg, bg = c.bg_alt })
  hi("FloatBorder", { fg = c.border, bg = c.bg_alt })
  hi("WinSeparator", { fg = c.border, bg = c.bg })
  hi("SignColumn", { bg = c.bg })
  hi("LineNr", { fg = c.line_nr, bg = c.bg })
  hi("CursorLineNr", { fg = c.accent, bg = c.caret_row })
  hi("CursorLine", { bg = c.caret_row })
  hi("ColorColumn", { bg = c.indent })
  hi("Visual", { fg = c.selection_fg, bg = c.selection })
  hi("Pmenu", { fg = c.fg, bg = c.bg_alt })
  hi("PmenuSel", { fg = c.selection_fg, bg = c.selection })

  hi("Comment", { fg = c.comment, italic = true })
  hi("Constant", { fg = c.const })
  hi("String", { fg = c.string })
  hi("Number", { fg = c.number })
  hi("Identifier", { fg = c.identifier })
  hi("Function", { fg = c.func, bold = true })
  hi("Field", { fg = c.field })
  hi("Parameter", { fg = c.param })
  hi("Type", { fg = c.type, bold = true })
  hi("Keyword", { fg = c.keyword, bold = true })
  hi("Statement", { fg = c.keyword })
  hi("Operator", { fg = c.keyword })
  hi("PreProc", { fg = c.accent })
  hi("Special", { fg = c.accent })

  hi("DiagnosticError", { fg = c.error })
  hi("DiagnosticWarn", { fg = c.warn })
  hi("DiagnosticInfo", { fg = c.info })
  hi("DiagnosticHint", { fg = c.hint })
  hi("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
  hi("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warn })
  hi("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
  hi("DiagnosticUnderlineHint", { undercurl = true, sp = c.hint })

  hi("@comment", { fg = c.comment, italic = true })
  hi("@keyword", { fg = c.keyword, bold = true })
  hi("@keyword.function", { fg = c.keyword, bold = true })
  hi("@type", { fg = c.type, bold = true })
  hi("@type.builtin", { fg = c.accent, bold = true })
  hi("@function", { fg = c.func, bold = true })
  hi("@function.method", { fg = c.func, bold = true })
  hi("@constructor", { fg = c.accent })
  hi("@variable", { fg = c.identifier })
  hi("@variable.parameter", { fg = c.param })
  hi("@field", { fg = c.field })
  hi("@property", { fg = c.field })
  hi("@constant", { fg = c.const })
  hi("@constant.builtin", { fg = c.accent })
  hi("@string", { fg = c.string })
  hi("@number", { fg = c.number })
  hi("@boolean", { fg = c.number })
  hi("@punctuation", { fg = c.line_nr })

  hi("DiffAdd", { bg = "#408040" })
  hi("DiffChange", { bg = "#4D6F99" })
  hi("DiffDelete", { bg = "#666666" })
  hi("DiffText", { bg = "#4D6F99" })
end

return M
