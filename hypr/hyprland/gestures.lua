hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.15,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    }
})

-- 3-finger horizontal workspace swipe
hl.gesture({
    fingers = Config.vars.workspaceSwipeFingers,
    direction = "horizontal",
    action = "workspace",
})

-- Swipe up -> show special workspace
hl.gesture({
    fingers = Config.vars.gestureFingers,
    direction = "up",
    action = "special",
    workspace_name = "special",
})

-- Swipe down -> toggle special workspace
hl.gesture({
    fingers = Config.vars.gestureFingers,
    direction = "down",
    action = function()
        hl.dispatch(
            hl.dsp.workspace.toggle_special("special")
        )
    end,
})

-- More fingers swipe down -> suspend
hl.gesture({
    fingers = Config.vars.gestureFingersMore,
    direction = "down",
    action = function()
        hl.dispatch(
            hl.dsp.exec_cmd("systemctl suspend-then-hibernate")
        )
    end,
})