-- Central shared configuration for Caelestia Hyprland
-- All modules have access to Config.colors, Config.vars, and Config.keybinds
-- without needing local imports

local Config = {}

-- Load color scheme (Material Design 3 Dark)
Config.colors = require("scheme.current")

-- Core application variables
Config.vars = {
    -- Apps
    terminal = "foot",
    browser = "firefox",
    editor = "code",
    fileExplorer = "thunar",

    -- Touchpad
    touchpadDisableTyping = true,
    touchpadScrollFactor = 0.5,
    touchpadSensitivity = 0.7,
    workspaceSwipeFingers = 4,
    gestureFingers = 3,
    gestureFingersMore = 4,

    -- Blur
    blurEnabled = true,
    blurSpecialWs = false,
    blurPopups = true,
    blurInputMethods = true,
    blurSize = 8,
    blurPasses = 2,
    blurXray = false,
    ignoreOpacity = true,
    newOptimizations = true,
    ignoreAlpha = 0.2,

    -- Shadow
    shadowEnabled = true,
    shadowRange = 20,
    shadowRenderPower = 3,
    -- Gaps
    workspaceGaps = 20,
    windowGapsIn = 5,
    windowGapsOut = 10,
    singleWindowGapsOut = 20,

    -- Window styling
    windowOpacity = 0.95,
    windowRounding = 10,
    windowBorderSize = 1,

    -- Misc
    volumeStep = 10,
    cursorTheme = "sweet-cursors",
    cursorSize = 20,
}

-- Keybind modifiers and combinations
Config.keybinds = {
    ----------------------------------------------------------------
    -- Workspace Navigation
    ----------------------------------------------------------------
    kbGoToWs = "SUPER",
    kbGoToWsGroup = "CTRL + SUPER",
    kbNextWs = "CTRL + SUPER + right",
    kbPrevWs = "CTRL + SUPER + left",
    kbToggleSpecialWs = "SUPER + S",

    kbWorkspacePrevPage = "SUPER + Page_Up",
    kbWorkspaceNextPage = "SUPER + Page_Down",

    kbWorkspacePrevMouse = "SUPER + mouse_down",
    kbWorkspaceNextMouse = "SUPER + mouse_up",

    kbWorkspaceGroupPrev = "CTRL + SUPER + mouse_down",
    kbWorkspaceGroupNext = "CTRL + SUPER + mouse_up",

    ----------------------------------------------------------------
    -- Window & Workspace Movement
    ----------------------------------------------------------------
    kbMoveWinToWs = "SUPER + ALT",
    kbMoveWinToWsGroup = "CTRL + SUPER + ALT",

    kbMoveWindowPrevWorkspace = "SUPER + ALT + Page_Up",
    kbMoveWindowNextWorkspace = "SUPER + ALT + Page_Down",

    kbMoveWindowPrevWorkspaceMouse = "SUPER + ALT + mouse_down",
    kbMoveWindowNextWorkspaceMouse = "SUPER + ALT + mouse_up",

    kbMoveWindowPrev = "CTRL + SUPER + SHIFT + left",
    kbMoveWindowNext = "CTRL + SUPER + SHIFT + right",

    kbMoveWindowToSpecial = "CTRL + SUPER + SHIFT + up",
    kbMoveWindowFromSpecial = "CTRL + SUPER + SHIFT + down",

    kbMoveWindowToSpecialAlt = "SUPER + ALT + S",

    ----------------------------------------------------------------
    -- Window Groups
    ----------------------------------------------------------------
    kbWindowGroupCycleNext = "ALT + TAB",
    kbWindowGroupCyclePrev = "SHIFT + ALT + TAB",
    kbToggleGroup = "SUPER + Comma",
    kbUngroup = "SUPER + U",
    kbLockGroup = "SUPER + SHIFT + Comma",

    ----------------------------------------------------------------
    -- Window Focus
    ----------------------------------------------------------------
    kbFocusLeft = "SUPER + left",
    kbFocusRight = "SUPER + right",
    kbFocusUp = "SUPER + up",
    kbFocusDown = "SUPER + down",

    ----------------------------------------------------------------
    -- Window Movement
    ----------------------------------------------------------------
    kbMoveLeft = "SUPER + SHIFT + left",
    kbMoveRight = "SUPER + SHIFT + right",
    kbMoveUp = "SUPER + SHIFT + up",
    kbMoveDown = "SUPER + SHIFT + down",

    ----------------------------------------------------------------
    -- Window Actions
    ----------------------------------------------------------------
    kbMoveWindow = "SUPER + Z",
    kbResizeWindow = "SUPER + X",

    kbPinWindow = "SUPER + P",
    kbCloseWindow = "SUPER + Q",

    kbWindowFullscreen = "SUPER + F",
    kbWindowBorderedFullscreen = "SUPER + ALT + F",

    kbToggleWindowFloating = "SUPER + ALT + Space",
    kbCenterWindow = "CTRL + SUPER + ALT + Backslash",
    kbWindowPip = "SUPER + ALT + Backslash",

    ----------------------------------------------------------------
    -- Window Resize
    ----------------------------------------------------------------
    kbResizeWidthDec = "SUPER + Minus",
    kbResizeWidthInc = "SUPER + Equal",

    kbResizeHeightDec = "SUPER + SHIFT + Minus",
    kbResizeHeightInc = "SUPER + SHIFT + Equal",

    kbResizeLeft = "SUPER + ALT + left",
    kbResizeRight = "SUPER + ALT + right",
    kbResizeUp = "SUPER + ALT + up",
    kbResizeDown = "SUPER + ALT + down",

    ----------------------------------------------------------------
    -- Special Workspaces
    ----------------------------------------------------------------
    kbSystemMonitor = "CTRL + SHIFT + Escape",
    kbMusic = "SUPER + M",
    kbCommunication = "SUPER + D",
    kbTodo = "SUPER + R",

    ----------------------------------------------------------------
    -- Application Launchers
    ----------------------------------------------------------------
    kbLauncher = "SUPER + SUPER_L",

    kbTerminal = "SUPER + T",
    kbBrowser = "SUPER + W",
    kbEditor = "SUPER + C",
    kbFileExplorer = "SUPER + E",

    kbGithubDesktop = "SUPER + G",
    kbNemo = "SUPER + ALT + E",
    kbQps = "CTRL + ALT + Escape",
    kbPavucontrol = "CTRL + ALT + V",

    ----------------------------------------------------------------
    -- Session & Shell
    ----------------------------------------------------------------
    kbSession = "CTRL + ALT + Delete",

    kbLock = "SUPER + L",
    kbRestoreLock = "SUPER + ALT + L",
    kbSuspend = "SUPER + SHIFT + L",

    kbKill = "CTRL + SUPER + SHIFT + R",
    kbRestart = "CTRL + SUPER + ALT + R",

    ----------------------------------------------------------------
    -- Panels & Notifications
    ----------------------------------------------------------------
    kbShowSidebar = "SUPER + N",
    kbShowPanels = "SUPER + K",
    kbClearNotifs = "CTRL + ALT + C",
    kbTestNotification = "SUPER + ALT + F12",

    ----------------------------------------------------------------
    -- Media Controls
    ----------------------------------------------------------------
    kbMediaToggle = "CTRL + SUPER + SPACE",
    kbMediaNext = "CTRL + SUPER + EQUAL",
    kbMediaPrev = "CTRL + SUPER + MINUS",

    kbMuteSpeaker = "SUPER + SHIFT + M",

    ----------------------------------------------------------------
    -- Screenshots & Recording
    ----------------------------------------------------------------
    kbScreenshotFull = "Print",
    kbScreenshotFreeze = "SUPER + SHIFT + S",
    kbScreenshotRegion = "SUPER + SHIFT + ALT + S",

    kbScreenRecordAudio = "SUPER + ALT + R",
    kbScreenRecordNoAudio = "CTRL + ALT + R",
    kbScreenRecordRegion = "SUPER + SHIFT + ALT + R",

    kbColorPicker = "SUPER + SHIFT + C",

    ----------------------------------------------------------------
    -- Clipboard & Emoji
    ----------------------------------------------------------------
    kbClipboard = "SUPER + V",
    kbClipboardDelayed = "SUPER + ALT + V",
    kbClipboardPasteLatest = "CTRL + SHIFT + ALT + V",

    kbEmojiPicker = "SUPER + Period",

    ----------------------------------------------------------------
    -- Appearance
    ----------------------------------------------------------------
    toggleNightMode = "SUPER + SHIFT + N",
}

-- Computed border colors using color scheme
Config.computed = {
    activeWindowBorderColour = "rgba(" .. Config.colors.primary .. "e6)",
    inactiveWindowBorderColour = "rgba(" .. Config.colors.onSurfaceVariant .. "11)",
    shadowColour = "rgba(" .. Config.colors.surfaceDim .. "d4)",
    primaryd4 = "rgba(".. Config.colors.primary .."d4)",
    outlined4 = "rgba(".. Config.colors.outline .."d4)",
    secondaryd4 = "rgba(".. Config.colors.secondary .."d4)"
}

return Config