-- caelestia colorscheme integration for lazy.nvim.
--
-- Behavior by setup:
--   * LazyVim distribution:  registers `opts.colorscheme = "caelestia"` on LazyVim
--                            so its boot sequence applies it at the right time.
--   * Plain lazy.nvim:       applies `:colorscheme caelestia` via VimEnter,
--                            without pulling in the whole LazyVim distribution.
--   * Other plugin managers: this file is never read (only lazy.nvim looks here).
--                            Drop `colors/caelestia.lua` into your runtimepath
--                            and put `vim.cmd.colorscheme("caelestia")` in init.lua.
--
-- Options (set before this file loads, e.g. in your init.lua):
--   vim.g.caelestia_transparent = false  -- opaque background (default: true)

local function has_lazyvim()
  if pcall(require, "lazyvim") then return true end
  local stat = (vim.uv or vim.loop).fs_stat(vim.fn.stdpath("data") .. "/lazy/LazyVim")
  return stat ~= nil
end

if has_lazyvim() then
  return {
    { "LazyVim/LazyVim", opts = { colorscheme = "caelestia" } },
  }
end

-- Plain lazy.nvim path: defer to VimEnter so any plugins that ship highlight
-- groups (gitsigns, telescope, neo-tree, etc.) have already loaded.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  group = vim.api.nvim_create_augroup("caelestia_colorscheme", { clear = true }),
  callback = function() pcall(vim.cmd.colorscheme, "caelestia") end,
})

return {}
