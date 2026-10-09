local vars = require("variables")
local fn   = require("utils.functions")


-- Flags
local locked           = { locked = true }
local mouse            = { mouse = true }
local release          = { release = true }
local repeating        = { repeating = true }
local locked_repeating = { locked = true, repeating = true }

local function normalise_keybind(key)
    return key:gsub("%s+", ""):lower()
end

local function valid_keybind(key)
    return type(key) == "string" and key:match("%S") ~= nil
end

local function repeating_unless_mouse(key)
    return not normalise_keybind(key):find("mouse", 1, true) and repeating or nil
end

local function flatten_keybinds(keybinds, keys)
    keys = keys or {}

    if type(keybinds) == "table" then
        for _, keybind in pairs(keybinds) do
            flatten_keybinds(keybind, keys)
        end
    elseif valid_keybind(keybinds) then
        keys[#keys + 1] = keybinds
    end

    return keys
end

local function create_bind(keybinds, action, description, flags)
    local get_flags = type(flags) == "function" and flags or function()
        return flags
    end

    for _, key in ipairs(flatten_keybinds(keybinds)) do
        local base_flags = get_flags(key) or {}

        -- Shallow copy so we never mutate a shared flags table (locked, mouse, etc.)
        local bind_flags = {}
        for k, v in pairs(base_flags) do
            bind_flags[k] = v
        end

        if description then
            bind_flags.description = description
        end

        hl.bind(key, action, bind_flags)
    end
end

local function extend_keybind(base, suffix)
    return valid_keybind(base) and base .. " + " .. suffix or nil
end

-- Launcher
local launcher_default = normalise_keybind("SUPER + SUPER_L")
create_bind(
    vars.kbLauncher,
    hl.dsp.global("caelestia:launcher"),
    "Shell: Open the launcher",
    function(key)
        return normalise_keybind(key) == launcher_default and release or nil
    end
)

-- Misc
create_bind(vars.kbSession, hl.dsp.global("caelestia:session"), "Shell: Open the session controls")
create_bind(vars.kbShowSidebar, hl.dsp.global("caelestia:sidebar"), "Shell: Show the sidebar")
create_bind(vars.kbClearNotifs, hl.dsp.global("caelestia:clearNotifs"), "Shell: Clear all notifications", locked)
create_bind(vars.kbShowPanels, hl.dsp.global("caelestia:showall"), "Shell: Show all panels")
create_bind(vars.kbLock, hl.dsp.global("caelestia:lock"), "Shell: Lock the screen")

-- Restore lock
create_bind(vars.kbRestoreLock, function()
    hl.dispatch(hl.dsp.exec_cmd("caelestia shell -d"))
    hl.dispatch(hl.dsp.global("caelestia:lock"))
end,
    "Shell: Restore the shell and lock the screen"
)

-- Kill/restart
create_bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"), "Shell: Kill the running shell", release)
create_bind(
    "CTRL + SUPER + ALT + R",
    hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"),
    "Shell: Restart the shell",
    release
)

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    create_bind(extend_keybind(vars.kbGoToWs, key), fn.wsaction("focus", "", i), "Workspaces: Go to workspace " .. i)
    create_bind(extend_keybind(vars.kbMoveWinToWs, key), fn.wsaction("move", "", i), "Workspaces: Move the window to workspace " .. i)
    create_bind(extend_keybind(vars.kbGoToWsGroup, key), fn.wsaction("focus", "group", i), "Workspaces: Go to workspace group " .. i)
    create_bind(extend_keybind(vars.kbMoveWinToWsGroup, key), fn.wsaction("move", "group", i), "Workspaces: Move the window to workspace group " .. i)
end

-- Go to workspace -1/+1
create_bind(vars.kbPrevWs, hl.dsp.focus({ workspace = "-1" }), "Workspaces: Go to the previous workspace", repeating_unless_mouse)
create_bind(vars.kbNextWs, hl.dsp.focus({ workspace = "+1" }), "Workspaces: Go to the next workspace", repeating_unless_mouse)

-- Go to workspace group -1/+1
create_bind(vars.kbPrevWsGroup, hl.dsp.focus({ workspace = "-10" }), "Workspaces: Go to the previous workspace group", repeating_unless_mouse)
create_bind(vars.kbNextWsGroup, hl.dsp.focus({ workspace = "+10" }), "Workspaces: Go to the next workspace group", repeating_unless_mouse)

-- Move window to workspace -1/+1
create_bind(vars.kbMoveWinToWsNext, hl.dsp.window.move({ workspace = "+1" }), "Workspaces: Move the window to the next workspace", repeating_unless_mouse)
create_bind(vars.kbMoveWinToWsPrev, hl.dsp.window.move({ workspace = "-1" }), "Workspaces: Move the window to the previous workspace", repeating_unless_mouse)

-- Move window to/from special workspace
create_bind(vars.kbMoveWinToWsSpecial, hl.dsp.window.move({ workspace = "special:special" }), "Workspaces: Move the window to the special workspace")
create_bind(vars.kbMoveWinFromWsSpecial, hl.dsp.window.move({ workspace = "e+0" }), "Workspaces: Move the window out of the special workspace")

-- Window groups
create_bind(vars.kbWindowCycleNext, hl.dsp.window.cycle_next(), "Window Groups: Cycle to the next window", repeating)
create_bind(vars.kbWindowCyclePrev, hl.dsp.window.cycle_next({ next = false }), "Window Groups: Cycle to the previous window", repeating)
create_bind(vars.kbWindowGroupCycleNext, hl.dsp.group.next(), "Window Groups: Cycle to the next window group", repeating)
create_bind(vars.kbWindowGroupCyclePrev, hl.dsp.group.prev(), "Window Groups: Cycle to the previous window group", repeating)
create_bind(vars.kbToggleGroup, hl.dsp.group.toggle(), "Window Groups: Toggle the window group")
create_bind(vars.kbUngroup, hl.dsp.window.move({ out_of_group = true }), "Window Groups: Remove the window from its group")
create_bind(vars.kbGroupLockActive, hl.dsp.group.lock_active(), "Window Groups: Lock the window group")

-- Window actions
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    create_bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }), "Window Actions: Focus the window to the " .. dir)
    create_bind("SUPER + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }), "Window Actions: Move the window to the " .. dir)
end

create_bind(vars.kbWindowDecreaseWidth, fn.resize_active_window(-10, 0), "Window Actions: Decrease the window width", repeating)
create_bind(vars.kbWindowIncreaseWidth, fn.resize_active_window(10, 0), "Window Actions: Increase the window width", repeating)
create_bind(vars.kbWindowDecreaseHeight, fn.resize_active_window(0, -10), "Window Actions: Decrease the window height", repeating)
create_bind(vars.kbWindowIncreaseHeight, fn.resize_active_window(0, 10), "Window Actions: Increase the window height", repeating)

create_bind({ vars.kbMoveWindow, "SUPER + mouse:272" }, hl.dsp.window.drag(), "Window Actions: Move the window by dragging", mouse)
create_bind({ vars.kbResizeWindow, "SUPER + mouse:273" }, hl.dsp.window.resize(), "Window Actions: Resize the window by dragging", mouse)
create_bind(vars.kbCenterWindow, hl.dsp.window.center(), "Window Actions: Center the window")
create_bind(vars.kbNormalizeWindow, function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
    hl.dispatch(hl.dsp.window.center())
end,
    "Window Actions: Resize and center the window"
)
create_bind(vars.kbWindowPip, function()
    local a = hl.get_active_window()
    if a then
        local pip = fn.move_actions(a) or {}
        if not a.floating then table.insert(pip, 1, hl.dsp.window.float()) end
        table.insert(pip, hl.dsp.window.pin({ action = "on", window = "address:" .. a.address }))

        for _, x in ipairs(pip) do
            hl.dispatch(x)
        end
    end
end,
    "Window Actions: Toggle picture-in-picture mode"
)
create_bind(vars.kbPinWindow, hl.dsp.window.pin(), "Window Actions: Pin the window")
create_bind(vars.kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Window Actions: Toggle fullscreen mode")
create_bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized" }), "Window Actions: Toggle bordered fullscreen mode")
create_bind(vars.kbToggleWindowFloating, hl.dsp.window.float(), "Window Actions: Toggle floating mode")
create_bind(vars.kbCloseWindow, hl.dsp.window.close(), "Window Actions: Close the window")

-- Special workspace toggles
create_bind(vars.kbSpecialWs, fn.toggle("specialws"), "Special Workspaces: Toggle the special workspace")
create_bind(vars.kbSystemMonitorWs, fn.toggle("sysmon"), "Special Workspaces: Toggle the system monitor workspace")
create_bind(vars.kbMusicWs, fn.toggle("music"), "Special Workspaces: Toggle the music workspace")
create_bind(vars.kbCommunicationWs, fn.toggle("communication"), "Special Workspaces: Toggle the communication workspace")
create_bind(vars.kbTodoWs, fn.toggle("todo"), "Special Workspaces: Toggle the todo workspace")

-- Apps
create_bind(vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal), "Apps: Open the terminal")
create_bind(vars.kbBrowser, hl.dsp.exec_cmd(vars.browser), "Apps: Open the web browser")
create_bind(vars.kbEditor, hl.dsp.exec_cmd(vars.editor), "Apps: Open the editor")
create_bind(vars.kbFileExplorer, hl.dsp.exec_cmd(vars.fileExplorer), "Apps: Open the file explorer")
create_bind(vars.kbAudioSettings, hl.dsp.exec_cmd(vars.audioSettings), "Apps: Open the audio settings")

-- Utilities
create_bind(vars.kbScreenshot, hl.dsp.exec_cmd("caelestia screenshot"), "Utilities: Capture a screenshot", locked)
create_bind(vars.kbScreenshotFreeze, hl.dsp.global("caelestia:screenshotFreeze"), "Utilities: Freeze the screen and capture a screenshot")
create_bind(vars.kbScreenshotRegion, hl.dsp.global("caelestia:screenshot"), "Utilities: Capture a screenshot of a selected region")
create_bind(vars.kbRecord, hl.dsp.exec_cmd("caelestia record"), "Utilities: Start a screen recording")
create_bind(vars.kbRecordSound, hl.dsp.exec_cmd("caelestia record -s"), "Utilities: Start a screen recording with audio")
create_bind(vars.kbRecordRegion, hl.dsp.exec_cmd("caelestia record -r"), "Utilities: Start a screen recording of a selected region")
create_bind(vars.kbColorPicker, hl.dsp.exec_cmd("hyprpicker -a"), "Utilities: Pick a color from the screen")

-- Brightness
create_bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), "Brightness: Increase screen brightness", locked)
create_bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), "Brightness: Decrease screen brightness", locked)

-- Media
create_bind({ vars.kbMediaToggle, "XF86AudioPlay", "XF86AudioPause" }, hl.dsp.global("caelestia:mediaToggle"), "Media: Toggle playback", locked)
create_bind({ vars.kbMediaNext, "XF86AudioNext" }, hl.dsp.global("caelestia:mediaNext"), "Media: Skip to the next track", locked)
create_bind({ vars.kbMediaPrev, "XF86AudioPrev" }, hl.dsp.global("caelestia:mediaPrev"), "Media: Go to the previous track", locked)
create_bind({ vars.kbMediaStop, "XF86AudioStop" }, hl.dsp.global("caelestia:mediaStop"), "Media: Stop playback", locked)

-- Volume
create_bind({ vars.kbVolumeMute, "XF86AudioMute" }, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), "Volume: Toggle system audio mute", locked)
create_bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), "Volume: Toggle microphone mute", locked)
create_bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " ..
        (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
    ),
    "Volume: Increase system volume",
    locked_repeating
)
create_bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"
    ),
    "Volume: Decrease system volume",
    locked_repeating
)

-- Sleep
create_bind(vars.kbSleep, hl.dsp.exec_cmd(vars.sleepGestureCmd), "Misc: Run the sleep command", locked)

-- Clipboard and emoji picker
create_bind(vars.kbClipboard, hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"), "Clipboard: Open clipboard history")
create_bind(vars.kbClipboardDel, hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"), "Clipboard: Delete an item from clipboard history")
create_bind(vars.kbEmoji, hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"), "Utilities: Open the emoji picker")
create_bind(
    vars.kbClipboardPasteLatest,
    hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'),
    "Clipboard: Paste the latest clipboard item",
    locked
)

-- Testing
create_bind(
    "SUPER + ALT + F12",
    hl.dsp.exec_cmd(
        "notify-send -u low -i dialog-information-symbolic 'Test notification' " ..
        [["Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!"]] ..
        " -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'"
    )
)

create_bind(
    vars.kbCheatsheet,
    hl.dsp.global("caelestia:cheatsheet"),
    "Shell: Open the keybind cheatsheet"
)
