local HOME = os.getenv("HOME")

package.path = package.path
    .. ";" .. HOME .. "/.config/hypr/?.lua"
    .. ";" .. HOME .. "/.config/caelestia/?.lua"

local function maybe_create(path)
    local file = io.open(path, "r")

    if file then
        file:close()
        return
    end

    file = io.open(path, "w")

    if file then
        file:close()
    end
end

maybe_create(HOME .. "/.config/caelestia/hypr-vars.lua")
maybe_create(HOME .. "/.config/caelestia/hypr-user.lua")

Config = require("config")
require("hypr-vars")

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

local modules = {
    "hyprland.env",
    "hyprland.general",
    "hyprland.input",
    "hyprland.misc",
    "hyprland.animations",
    "hyprland.decoration",
    "hyprland.group",
    "hyprland.execs",
    "hyprland.rules",
    "hyprland.gestures",
    "hyprland.keybinds",
    "hyprland.scrolling",
}

for _, module in ipairs(modules) do
    require(module)
end

require("hypr-user")