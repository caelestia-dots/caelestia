hl.config({
  general = {
    layout = "dwindle",
    allow_tearing = false, -- Allows `immediate` window rule to work

    gaps_workspaces = Config.vars.workspaceGaps,
    gaps_in = Config.vars.windowGapsIn,
    gaps_out = Config.vars.windowGapsOut,
    border_size = Config.vars.windowBorderSize,

    col = {
      active_border = Config.computed.activeWindowBorderColour,
      inactive_border = Config.computed.inactiveWindowBorderColour,
    },
  },

  dwindle = {
    preserve_split = true,
    smart_split = false,
    smart_resizing = true,
  },
})
