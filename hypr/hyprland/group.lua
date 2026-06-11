local colors = Config.colors
local computed = Config.computed

-- Call the hl.config function with your configuration table
hl.config({
    group = {

        ["col.border_active"] = computed.activeWindowBorderColour,
        ["col.border_inactive"]          = computed.inactiveWindowBorderColour,
        ["col.border_locked_active"]     = computed.activeWindowBorderColour,
        ["col.border_locked_inactive"]   = computed.inactiveWindowBorderColour,
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


            text_color                   = "0xff" .. colors.onPrimary,
            
            ["col.active"]               = computed.primaryd4,
            ["col.inactive"]             = computed.outlined4,
            ["col.locked_active"]        = computed.primaryd4,
            ["col.locked_inactive"]      = computed.secondaryd4,
        }
    }
})
