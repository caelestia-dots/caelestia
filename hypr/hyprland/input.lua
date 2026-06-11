local vars = Config.vars

hl.config({
  -- Input variables
  input = {
    kb_layout = "us",
    numlock_by_default = false,
    repeat_delay = 250,
    repeat_rate = 35,

    focus_on_close = 1,
    sensitivity = vars.touchpadSensitivity,

    touchpad = {
      natural_scroll = true,
      disable_while_typing = vars.touchpadDisableTyping,
      scroll_factor = vars.touchpadScrollFactor,
    },
  },

  -- Keybind settings
  binds = {
    scroll_event_delay = 0,
  },

  -- Cursor options
  cursor = {
    hotspot_padding = 1,
  },
})
