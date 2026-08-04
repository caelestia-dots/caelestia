-- Dynamic colorscheme sourced from caelestia's Material Design 3 palette + term0..term15.
-- Reads ~/.local/state/caelestia/scheme.json, applies highlights directly,
-- and live-reloads when caelestia regenerates the file (wallpaper change).

local scheme_path = vim.fn.expand("~/.local/state/caelestia/scheme.json")
local uv = vim.uv or vim.loop

local function read_palette()
  local f = io.open(scheme_path, "r")
  if not f then return nil end
  local raw = f:read("*a"); f:close()
  local ok, data = pcall(vim.json.decode, raw)
  if not ok or type(data) ~= "table" or type(data.colours) ~= "table" then return nil end
  local out = {}
  for k, v in pairs(data.colours) do
    if type(v) == "string" and v:match("^%x%x%x%x%x%x$") then out[k] = "#" .. v end
  end
  return out
end

local function blend(c1, c2, a)
  local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
  local r1, g1, b1 = rgb(c1)
  local r2, g2, b2 = rgb(c2)
  return string.format("#%02x%02x%02x",
    math.floor(r1*a + r2*(1-a)), math.floor(g1*a + g2*(1-a)), math.floor(b1*a + b2*(1-a)))
end

local function apply(p)
  if not p then return end
  local transparent = vim.g.caelestia_transparent ~= false
  local bg = transparent and "NONE" or p.surface
  local container_bg = transparent and "NONE" or p.surfaceContainer
  local container_low_bg = transparent and "NONE" or p.surfaceContainerLow
  local hl = function(g, s) vim.api.nvim_set_hl(0, g, s) end

  -- Editor UI
  hl("Normal",        { fg = p.onSurface, bg = bg })
  hl("NormalNC",      { fg = p.onSurface, bg = bg })
  hl("NormalFloat",   { fg = p.onSurface, bg = container_bg })
  hl("FloatBorder",   { fg = p.outline, bg = "NONE" })
  hl("FloatTitle",    { fg = p.primary, bold = true })
  hl("CursorLine",    { bg = p.surfaceContainerHigh })
  hl("CursorLineNr",  { fg = p.primary, bold = true })
  hl("LineNr",        { fg = p.outline })
  hl("SignColumn",    { bg = bg })
  hl("WinSeparator",  { fg = p.outlineVariant })
  hl("VertSplit",     { fg = p.outlineVariant })
  hl("MatchParen",    { fg = p.primary, bold = true, underline = true })
  hl("NonText",       { fg = p.outline })
  hl("Whitespace",    { fg = p.outlineVariant })
  hl("ColorColumn",   { bg = p.surfaceContainer })
  hl("Folded",        { fg = p.onSurfaceVariant, bg = p.surfaceContainer })
  hl("Conceal",       { fg = p.onSurfaceVariant })

  -- Selection / search. Visual uses primaryContainer (a clearly tinted "filled"
  -- background per Material semantics) so selections are obvious in both modes;
  -- surfaceContainerHighest is too close to surface and disappears on light.
  hl("Visual",        { fg = p.onPrimaryContainer, bg = p.primaryContainer })
  hl("VisualNOS",     { fg = p.onPrimaryContainer, bg = p.primaryContainer })
  hl("Search",        { fg = p.onTertiaryContainer, bg = p.tertiaryContainer })
  hl("IncSearch",     { fg = p.onPrimary, bg = p.primary })
  hl("CurSearch",     { fg = p.onPrimary, bg = p.primary })

  -- Completion menu
  hl("Pmenu",         { fg = p.onSurface, bg = p.surfaceContainerHigh })
  hl("PmenuSel",      { fg = p.onPrimaryContainer, bg = p.primaryContainer, bold = true })
  hl("PmenuSbar",     { bg = p.surfaceContainerHighest })
  hl("PmenuThumb",    { bg = p.outline })

  -- Statusline / tabline
  hl("StatusLine",    { fg = p.onSurface, bg = container_bg })
  hl("StatusLineNC",  { fg = p.onSurfaceVariant, bg = container_low_bg })
  hl("TabLineSel",    { fg = p.primary, bg = bg, bold = true })
  hl("WinBar",        { fg = p.onSurfaceVariant, bg = bg })

  -- Spell
  hl("SpellBad",      { sp = p.error, undercurl = true })
  hl("SpellCap",      { sp = p.term3, undercurl = true })
  hl("SpellRare",     { sp = p.term5, undercurl = true })
  hl("SpellLocal",    { sp = p.term6, undercurl = true })

  -- Diff (blended so it sits subtly over surface)
  hl("DiffAdd",       { bg = blend(p.term2, p.surface, 0.25) })
  hl("DiffChange",    { bg = blend(p.term3, p.surface, 0.20) })
  hl("DiffDelete",    { bg = blend(p.term1, p.surface, 0.25) })
  hl("DiffText",      { bg = blend(p.term3, p.surface, 0.45) })

  -- Syntax (legacy groups; treesitter inherits where not set).
  -- Mapping rule (matches caelestia's terminal palette convention):
  -- only term1..6 are safe in both modes — term8..15 are "bright" ANSI variants
  -- that lose contrast on light backgrounds. Chrome text uses Material keys
  -- (onSurfaceVariant / outline / onSurface) which caelestia tunes per mode.
  hl("Comment",       { fg = p.onSurfaceVariant, italic = true })
  hl("String",        { fg = p.term2 })
  hl("Number",        { fg = p.term3 })
  hl("Boolean",       { fg = p.term3 })
  hl("Constant",      { fg = p.term3 })
  hl("Function",      { fg = p.term4 })
  hl("Statement",     { fg = p.term5 })  -- Keyword, Conditional, Repeat, Label, Exception link to this
  hl("Operator",      { fg = p.term6 })  -- overrides default Statement link
  hl("Type",          { fg = p.term3 })
  hl("PreProc",       { fg = p.term1 })
  hl("Special",       { fg = p.term6 })
  hl("Delimiter",     { fg = p.onSurfaceVariant })
  hl("Error",         { fg = p.error })
  hl("Todo",          { fg = p.onTertiary, bg = p.tertiary, bold = true })
  hl("Title",         { fg = p.primary, bold = true })
  hl("Identifier",    { fg = p.onSurface })  -- clears default cyan; variables look like regular text

  -- Treesitter
  hl("@variable",            { fg = p.onSurface })
  hl("@variable.builtin",    { fg = p.term5 })
  hl("@variable.parameter",  { fg = p.onSurface })
  hl("@variable.member",     { fg = p.onSurface })
  hl("@property",            { fg = p.onSurface })
  hl("@function",            { fg = p.term4 })
  hl("@function.builtin",    { fg = p.term5 })
  hl("@function.macro",      { fg = p.term1 })
  hl("@constructor",         { fg = p.term3 })
  hl("@keyword",             { fg = p.term5 })
  hl("@keyword.return",      { fg = p.term5, bold = true })
  hl("@string.escape",       { fg = p.term6 })
  hl("@type.builtin",        { fg = p.term3, italic = true })
  hl("@tag",                 { fg = p.term4 })
  hl("@tag.attribute",       { fg = p.onSurface })
  hl("@namespace",           { fg = p.term3 })
  hl("@punctuation.bracket", { fg = p.onSurfaceVariant })
  hl("@markup.heading",      { fg = p.primary, bold = true })
  hl("@markup.link",         { fg = p.term4, underline = true })
  hl("@diff.plus",           { fg = p.term2 })
  hl("@diff.minus",          { fg = p.term1 })

  -- LSP semantic tokens
  hl("@lsp.type.namespace",  { link = "@namespace" })
  hl("@lsp.type.type",       { link = "@type" })
  hl("@lsp.type.class",      { link = "@type" })
  hl("@lsp.type.parameter",  { link = "@variable.parameter" })
  hl("@lsp.type.property",   { link = "@property" })
  hl("@lsp.type.enumMember", { link = "@number" })
  hl("@lsp.type.function",   { link = "@function" })
  hl("@lsp.type.method",     { link = "@function" })
  hl("@lsp.type.macro",      { link = "@function.macro" })
  hl("@lsp.typemod.variable.readonly", { fg = p.term3 })

  -- Diagnostics
  hl("DiagnosticError",   { fg = p.error })
  hl("DiagnosticWarn",    { fg = p.term3 })
  hl("DiagnosticInfo",    { fg = p.term4 })
  hl("DiagnosticHint",    { fg = p.term6 })
  hl("DiagnosticOk",      { fg = p.term2 })
  hl("DiagnosticUnderlineError", { sp = p.error, undercurl = true })
  hl("DiagnosticUnderlineWarn",  { sp = p.term3, undercurl = true })
  hl("DiagnosticUnderlineInfo",  { sp = p.term4, undercurl = true })
  hl("DiagnosticUnderlineHint",  { sp = p.term6, undercurl = true })
  hl("DiagnosticUnderlineOk",    { sp = p.term2, undercurl = true })
  hl("DiagnosticVirtualTextError", { fg = p.error,  bg = blend(p.error,  p.surface, 0.15) })
  hl("DiagnosticVirtualTextWarn",  { fg = p.term3,  bg = blend(p.term3,  p.surface, 0.15) })
  hl("DiagnosticVirtualTextInfo",  { fg = p.term4,  bg = blend(p.term4,  p.surface, 0.15) })
  hl("DiagnosticVirtualTextHint",  { fg = p.term6,  bg = blend(p.term6,  p.surface, 0.15) })
  hl("DiagnosticVirtualTextOk",    { fg = p.term2,  bg = blend(p.term2,  p.surface, 0.15) })

  -- Common plugin groups (transparent-friendly)
  for _, g in ipairs({
    "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
    "TelescopeNormal", "TelescopePromptNormal", "TelescopeResultsNormal",
    "TelescopePreviewNormal",
    "LazyNormal", "MasonNormal",
    "WhichKeyFloat", "WhichKeyNormal",
    "SnacksDashboardNormal", "SnacksPickerNormal",
  }) do hl(g, { bg = container_bg }) end

  for _, g in ipairs({
    "TelescopeBorder", "TelescopePromptBorder", "TelescopeResultsBorder",
    "TelescopePreviewBorder", "NeoTreeFloatBorder", "SnacksPickerBorder",
  }) do hl(g, { fg = p.outline, bg = "NONE" }) end

  hl("TelescopeSelection",    { bg = p.surfaceContainerHigh, bold = true })
  hl("TelescopeMatching",     { fg = p.primary, bold = true })
  hl("TelescopePromptPrefix", { fg = p.primary })

  -- Base Directory group is used by many file UIs (neo-tree, oil, fzf-lua,
  -- completion menus). Without an explicit override the LazyVim default
  -- ("#8cf8f7") leaks through and never updates on live reapply.
  hl("Directory",             { fg = p.term4 })
  hl("NeoTreeDirectoryName",  { fg = p.term4 })
  hl("NeoTreeDirectoryIcon",  { fg = p.term4 })
  hl("NeoTreeFileName",       { fg = p.onSurface })
  hl("NeoTreeFileNameOpened", { fg = p.primary, bold = true })
  hl("NeoTreeRootName",       { fg = p.primary, bold = true, italic = true })
  hl("NeoTreeSymbolicLinkTarget", { fg = p.term6 })
  hl("NeoTreeDotfile",        { fg = p.outline })
  hl("NeoTreeHiddenByName",   { fg = p.outline })
  hl("NeoTreeIndentMarker",   { fg = p.outlineVariant })
  hl("NeoTreeExpander",       { fg = p.outline })
  hl("NeoTreeModified",       { fg = p.term3 })
  hl("NeoTreeGitModified",    { fg = p.term3 })
  hl("NeoTreeGitAdded",       { fg = p.term2 })
  hl("NeoTreeGitDeleted",     { fg = p.term1 })
  hl("NeoTreeGitUntracked",   { fg = p.term2, italic = true })
  hl("NeoTreeGitIgnored",     { fg = p.outline })
  hl("NeoTreeGitConflict",    { fg = p.error, bold = true })
  hl("NeoTreeGitStaged",      { fg = p.term2 })
  hl("NeoTreeGitUnstaged",    { fg = p.term1 })
  hl("GitSignsAdd",           { fg = p.term2 })
  hl("GitSignsChange",        { fg = p.term3 })
  hl("GitSignsDelete",        { fg = p.term1 })

  -- mini.icons palette. Defines these explicitly because mini.icons sets them
  -- with `default = true` on the ColorScheme autocmd — which often fires before
  -- the plugin lazy-loads, leaving the groups undefined and falling back to
  -- terminal defaults (the "weird blue names" symptom).
  hl("MiniIconsAzure",  { fg = p.term4 })
  hl("MiniIconsBlue",   { fg = p.term4 })
  hl("MiniIconsCyan",   { fg = p.term6 })
  hl("MiniIconsGreen",  { fg = p.term2 })
  hl("MiniIconsGrey",   { fg = p.onSurfaceVariant })
  hl("MiniIconsOrange", { fg = p.term1 })
  hl("MiniIconsPurple", { fg = p.term5 })
  hl("MiniIconsRed",    { fg = p.error })
  hl("MiniIconsYellow", { fg = p.term3 })

  vim.g.colors_name = "caelestia"
end

-- Watcher: detect scheme.json changes and re-apply.
--
-- Three things go wrong under naive `fs_event → apply`:
--   1. caelestia may write scheme.json more than once per wallpaper change
--      (intermediate then final). Applying only on the first write leaves
--      stale colors.
--   2. fs_event on Linux dies when the inode is replaced by an atomic-rename
--      write, so we stop+restart the handle on every event. We are blind
--      during the restart window.
--   3. Some plugins' ColorScheme handlers run via vim.schedule after ours,
--      and re-set highlights from cached defaults — overriding our apply.
--
-- Strategy: leading-edge response (apply immediately on event for snappy
-- feedback) plus a single coalesced verify pass ~250ms later that catches
-- partial reads, late writes, and post-hoc plugin overrides. Multiple events
-- in the verify window collapse into one verify, always reading the latest
-- file content.

local watch_handle
local verify_timer

local function read_apply()
  local p = read_palette()
  if not p then return false end  -- partial / corrupt; verify pass will retry
  apply(p)
  pcall(vim.api.nvim_exec_autocmds, "ColorScheme", { modeline = false })
  return true
end

local function trigger()
  pcall(read_apply)  -- immediate; may no-op if file is mid-write
  if verify_timer then verify_timer:stop(); verify_timer:close() end
  verify_timer = uv.new_timer()
  verify_timer:start(250, 0, vim.schedule_wrap(function()
    verify_timer:close(); verify_timer = nil
    pcall(read_apply)
  end))
end

local function watch()
  if watch_handle then return end
  watch_handle = uv.new_fs_event()
  if not watch_handle then return end
  local function arm()
    local ok = watch_handle:start(scheme_path, {}, vim.schedule_wrap(function(err)
      watch_handle:stop()
      if not err then trigger() end
      vim.defer_fn(arm, 10)  -- minimal blind window between events
    end))
    if not ok then vim.defer_fn(arm, 1000) end
  end
  arm()
end

apply(read_palette())
watch()
