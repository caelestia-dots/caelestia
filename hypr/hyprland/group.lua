-- Call the hl.config function with your configuration table
hl.config({
    group = {

        ["col.border_active"] = Config.computed.activeWindowBorderColour,
        ["col.border_inactive"]          = Config.computed.inactiveWindowBorderColour,
        ["col.border_locked_active"]     = Config.computed.activeWindowBorderColour,
        ["col.border_locked_inactive"]   = Config.computed.inactiveWindowBorderColour,
        groupbar = {
            font_family                  = "JetBrains Mono NF",
            font_size                    = 15,
            gradients                    = true,
            gradient_round_only_edges    = false,
            gradient_rounding            = 5,
            height                       = 25,
            indicator_height             = 0,
            gaps_in                      = 3,
            gaps_out                     = 3,


            text_color                   = "0xff" .. Config.colors.onPrimary,
            
            ["col.active"]               = Config.computed.primaryd4,
            ["col.inactive"]             = Config.computed.outlined4,
            ["col.locked_active"]        = Config.computed.primaryd4,
            ["col.locked_inactive"]      = Config.computed.secondaryd4,
        }
    }
})
