local vars = Config.vars
local computed = Config.computed
hl.config({
  decoration = {
    rounding = vars.windowRounding,

    blur = {
      enabled = vars.blurEnabled,
      xray = vars.blurXray,
      special = vars.blurSpecialWs,
      ignore_opacity = vars.ignoreOpacity,
      new_optimizations = vars.newOptimizations,
      popups = vars.blurPopups,
      input_methods = vars.blurInputMethods,
      size = vars.blurSize,
      passes = vars.blurPasses,
    },

    shadow = {
      enabled = vars.shadowEnabled,
      range = vars.shadowRange,
      render_power = vars.shadowRenderPower,
      color = computed.shadowColour,
    },
  }
})
