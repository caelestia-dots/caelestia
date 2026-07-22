local function wsaction(action, range, i)
    return function()
        local activews = hl.get_active_workspace()
        if activews then
            local id = activews.id
            local s  = (i - 1) * 10 + (id % 10)
            local t  = math.floor((id - 1) / 10) * 10 + i
            local z  = (range == "group") and s or t

            if action == "move" then
                return hl.dispatch(hl.dsp.window.move({ workspace = z }))
            else
                return hl.dispatch(hl.dsp.focus({ workspace = z }))
            end
        end
    end
end

local function resize_by_screen(x, y)
    local screen = hl.get_active_monitor()
    if screen and type(screen.width) == "number" and type(screen.height) == "number" then
        if not (x == 0 and y == 0) then
            local w = (x and x > 0) and math.floor(screen.width * x / 100) or screen.width
            local h = (y and y > 0) and math.floor(screen.height * y / 100) or screen.height
            return { x = w, y = h, relative = false }
        end
    end
end

local function resize_active_window(x, y)
    return function() -- returning the function so hl reloads everytime correctly
        local win = hl.get_active_window()
        if win and win.size then
            local w = (win.size.x * (x / 100)) or 800
            local h = (win.size.y * (y / 100)) or 600

            hl.dispatch(hl.dsp.window.resize({ x = w, y = h, relative = true }))
        else
            hl.dispatch(hl.dsp.no_op())
        end
    end
end

local function resizer(window, pattern, x_percent, y_percent, actions, exact)
    if (window and window.title) and string.find(window.title, pattern, 1, exact) then
        local disp = (type(actions) == "table") and actions or { actions }
        for _, x in ipairs(disp) do
            hl.dispatch(x)
        end

        hl.dispatch(hl.dsp.window.resize(resize_by_screen(x_percent, y_percent)))
        hl.dispatch(hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true" }))
    end
end

local function move_actions(win)
    local screen = hl.get_active_monitor()

    if screen and screen.width and screen.height and win and win.size then
        local monitor_height = screen.height / screen.scale
        local monitor_width  = screen.width / screen.scale

        local scale_factor   = (monitor_height / 4) / win.size.y

        local target_width   = win.size.x * scale_factor
        local target_height  = win.size.y * scale_factor

        local x_resize       = math.floor(math.max(200, target_width))
        local y_resize       = math.floor(math.max(150, target_height))

        local offset         = math.min(monitor_width, monitor_height) * 0.03

        local move_x         = math.floor(screen.x + monitor_width - x_resize - offset)
        local move_y         = math.floor(screen.y + monitor_height - y_resize - offset)

        return {
            hl.dsp.window.resize({ x = x_resize, y = y_resize, window = win }),
            hl.dsp.window.move({ x = move_x, y = move_y, relative = false, window = win }),
        }
    end
end

-- Toggle function
local home       = os.getenv("HOME")
local config_dir = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local json       = require("utils.json")     -- rxi's peak library

-- Default config
local function default_config()
    return {
        communication = {
            discord  = { enable = true, match = { { class = "discord" } }, command = { "discord" }, move = true },
            whatsapp = { enable = true, match = { { class = "whatsapp" } }, move = true },
        },
        music = {
            spotify = {
                enable  = true,
                match   = { { class = "Spotify" }, { initial_title = "Spotify" }, { initial_title = "Spotify Free" } },
                command = { "spicetify", "watch", "-s" },
                move    = true,
            },
            feishin = { enable = true, match = { { class = "feishin" } }, move = true },
        },
        sysmon = {
            btop = {
                enable  = true,
                match   = { { class = "btop", title = "btop", workspace = { name = "special:sysmon" } } },
                command = { "foot", "-a", "btop", "-T", "btop", "fish", "-C", "exec btop" },
                move    = true,
            },
        },
        todo = {
            todoist = { enable = true, match = { { class = "todoist" } }, command = { "todoist" }, move = true },
        },
    }
end

local function merge(default_conf, user_conf)
    for category, apps in pairs(user_conf) do
        default_conf[category] = default_conf[category] or {}

        for app_name, options in pairs(apps) do
            default_conf[category][app_name] = default_conf[category][app_name] or {}

            for key, value in pairs(options) do
                default_conf[category][app_name][key] = value
            end
        end
    end
end

local function deep_match(actual, expected)
    if type(expected) == "table" then
        if type(actual) ~= "table" and type(actual) ~= "userdata" then
            return false
        end

        for key, sub_expected in pairs(expected) do
            if not deep_match(actual[key], sub_expected) then
                return false
            end
        end
        return true
    else
        return actual and string.find(tostring(actual), tostring(expected), 1, true)
    end
end

-- "if the client is running" etc function
local function get_clients(clients, app_config, target_special)
    local matched_clients = {}
    if app_config and app_config.match then
        for _, window in ipairs(clients) do
            for _, rule in ipairs(app_config.match) do
                local is_a_match = true
                for key, expected_value in pairs(rule) do
                    if not deep_match(window[key], expected_value) then
                        is_a_match = false
                        break
                    end
                end
                if is_a_match then
                    local client_workspace = window.workspace and window.workspace.name
                    table.insert(matched_clients, {
                        window = window,
                        is_in_place = (client_workspace == "special:" .. target_special),
                    })
                    break
                end
            end
        end
        return #matched_clients > 0, matched_clients
    end
    return false, matched_clients
end

local function shell_join(argv) -- uhh praise danny for this
    local quoted = {}
    for i, arg in ipairs(argv) do
        quoted[i] = "'" .. tostring(arg):gsub("'", [['"'"']]) .. "'"
    end
    return table.concat(quoted, " ")
end

local function spawn_client(app_config, target_workspace)
    if app_config.command then
        hl.dispatch(hl.dsp.exec_cmd(shell_join(app_config.command), { workspace = "special:" .. target_workspace }))
    end
end

local function move_client(window, special_workspace)
    if window then
        hl.dispatch(hl.dsp.window.move({ window = window, workspace = "special:" .. special_workspace }))
        hl.dispatch(hl.dsp.focus({ workspace = "special:" .. special_workspace })) -- we used to toggle...
    end
end

local function toggle(special_workspace)
    return function()
        if special_workspace == "specialws" then
            local active_workspace = hl.get_active_special_workspace()
            local fated_target     = active_workspace and active_workspace.name:gsub("^special:", "") or "special"
            return hl.dispatch(hl.dsp.workspace.toggle_special(fated_target))
        end

        local config = default_config()

        local user_file = io.open(config_dir .. "/caelestia/cli.json", "r") -- Cli.json
        if user_file then
            local content = user_file:read("*a")
            user_file:close()
            local recognized, user_conf = pcall(json.decode, content)
            if not recognized or type(user_conf) ~= "table" then
                hl.exec_cmd("caelestia shell toaster error 'Error' 'check your cli.json again BAKA BAKA' info")
            end
            local user_config = (recognized and type(user_conf) == "table") and user_conf.toggles or {}
            merge(config, user_config)
        end

        local apps          = config[special_workspace]
        local should_toggle = true
        if apps then
            local clients = hl.get_windows() or {}

            for _, app in pairs(apps) do
                if app.enable then
                    local is_running, target_clients = get_clients(clients, app, special_workspace)

                    if not is_running and app.command then
                        spawn_client(app, special_workspace)
                        should_toggle = false
                    elseif is_running then
                        for _, target_client in ipairs(target_clients) do
                            if not target_client.is_in_place and app.move then
                                move_client(target_client.window, special_workspace)
                                should_toggle = false
                            end
                        end
                    end
                end
            end
        end
        if should_toggle then
            hl.dispatch(hl.dsp.workspace.toggle_special(special_workspace)) -- toggling anyways except when launching the app
        end
    end
end

return {
    resizer              = resizer,
    resize_by_screen     = resize_by_screen,
    resize_active_window = resize_active_window,
    wsaction             = wsaction,
    move_actions         = move_actions,
    toggle               = toggle,
}
