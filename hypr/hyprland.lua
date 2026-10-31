local home   = os.getenv("HOME")
local hypr   = home .. "/.config/hypr"
package.path = package.path .. ";" .. home .. "/.config/caelestia/?.lua"

-- Create a file if it doesn't exist, optionally with initial content
local function maybe_create(file, content)
    local f = io.open(file)

    if f then
        f:close()
        return true
    end

    f = io.open(file, "w")
    if not f then return false end

    if content then f:write(content) end
    f:close()
    return true
end

-- Copy src to dst, but only if dst doesn't already exist
local function maybe_copy(src, dst)
    local out = io.open(dst)
    if out then
        out:close()
        return
    end

    local input = io.open(src, "r")
    if not input then return end

    out = io.open(dst, "w")
    if out then
        out:write(input:read("*a"))
        out:close()
    end
    input:close()
end

-- Maybe set current colours to defaults
maybe_copy(hypr .. "/scheme/default.lua", hypr .. "/scheme/current.lua")

-- User variables
local overrides = maybe_create(
    home .. "/.config/caelestia/hypr-vars.lua",
    "return {}\n"
) and require("hypr-vars") or {}

if type(overrides) == "table" then
    local vars = require("variables")
    for k, v in pairs(overrides) do
        vars[k] = v
    end
end

-- Default monitor conf
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Configs
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

-- User configs
if maybe_create(home .. "/.config/caelestia/hypr-user.lua") then
    require("hypr-user")
end
