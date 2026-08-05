local vars = require("variables")
local fn   = require("utils.functions")

-- Cursors 
local function apply_cursors()
    package.loaded["variables"] = nil
    package.loaded["hypr-vars"] = nil
    
    local current_vars = require("variables")
    
    local ok, overrides = pcall(require, "hypr-vars")
    if ok and type(overrides) == "table" then
        for k, v in pairs(overrides) do
            current_vars[k] = v
        end
    end

    local theme = string.gsub(tostring(current_vars.cursorTheme), "['\"\n\r%s]", "")
    local size = string.gsub(tostring(current_vars.cursorSize), "['\"\n\r%s]", "")

    local shell_cmd = string.format([[
        touch ~/.Xresources
        sed -i '/^Xcursor\./d' ~/.Xresources
        printf 'Xcursor.theme: %s\nXcursor.size: %s\n' >> ~/.Xresources
        xrdb -merge ~/.Xresources 2>/dev/null
        
        for gtk in ~/.config/gtk-3.0 ~/.config/gtk-4.0; do
            mkdir -p "$gtk"
            touch "$gtk/settings.ini"
            grep -q '\[Settings\]' "$gtk/settings.ini" || echo '[Settings]' >> "$gtk/settings.ini"
            sed -i '/^gtk-cursor-theme-/d' "$gtk/settings.ini"
            sed -i '/\[Settings\]/a gtk-cursor-theme-name=%s\ngtk-cursor-theme-size=%s' "$gtk/settings.ini"
        done
    ]], theme, size, theme, size)
    
    os.execute(shell_cmd)

    hl.exec_cmd("hyprctl setcursor '" .. theme .. "' " .. size)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. theme .. "'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. size)
    
    hl.exec_cmd(string.format(
        "mkdir -p ~/.local/share/icons/default && printf '[Icon Theme]\\nName=Default\\nComment=Default Cursor Theme\\nInherits=%s\\n' > ~/.local/share/icons/default/index.theme",
        theme
    ))
end

apply_cursors()

hl.on("hyprland.start", function()
    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Location provider and night light
    hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
    hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Start shell
    hl.exec_cmd("caelestia shell -d")
end)

-- Resizer listeners
local function apply_resizer_rules(win)
    local float_center = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
    local pip_actions = fn.move_actions(win) or {}

    -- Bitwarden
    fn.resizer(win, "Bitwarden", 20, 54, float_center, true, "class")                                       -- Native app
    fn.resizer(win, "^Extension: %(Bitwarden Password Manager%) %- Bitwarden", 20, 54, float_center, false) -- Firefox
    fn.resizer(win, "nngceckbapebfimnlniiiahkandclblb", 20, 54, float_center, true, "class")                -- Chromium

    -- Picture in picture
    fn.resizer(win, "Picture[- ]in[- ][Pp]icture", 0, 0, pip_actions, false)
end

hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)
