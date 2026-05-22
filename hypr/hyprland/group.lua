local scheme = require("scheme.current")
local vars = require("variables")
hl.config({
	group = {
		col = {
			border_active = vars.activeWindowBorderColour,
			border_inactive = vars.inactiveWindowBorderColour,
			border_locked_active = vars.activeWindowBorderColour,
			border_locked_inactive = vars.inactiveWindowBorderColour,
		},
		groupbar = {
			font_family = "JetBrains Mono NF",
			font_size = 15,
			gradients = true,
			gradient_round_only_edges = false,
			gradient_rounding = 5,
			height = 25,
			indicator_height = 0,
			gaps_in = 3,
			gaps_out = 3,
			text_color = "rgb(" .. scheme.onPrimary .. ")",
			col = {
				active = "rgba(" .. scheme.primary .. "d4)",
				inactive = "rgba(" .. scheme.outline .. "d4)",
				locked_active = "rgba(" .. scheme.primary .. "d4)",
				locked_inactive = "rgba(" .. scheme.secondary .. "d4)",
			},
		},
	},
})
