local vars = Config.vars

--------------------------------------------------------------------------------
-- 1. Appearance Rules
--------------------------------------------------------------------------------

-- General window opacity for non-fullscreen windows
hl.window_rule({
  name = "general-opacity",
  match = { fullscreen = false },
  opacity = vars.windowOpacity
})

-- Opaque applications (apps that handle their own transparency or need clarity)
local opaque_apps = { "foot", "equibop", "org\\.quickshell", "imv", "swappy" }
hl.window_rule({
  name = "opaque-apps",
  match = { class = table.concat(opaque_apps, "|") },
  opaque = true
})

-- Creative & Industry software (Always opaque)
local creative_apps = { 
  "krita", "gimp", "inkscape", "darktable", "resolve", 
  "kdenlive", "shotcut", "blender", "godot" 
}
hl.window_rule({
  name = "creative-apps-opaque",
  match = { class = table.concat(creative_apps, "|") },
  opaque = true
})

--------------------------------------------------------------------------------
-- 2. Floating and Geometry Rules
--------------------------------------------------------------------------------

-- Center all floating windows (excluding XWayland popups)
hl.window_rule({
  name = "center-floating",
  match = { float = true , xwayland = false },
  center = true
})

-- Applications that should always float
local floating_classes = {
  "guifetch", "yad", "zenity", "wev", "org\\.gnome\\.FileRoller", 
  "file-roller", "blueman-manager", "com\\.github\\.GradienceTeam\\.Gradience", 
  "feh", "imv", "system-config-printer", "org\\.quickshell"
}
hl.window_rule({
  name = "default-floating",
  match = { class = table.concat(floating_classes, "|") },
  float = true
})

-- Specific Float, Resize, and Center rules
local geometry_rules = {
  { match = { class = "foot", title = "nmtui" }, size = "60% 70%" },
  { match = { class = "org\\.gnome\\.Settings" }, size = "70% 80%" },
  { match = { class = "nwg-look" }, size = "50% 60%" },
  { match = { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" } }
}

for _, rule in ipairs(geometry_rules) do
  hl.window_rule({
    match = rule.match,
    float = true,
    center = true,
    size = rule.size
  })
end

--------------------------------------------------------------------------------
-- 3. Workspace Assignments
--------------------------------------------------------------------------------

-- Special Workspaces
local workspace_assignments = {
  { match = { class = "btop" }, workspace = "special:sysmon" },
  { match = { class = "discord|equibop|vesktop|whatsapp" }, workspace = "special:communication" },
  { match = { class = "Todoist" }, workspace = "special:todo" },
  { 
    match = { class = "feishin|Spotify|Supersonic|Cider|io.bassi.Amberol|com.github.th_ch.youtube_music|Plexamp|com-maxrave-simpmusic-MainKt" }, 
    workspace = "special:music" 
  },
  { match = { initial_title = "Spotify( Free)?" }, workspace = "special:music" }
}

for _, rule in ipairs(workspace_assignments) do
  hl.window_rule(rule)
end

--------------------------------------------------------------------------------
-- 4. Utility and System Rules
--------------------------------------------------------------------------------

-- Common Dialogs
local dialog_titles = {
  "(Select|Open)( a)? (File|Folder)(s)?", "File (Operation|Upload)( Progress)?",
  ".* Properties", "Export Image as PNG", "GIMP Crash Debug", "Save As", "Library"
}
hl.window_rule({
  name = "system-dialogs",
  match = { title = table.concat(dialog_titles, "|") },
  float = true
})

-- Picture in Picture (PiP)
hl.window_rule({
  name = "pip-window",
  match = { title = "Picture(-| )in(-| )[Pp]icture" },
  move = "100%-w-2% 100%-w-3%",
  keep_aspect_ratio = true,
  float = true,
  pin = true
}) 

-- Ueberzugpp (Image previews in terminal)
hl.window_rule({ 
  match = { class = "^(ueberzugpp_.*)$" }, 
  float = true, 
  no_initial_focus = true 
})

-- Xwayland popups fix
hl.window_rule({
  name = "xwayland-popups",
  match = { xwayland = true, title = "win[0-9]+" },
  no_dim = true,
  no_shadow = true,
  rounding = 10
})

--------------------------------------------------------------------------------
-- 5. Gaming Rules
--------------------------------------------------------------------------------

-- Steam
hl.window_rule({ match = { class = "steam" }, rounding = 10 })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, float = true })

-- Games (Steam, Lutris/Wine, Gamescope)
hl.window_rule({
  name = "games-performance",
  match = { class = "(steam_app_(default|[0-9]+))|gamescope" },
  opaque = true,
  immediate = true,
  idle_inhibit = "always"
})

-- Minecraft launcher consoles
hl.window_rule({ match = { class = "com-atlauncher-App", title = "ATLauncher Console" }, float = true })
hl.window_rule({ match = { class = "PandoraLauncher", title = "Minecraft Game Output" }, float = true })

-- Autodesk Fusion 360
hl.window_rule({ 
  match = { class = "fusion360\\.exe", title = "Fusion360|(Marking Menu)" }, 
  no_blur = true
})

--------------------------------------------------------------------------------
-- 6. Workspace Layout Rules
--------------------------------------------------------------------------------

-- "Smart Gaps" (Remove gaps when only one tiled window is visible)
-- w[tv1] = 1 visible tiled window, s[false] = not special workspace
hl.workspace_rule({ 
  workspace = "w[tv1]s[false]", 
  gaps_out = vars.singleWindowGapsOut 
})

hl.workspace_rule({ 
  workspace = "f[1]s[false]", 
  gaps_out = vars.singleWindowGapsOut 
})

--------------------------------------------------------------------------------
-- 7. Layer Rules
--------------------------------------------------------------------------------

-- Simple fade layers 
local fade_layers = { "hyprpicker", "logout_dialog", "selection", "wayfreeze", "caelestia-background" }
for _, namespace in ipairs(fade_layers) do
  hl.layer_rule({ match = { namespace = namespace }, animation = "fade" })
end

-- Fuzzel Launcher
hl.layer_rule({ 
  match = { namespace = "launcher" }, 
  animation = "popin 80%", 
  blur = true 
})

-- Caelestia Shell components
hl.layer_rule({ match = { namespace = "caelestia-area-picker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-border-exclusion" }, no_anim = true })
hl.layer_rule({ 
  match = { namespace = "caelestia-drawers" }, 
  animation = "fade", 
  blur = true, 
  ignore_alpha = vars.ignoreAlpha 
})
