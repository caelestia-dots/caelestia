local keybinds = Config.keybinds
local vars = Config.vars
-- Launcher
hl.bind("SUPER + SUPER_L", hl.dsp.global("caelestia:launcher"), { release = true })
-- Mouse interrupts
hl.bind("SUPER + mouse:272", hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
hl.bind("SUPER + mouse:273", hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
hl.bind("SUPER + mouse:274", hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
hl.bind("SUPER + mouse:275", hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
hl.bind("SUPER + mouse:276", hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
hl.bind("SUPER + mouse:277", hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
hl.bind("SUPER + mouse_up",  hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
hl.bind("SUPER + mouse_down",hl.dsp.global("caelestia:launcherInterrupt"), { release = true })
-- Session menu (Power off, Logout, Reboot, Lock)
hl.bind( keybinds.kbSession, hl.dsp.global("caelestia:session"))

-- Sidebar toggle
hl.bind( keybinds.kbShowSidebar, hl.dsp.global("caelestia:sidebar"))

-- Clear all notifications
hl.bind( keybinds.kbClearNotifs, hl.dsp.global("caelestia:clearNotifs"), { locked = true })  -- Works while screen is locked

-- Show all panels
hl.bind( keybinds.kbShowPanels, hl.dsp.global("caelestia:showall"))

-- Lock screen
hl.bind( keybinds.kbLock, hl.dsp.global("caelestia:lock"), { locked = true } )

-- Unlocks screen and returns to shell
hl.bind( keybinds.kbRestoreLock,
    function()
        hl.dispatch(hl.dsp.exec_cmd("caelestia shell -d"))
        hl.dispatch(hl.dsp.global("caelestia:lock"))
    end,
    { locked = true }
)

-- Toggle night mode 
hl.bind( keybinds.toggleNightMode, hl.dsp.exec_cmd("~/.config/hypr/scripts/gammastep-toggle.sh"))

-- Increase brightness
hl.bind( "XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true, repeating = true } )

-- Decrease brightness
hl.bind( "XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true, repeating = true } )

-- Play/Pause (both Ctrl+Super+Space and XF86 key)
hl.bind( keybinds.kbMediaToggle, hl.dsp.global("caelestia:mediaToggle"), { locked = true } )
hl.bind( "XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind( "XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })

-- Next track (both Ctrl+Super+Equal and XF86 key)
hl.bind( keybinds.kbMediaNext, hl.dsp.global("caelestia:mediaNext"), { locked = true, repeating = true })
hl.bind( "XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true, repeating = true } )

-- Previous track (both Ctrl+Super+Minus and XF86 key)
hl.bind( keybinds.kbMediaPrev, hl.dsp.global("caelestia:mediaPrev"), { locked = true, repeating = true } )
hl.bind( "XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true, repeating = true } )

-- Stop media playback
hl.bind( "XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true } )

-- Kill shell (triggers on key release)
hl.bind( keybinds.kbKill, hl.dsp.exec_cmd("qs -c caelestia kill"), { release = true })

-- Restart shell (with small delay to ensure clean shutdown)
hl.bind( keybinds.kbRestart, hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"), { release = true } )

-- Navigate to workspace 1-10 by number
for i = 1, 9 do
    hl.bind( keybinds.kbGoToWs .. " + " .. i, hl.dsp.focus({ workspace = i }))
end

-- Workspace 0 maps to workspace 10
hl.bind( keybinds.kbGoToWs .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Navigate to workspaces in groups of 10
local function gotoWorkspaceGroup(group)
    local ws = tonumber(hl.get_active_workspace().id)
    local pos = ws % 10
    if pos == 0 then
        pos = 10
    end
    local target = (group - 1) * 10 + pos
    hl.dispatch(hl.dsp.focus({ workspace = target }))
end

for i = 1, 9 do
    hl.bind( keybinds.kbGoToWsGroup .. " + " .. i,
        function()
            gotoWorkspaceGroup(i)
        end
    )
end

hl.bind(
    keybinds.kbGoToWsGroup .. " + 0",
    function()
        gotoWorkspaceGroup(10)
    end
)


-- Mouse scrolling with Super key changes workspaces
hl.bind( keybinds.kbWorkspacePrevMouse, hl.dsp.focus({ workspace = "r-1" }))  -- r-1 = relative -1
hl.bind( keybinds.kbWorkspaceNextMouse, hl.dsp.focus({ workspace = "r+1" }))  -- r+1 = relative +1

-- Navigate to previous/next workspace
hl.bind( keybinds.kbPrevWs, hl.dsp.focus({ workspace = "r-1" }))
hl.bind( keybinds.kbNextWs, hl.dsp.focus({ workspace = "r+1" }))

-- Page Up/Down for additional workspace navigation
hl.bind( keybinds.kbWorkspacePrevPage, hl.dsp.focus({ workspace = "r-1" }))
hl.bind(keybinds.kbWorkspaceNextPage, hl.dsp.focus({ workspace = "r+1" }))

-- Jump between workspace groups using mouse scroll with Ctrl+Super
hl.bind( keybinds.kbWorkspaceGroupPrev, hl.dsp.focus({ workspace = "r-10" }))
hl.bind( keybinds.kbWorkspaceGroupNext, hl.dsp.focus({ workspace = "r+10" }))

-- Show/hide the special workspace (useful for scratchpad-like windows)
hl.bind( keybinds.kbToggleSpecialWs, hl.dsp.workspace.toggle_special("special"))

-- Move focused window to workspace 1-10
for i = 1, 9 do
    hl.bind( keybinds.kbMoveWinToWs .. " + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind( keybinds.kbMoveWinToWs .. " + 0", hl.dsp.window.move({ workspace = 10 }))

-- Move window to same position in different workspace group
local function moveWindowToWorkspaceGroup(group)
    local ws = tonumber(hl.get_active_workspace().id)
    local pos = ws % 10
    if pos == 0 then
        pos = 10
    end
    local target = (group - 1) * 10 + pos
    hl.dispatch( hl.dsp.window.move({ workspace = target }))
end

for i = 1, 9 do
    hl.bind(
        keybinds.kbMoveWinToWsGroup .. " + " .. i,
        function()
            moveWindowToWorkspaceGroup(i)
        end
    )
end

hl.bind(
    keybinds.kbMoveWinToWsGroup .. " + 0",
    function()
        moveWindowToWorkspaceGroup(10)
    end
)

-- Move window to previous/next workspace
hl.bind( keybinds.kbMoveWindowPrevWorkspace, hl.dsp.window.move({ workspace = "r-1" }))
hl.bind( keybinds.kbMoveWindowNextWorkspace, hl.dsp.window.move({ workspace = "r+1" }))

-- Mouse scroll to move windows between workspaces
hl.bind( keybinds.kbMoveWindowPrevWorkspaceMouse, hl.dsp.window.move({ workspace = "r-1" }))
hl.bind( keybinds.kbMoveWindowNextWorkspaceMouse, hl.dsp.window.move({ workspace = "r+1" }))

-- Arrow keys to move windows between workspaces
hl.bind( keybinds.kbMoveWindowNext, hl.dsp.window.move({ workspace = "r+1" }))
hl.bind( keybinds.kbMoveWindowPrev, hl.dsp.window.move({ workspace = "r-1" }))

-- Move to special workspace
hl.bind( keybinds.kbMoveWindowToSpecial, hl.dsp.window.move({ workspace = "special:special" }))

-- Move from special workspace to empty workspace
hl.bind( keybinds.kbMoveWindowFromSpecial, hl.dsp.window.move({ workspace = "e+0" })) -- e+0 = first empty workspace

-- Alternative binding for moving to special workspace
hl.bind( keybinds.kbMoveWindowToSpecialAlt, hl.dsp.window.move({ workspace = "special:special" }))

-- Cycle to next window in group
hl.bind( keybinds.kbWindowGroupCycleNext, hl.dsp.window.cycle_next())

-- Cycle to previous window in group
hl.bind( keybinds.kbWindowGroupCyclePrev, hl.dsp.window.cycle_next({ previous = true }))

-- Toggle group mode
hl.bind( keybinds.kbToggleGroup, hl.dsp.group.toggle())

-- Lock/unlock active group
hl.bind( keybinds.kbLockGroup, hl.dsp.group.lock_active("toggle"))

-- Navigate between windows using arrow keys and hjkl
local directions = { left = "l", right = "r", up = "u", down = "d" }

-- Move windows with SUPER + Left Mouse Button (LMB)
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Resize windows with SUPER + Right Mouse Button (RMB)
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

for key, dir in pairs(directions) do
    -- Focus window in direction
    hl.bind( "SUPER + "         .. key, hl.dsp.focus({ direction = dir }))
    -- Move window in direction
    hl.bind( "SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end


-- Resize using Minus (-) and Equal (=) keys
hl.bind(keybinds.kbResizeWidthDec, hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(keybinds.kbResizeWidthInc, hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })

hl.bind(keybinds.kbResizeHeightDec, hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(keybinds.kbResizeHeightInc, hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

-- Resize using Arrow Keys
hl.bind(keybinds.kbResizeLeft,  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(keybinds.kbResizeRight, hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(keybinds.kbResizeUp,    hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(keybinds.kbResizeDown,  hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

-- Pin window (keep on all workspaces)
hl.bind(
    keybinds.kbPinWindow, function ()
        hl.dispatch(hl.dsp.window.pin())   
    end           
)

-- Fullscreen (seamless, no borders, no bars)
hl.bind( keybinds.kbWindowFullscreen,hl.dsp.window.fullscreen({ mode = 0, action = "toggle" }))

-- Fullscreen with borders/gaps (Maximized)
hl.bind( keybinds.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = 1, action = "toggle" }))

-- Toggle floating/tiled mode
hl.bind( keybinds.kbToggleWindowFloating, hl.dsp.window.float({ action = "toggle" }))

-- Close window
hl.bind( keybinds.kbCloseWindow, hl.dsp.window.close())

-- Float and Center a window 
hl.bind( keybinds.kbCenterWindow, 
    function()
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        hl.dispatch(hl.dsp.window.center())
    end
)

-- Picture-in-picture mode
hl.bind( keybinds.kbWindowPip, hl.dsp.exec_cmd("caelestia resizer pip"))  -- NOT TESTED

-- Toggle system monitor workspace
hl.bind(keybinds.kbSystemMonitor, function()
    if #hl.get_windows({ class = "btop" }) == 0 then 
        hl.exec_cmd("kitty --class btop -e btop") 
    else
        hl.dispatch(hl.dsp.workspace.toggle_special("sysmon"))
    end
end)

-- Toggle music player workspace
hl.bind( keybinds.kbMusic, function ()
        hl.dispatch(hl.dsp.workspace.toggle_special("music")) 
    end
)

-- Toggle communication apps workspace
hl.bind( keybinds.kbCommunication, function()
        hl.dispatch(hl.dsp.workspace.toggle_special("communication"))
    end
)

-- Toggle todo/task manager workspace
hl.bind( keybinds.kbTodo, function()
        hl.dispatch(hl.dsp.workspace.toggle_special("todo"))
    end
)

-- Terminal
hl.bind( keybinds.kbTerminal, hl.dsp.exec_cmd("app2unit -- " .. vars.terminal))

-- Browser
hl.bind( keybinds.kbBrowser, hl.dsp.exec_cmd("app2unit -- " .. vars.browser))

-- Editor
hl.bind( keybinds.kbEditor, hl.dsp.exec_cmd("app2unit -- " .. vars.editor))

-- File manager
hl.bind(keybinds.kbFileExplorer, hl.dsp.exec_cmd("app2unit -- " .. vars.fileExplorer))

-- Additional apps
hl.bind(keybinds.kbGithubDesktop, hl.dsp.exec_cmd("app2unit -- github-desktop"))
hl.bind(keybinds.kbNemo, hl.dsp.exec_cmd("app2unit -- nemo"))
hl.bind(keybinds.kbQps, hl.dsp.exec_cmd("app2unit -- qps"))
hl.bind(keybinds.kbPavucontrol, hl.dsp.exec_cmd("app2unit -- pavucontrol"))

-- Full screen screenshot to clipboard
hl.bind( keybinds.kbScreenshotFull, hl.dsp.exec_cmd("caelestia screenshot"), { locked = true })

-- Capture region (with freeze)
hl.bind( keybinds.kbScreenshotFreeze, hl.dsp.global("caelestia:screenshotFreeze"))

-- Capture region (without freeze)
hl.bind( keybinds.kbScreenshotRegion, hl.dsp.global("caelestia:screenshot"))

-- Record screen with audio
hl.bind( keybinds.kbScreenRecordAudio, hl.dsp.exec_cmd("caelestia record -s"))  -- RECORDING NOT WORKING PROPERLY

-- Record screen without audio
hl.bind( keybinds.kbScreenRecordNoAudio, hl.dsp.exec_cmd("caelestia record"))  -- RECORDING NOT WORKING PROPERLY

-- Record specific region
hl.bind( keybinds.kbScreenRecordRegion, hl.dsp.exec_cmd("caelestia record -r"))  -- RECORDING NOT WORKING PROPERLY

-- Color picker
hl.bind( keybinds.kbColorPicker, hl.dsp.exec_cmd("hyprpicker -a"))

-- Mute/unmute microphone
hl.bind( "XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Mute/unmute speakers
hl.bind( "XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind( keybinds.kbMuteSpeaker, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- Increase volume (enables unmute + adjusts volume with limit of 1.0)
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"),
    { locked = true, repeating = true }
)

-- Decrease volume
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"),
    { locked = true, repeating = true }
)

-- Suspend to RAM with hibernation after timeout
hl.bind( keybinds.kbSuspend, hl.dsp.exec_cmd("~/.config/hypr/scripts/suspend-toggle.sh"), { locked = true })

-- Clipboard manager
hl.bind( keybinds.kbClipboard, hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))

-- Clipboard manager (with delay)
hl.bind( keybinds.kbClipboardDelayed, hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))

-- Emoji picker
hl.bind( keybinds.kbEmojiPicker, hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

-- Alternative paste from clipboard history
hl.bind( keybinds.kbClipboardPasteLatest, hl.dsp.exec_cmd('sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'), { locked = true })

-- Test notification with multiple actions
hl.bind( 
    keybinds.kbTestNotification,
    hl.dsp.exec_cmd('notify-send -u low -i dialog-information-symbolic "Test notification" "Here\'s a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!" -a "Shell" -A "Test1=I got it!" -A "Test2=Another action"'),
    { locked = true }
)