local function wsaction(x, y, i)
    return function()
        local activews = hl.get_active_workspace()
        if activews then
            local id = activews.id
            local s = (i - 1) * 10 + (id % 10)
            local t = math.floor((id - 1) / 10) * 10 + i

            if x == "move" then
                local z = (y == "g") and s or t
                return hl.dispatch(hl.dsp.window.move({ workspace = z }))
            else
                local z = (y == "g") and s or t
                return hl.dispatch(hl.dsp.focus({ workspace = z }))
            end
        end
    end
end

local function resize_by_screen(x, y)
    local screen = hl.get_active_monitor()
    if screen and type(screen.width) == "number" and type(screen.height) == "number" then
        if (x and y) > 0 then
            local w = screen.width
            local h = screen.height

            w = math.floor(screen.width * x / 100)
            h = math.floor(screen.height * y / 100)
            return { x = w, y = h, relative = false }
        end
    end
end

local function resize_activewindow(x, y)
    local w = 800
    local h = 600
    local win = hl.get_active_window()
    if win and win.size then
        w = (win.size.x * (x / 100))
        h = (win.size.y * (y / 100))

        return { x = w, y = h, relative = true }
    end
end

local function resizer(a, b, c, d, e)
    local window = hl.get_active_window()

    if (window and window.title) and string.find(window.title, a, 1, e) then
        hl.dispatch(hl.dsp.window.float())
        local disp = (type(d) == "table") and d or { d }
        for _, x in ipairs(disp) do
            hl.dispatch(x)
        end
        hl.dispatch(hl.dsp.window.resize(resize_by_screen(b, c)))
        hl.dispatch(hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true" }))
    end
end

local function moveActions()
    local screen = hl.get_active_monitor()
    local win = hl.get_active_window()

    if screen and screen.width and screen.height and win and win.size then
        local monitor_height = screen.height / screen.scale
        local monitor_width = screen.width / screen.scale

        local scale_factor = (monitor_height / 4) / win.size.y

        local target_width = win.size.x * scale_factor
        local target_height = win.size.y * scale_factor

        local x_resize = math.floor(math.max(200, target_width))
        local y_resize = math.floor(math.max(150, target_height))

        local offset = math.min(monitor_width, monitor_height) * 0.03

        local move_x = math.floor(screen.x + monitor_width - x_resize - offset)
        local move_y = math.floor(screen.y + monitor_height - y_resize - offset)

        return {
            hl.dsp.window.resize({ x = x_resize, y = y_resize }),
            hl.dsp.window.move({ x = move_x, y = move_y, relative = false }),
        }
    end
end

return {
    resizer = resizer,
    resize_by_screen = resize_by_screen,
    resize_activewindow = resize_activewindow,
    wsaction = wsaction,
    moveActions = moveActions,
}
