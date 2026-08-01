local vars = require("variables")

-- Tags an array of window matches. If `field` is given, matches should be an
-- array of strings. Otherwise, it should be an array of tables.
local function tagged_rule(tag, matches, field)
    for _, match in ipairs(matches) do
        if field then
            local table = {}
            table[field] = match
            match = table
        end
        hl.window_rule({ match = match, tag = "+" .. tag })
    end
end

local function create_tag(tag, rules)
    local rule = { match = { tag = tag } }
    for k, v in pairs(rules) do
        rule[k] = v
    end
    hl.window_rule(rule)
end

-- All tags
local opaque_tag = "opaque"
local float_tag = "float"
local float_60_70_tag = "float_60_70"
local float_70_80_tag = "float_70_80"
local float_50_60_tag = "float_50_60"
local game_tag = "game"
local xwl_popup_tag = "xwl_popup"
local system_monitor_tag = "system_monitor"
local music_player_tag = "music_player"
local communication_app_tag = "communication_app"
local todo_app_tag = "todo_app"


----------------------
---- Window rules ----
----------------------

-- Apply default opacity to all windows except fullscreen
hl.window_rule({ match = { fullscreen = false }, opacity = vars.windowOpacity .. " override" })

-- Center all floating windows except xwayland windows (xwayland popups count as windows)
hl.window_rule({ match = { float = true, xwayland = false }, center = true })

-- Picture in picture (move and resize done via resizer in execs.lua)
hl.window_rule({
    match             = { title = "Picture(-| )in(-| )[Pp]icture" },
    move              = "(monitor_w*0.98-window_w) (monitor_h*0.97-window_h)", -- Initial move so window doesn't jump so much
    pin               = true,
    float             = true,
    keep_aspect_ratio = true,
})


----------------------
---- Tagged rules ----
----------------------

-- Opaque apps
tagged_rule(opaque_tag, {
    "foot",                          -- Terminal
    "equibop",                       -- Discord client
    "org.quickshell",                -- Quickshell
    "feh|imv|swappy",                -- Image viewers
    "krita|gimp|inkscape|darktable", -- Image editors
    "resolve|kdenlive|shotcut",      -- Video editors
    "blender|godot",                 -- 3D editors
}, "class")


-- Floating apps
tagged_rule(float_tag, {
    "guifetch",                           -- System info
    "yad|zenity",                         -- Dialogs
    "wev",                                -- Input detector
    "org.gnome.FileRoller|file-roller",   -- Archive manager
    "blueman-manager",                    -- Bluetooth GUI
    "com.github.GradienceTeam.Gradience", -- GTK themer (deprecated)
    "feh|imv|swappy",                     -- Image viewers
    "org.quickshell",                     -- Quickshell
}, "class")
tagged_rule(float_tag, {
    "File (Operation|Upload)( Progress)?", -- File manager operation progress (upload, move, copy, etc)
    ".* Properties",                       -- File properties
}, "title")


-- Sized floaters
-- 60% x 70%
tagged_rule(float_60_70_tag, {
    "(Select|Open)( a)? (File|Folder)(s)?", -- File dialogs
    "Save As",                              -- Save dialogs
    "Library",                              -- * I don't remember what this matches...
}, "title")
tagged_rule(float_60_70_tag, {
    { title = "(Save|Export) Image", class = "gimp" }, -- GIMP export/save
})
tagged_rule(float_60_70_tag, {
    "org.pulseaudio.pavucontrol|com.saivert.pwvucontrol", -- Audio control
    "yad-icon-browser",                                   -- GTK icon browser
}, "class")

-- 70% x 80%
tagged_rule(float_70_80_tag, {
    "org.gnome.Settings", -- System settings
}, "class")

-- 50% x 60%
tagged_rule(float_50_60_tag, {
    "nwg-look",              -- GTK theme manager
    "system-config-printer", -- Printer config
}, "class")


-- Games
tagged_rule(game_tag, {
    "steam_app_[0-9]+",  -- Steam games
    "steam_app_default", -- Lutris games
    "gamescope",         -- Gamescope
}, "class")


-- Xwayland popups
tagged_rule(xwl_popup_tag, {
    { xwayland = true, title = "win[0-9]+" },
    { xwayland = true, title = "",         class = "", initial_title = "", initial_class = "" }
})


-- Special workspaces
tagged_rule(system_monitor_tag, { "btop" }, "class")
tagged_rule(music_player_tag, {
    "feishin|Supersonic|Plexamp",                                  -- Self hosted
    "Spotify",                                                     -- Spotify
    "Cider",                                                       -- Apple music
    "com.github.th-ch.youtube-music|com-maxrave-simpmusic-MainKt", -- YouTube music
}, "class")
tagged_rule(music_player_tag, {
    "Spotify|Spotify Free" -- Spotify wayland, it has no class for some reason
}, "initial_title")
tagged_rule(communication_app_tag, {
    "discord|equibop|vesktop", -- Discord clients
    "whatsapp"                 -- Whatsapp
}, "class")
tagged_rule(todo_app_tag, {
    "todoist" -- Todoist
}, "class")


-----------------------
---- Per app rules ----
-----------------------

-- Steam
tagged_rule(float_tag, { { class = "steam", title = "Friends List" } })
tagged_rule(xwl_popup_tag, { { class = "steam", title = "" } })

-- Ueberzugpp
hl.window_rule({ match = { class = "ueberzugpp_.*" }, float = true, no_initial_focus = true })

-- Autodesk Fusion 360
hl.window_rule({ match = { class = "fusion360.exe", title = "Fusion360|(Marking Menu)" }, no_blur = true })

-- Minecraft launcher consoles
tagged_rule(float_tag, {
    { class = "com-atlauncher-App", title = "ATLauncher Console" },
    { class = "PandoraLauncher",    title = "Minecraft Game Output" },
})


-------------------------
---- Tag definitions ----
-------------------------
-- These have to come after all uses of window tagging. Thank you Hyprland...

create_tag(opaque_tag, { opaque = true })
create_tag(float_tag, { float = true })
create_tag(float_50_60_tag, { float = true, size = "(monitor_w*0.5) (monitor_h*0.6)", center = true })
create_tag(float_60_70_tag, { float = true, size = "(monitor_w*0.6) (monitor_h*0.7)", center = true })
create_tag(float_70_80_tag, { float = true, size = "(monitor_w*0.7) (monitor_h*0.8)", center = true })
create_tag(game_tag, { opaque = true, immediate = true, idle_inhibit = "always" })
create_tag(xwl_popup_tag, {
    no_dim = true,
    no_shadow = true,
    no_blur = true,
    opaque = true,
    rounding = math.min(10, vars.windowRounding), -- Popups are usually small, so we want to limit the rounding
})
create_tag(system_monitor_tag, { workspace = "special:sysmon" })
create_tag(music_player_tag, { workspace = "special:music" })
create_tag(communication_app_tag, { workspace = "special:communication" })
create_tag(todo_app_tag, { workspace = "special:todo" })


-------------------------
---- Workspace rules ----
-------------------------

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = vars.singleWindowGapsOut })


---------------------
---- Layer rules ----
---------------------

hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })                 -- Colour picker out animation
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })              -- wlogout
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })                  -- slurp
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" })                  -- wayfreeze
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%", blur = true }) -- Fuzzel

-- Shell
hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)" }, animation = "fade" })
