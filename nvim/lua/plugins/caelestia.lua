-- Sync Neovim colors from caelestia's generated scheme.json
-- Caelestia writes ~/.local/state/caelestia/scheme.json with a Catppuccin-shaped palette,
-- so we feed those colors into catppuccin's mocha flavour via color_overrides.

local scheme_path = vim.fn.expand("~/.local/state/caelestia/scheme.json")

local function read_palette()
  local f = io.open(scheme_path, "r")
  if not f then return nil end
  local raw = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, raw)
  if not ok or type(data) ~= "table" or type(data.colours) ~= "table" then return nil end
  local out = {}
  for k, v in pairs(data.colours) do
    if type(v) == "string" and v:match("^%x%x%x%x%x%x$") then
      out[k] = "#" .. v
    end
  end
  return out
end

local function overrides_from(p)
  if not p then return {} end
  -- catppuccin mocha palette keys ← caelestia palette keys (1:1 names where possible)
  local keys = {
    "rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach",
    "yellow", "green", "teal", "sky", "sapphire", "blue", "lavender",
    "text", "subtext1", "subtext0",
    "overlay2", "overlay1", "overlay0",
    "surface2", "surface1", "surface0",
    "base", "mantle", "crust",
  }
  local o = {}
  for _, k in ipairs(keys) do
    if p[k] then o[k] = p[k] end
  end
  return o
end

local function reapply()
  local cp = require("catppuccin")
  cp.setup(vim.tbl_deep_extend("force", require("catppuccin").options or {}, {
    color_overrides = { mocha = overrides_from(read_palette()) },
  }))
  vim.cmd.colorscheme("catppuccin")
end

-- libuv fs_event re-arms itself after most editors' atomic-rename writes
local function watch_scheme()
  local uv = vim.uv or vim.loop
  local handle = uv.new_fs_event()
  if not handle then return end
  local function arm()
    handle:start(scheme_path, {}, vim.schedule_wrap(function(err)
      handle:stop()
      if not err then pcall(reapply) end
      vim.defer_fn(arm, 100)
    end))
  end
  arm()
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = function()
      return {
        flavour = "mocha",
        background = { dark = "mocha" },
        transparent_background = true,
        color_overrides = { mocha = overrides_from(read_palette()) },
        custom_highlights = function()
          -- Clear backgrounds on UI panes that catppuccin paints opaque even in transparent mode
          local clear = { bg = "NONE" }
          return {
            NeoTreeNormal = clear, NeoTreeNormalNC = clear,
            NeoTreeEndOfBuffer = clear, NeoTreeWinSeparator = clear,
            NeoTreeStatusLine = clear, NeoTreeStatusLineNC = clear,
            NormalFloat = clear, FloatBorder = clear,
            TelescopeNormal = clear, TelescopeBorder = clear,
            TelescopePromptNormal = clear, TelescopePromptBorder = clear,
            TelescopeResultsNormal = clear, TelescopeResultsBorder = clear,
            TelescopePreviewNormal = clear, TelescopePreviewBorder = clear,
            LazyNormal = clear, MasonNormal = clear,
            WhichKeyFloat = clear, WhichKeyNormal = clear,
            NoicePopup = clear, NoicePopupmenu = clear,
            SnacksDashboardNormal = clear, SnacksPickerNormal = clear,
            SnacksPickerBorder = clear, SnacksPickerListBorder = clear,
            SnacksPickerPreviewBorder = clear, SnacksPickerInputBorder = clear,
          }
        end,
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          notify = true,
          mini = { enabled = true },
          telescope = { enabled = true },
          which_key = true,
          native_lsp = { enabled = true, inlay_hints = { background = true } },
          mason = true,
          neotree = true,
          noice = true,
          flash = true,
          dashboard = true,
          render_markdown = true,
          blink_cmp = true,
          fzf = true,
          snacks = true,
        },
      }
    end,
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
      watch_scheme()
    end,
  },

  -- Make catppuccin the default LazyVim colorscheme
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
