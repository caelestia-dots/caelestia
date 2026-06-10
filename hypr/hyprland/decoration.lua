hl.config({
  decoration = {
    rounding = Config.vars.windowRounding,

    blur = {
      enabled = Config.vars.blurEnabled,
      xray = Config.vars.blurXray,
      special = Config.vars.blurSpecialWs,
      ignore_opacity = Config.vars.ignoreOpacityq,
      new_optimizations = Config.vars.newOptimizations,
      popups = Config.vars.blurPopups,
      input_methods = Config.vars.blurInputMethods,
      size = Config.vars.blurSize,
      passes = Config.vars.blurPasses,
    },

    shadow = {
      enabled = Config.vars.shadowEnabled,
      range = Config.vars.shadowRange,
      render_power = Config.vars.shadowRenderPower,
      color = Config.vars.shadowColour,
    },
  }
})
