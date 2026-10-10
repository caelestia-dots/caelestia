local vars = require("variables")
local fn   = require("utils.functions")

hl.on("hyprland.start", function()
    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("polkit-gnome-authentication-agent-1 || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Location provider and night light
    hl.exec_cmd("geoclue-demo-agent || /usr/lib/geoclue-2.0/demos/agent || /usr/libexec/geoclue-2.0/demos/agent")
    hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Start shell
    hl.exec_cmd("caelestia shell -d")
end)

-- Resizer listeners
local function apply_resizer_rules(win)
    local match_str = function(pattern, field, exact)
        return function(w)
            return w[field] and string.find(w[field], pattern, 1, exact)
        end
    end
    local match_title = function(pattern, exact) return match_str(pattern, "title", exact) end
    local match_class = function(pattern, exact) return match_str(pattern, "class", exact) end

    local match_tag = function(tag)
        return function(w)
            for _, t in ipairs(w.tags) do
                if t == tag or t == tag .. "*" then
                    return true
                end
            end
            return false
        end
    end

    local float_center = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
    local pip_actions = fn.move_actions(win) or {}

    -- Bitwarden
    fn.resizer(win, match_class("Bitwarden", true), 20, 54, float_center)                                                -- Native app
    fn.resizer(win, match_title("^Extension: %(Bitwarden Password Manager%) %- Bitwarden", false), 20, 54, float_center) -- Firefox
    fn.resizer(win, match_class("nngceckbapebfimnlniiiahkandclblb", true), 20, 54, float_center)                         -- Chromium

    -- Picture in picture
    fn.resizer(win, match_title("Picture[- ]in[- ][Pp]icture", false), 0, 0, pip_actions)

    -- Tags, because window rules are unreliable
    fn.resizer(win, match_tag("float_60_70"), 60, 70, float_center)
    fn.resizer(win, match_tag("float_70_80"), 70, 80, float_center)
    fn.resizer(win, match_tag("float_50_60"), 50, 60, float_center)
end

hl.on("window.class", apply_resizer_rules)
hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)


-- Tag shenanigans, there is no way to only detect when a window's tags change
local lastTags = {}

local function tag_key(tags)
    local copy = {}
    for _, tag in ipairs(tags) do
        copy[#copy + 1] = tag:gsub("%*$", "")
    end
    table.sort(copy)
    return table.concat(copy, "\0")
end

hl.on("window.update_rules", function(win)
    local id = win.stable_id
    local key = tag_key(win.tags)
    if lastTags[id] == key then
        return
    end
    lastTags[id] = key
    apply_resizer_rules(win)
end)

hl.on("window.close", function(win)
    lastTags[win.stable_id] = nil
end)
