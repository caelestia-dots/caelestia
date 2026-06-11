local vars = Config.vars
local computed = Config.computed

hl.config({
  general = {
    layout = "dwindle",
    allow_tearing = false, -- Allows `immediate` window rule to work

    gaps_workspaces = vars.workspaceGaps,
    gaps_in = vars.windowGapsIn,
    gaps_out = vars.windowGapsOut,
    border_size = vars.windowBorderSize,

    col = {
      active_border = computed.activeWindowBorderColour,
      inactive_border = computed.inactiveWindowBorderColour,
    },
  },

  dwindle = {
    preserve_split = true,
    smart_split = false,
    smart_resizing = true,
  },
})
