local HOME = os.getenv("HOME")

Config = require("config")
hl.dispatch(hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/configs.fish " .. os.getenv("HOME") .. "/.config/caelestia"))
hl.monitor({
    output  = "eDP-1",
    mode    = "19020x1080@60",
    position= "0x0",
    scale   = "1"
})

hl.config({
    animations = {
        enabled = true
    }
})


require("hyprland.env")
require("hyprland.general")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.animations")
require("hyprland.decoration")
require("hyprland.group")
require("hyprland.execs")
require("hyprland.rules")
require("hyprland.gestures")
require("hyprland.keybinds")
require("hyprland.scorlling")