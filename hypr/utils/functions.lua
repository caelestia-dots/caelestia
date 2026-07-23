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
local json       = require("utils.json") -- rxi's peak library

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

-- Get a field from an object. Allows mapping camelCase to snake_case fields.
local function get_field(obj, key)
    local value = obj[key]
    if value == nil and type(key) == "string" then
        value = obj[(key:gsub("(%u)", "_%1")):lower()] -- Try convert camelCase to snake_case
    end
    return value
end

local function deep_match(actual, expected)
    if type(expected) == "table" then
        if type(actual) ~= "table" and type(actual) ~= "userdata" then
            return false
        end

        for key, sub_expected in pairs(expected) do
            if not deep_match(get_field(actual, key), sub_expected) then
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
                    if not deep_match(get_field(window, key), expected_value) then
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

-- Merge user config with defaults
local function load_toggle_config()
    local config = default_config()

    local user_file = io.open(config_dir .. "/caelestia/cli.json", "r") -- CLI config
    if not user_file then
        return config
    end

    local content = user_file:read("*a")
    user_file:close()

    local recognized, conf_or_error = pcall(json.decode, content)
    if recognized and type(conf_or_error) == "table" then
        merge(config, conf_or_error.toggles or {})
    else
        -- Invalid cli.json: notify and fall back to defaults.
        -- conf_or_error holds the parse error (string) or a non-table value on success.
        local reason = recognized and "Expected a JSON object" or tostring(conf_or_error):gsub("^.-:%d+: ", "")
        hl.exec_cmd("caelestia shell toaster error " ..
            shell_join({ "Failed to parse CLI config", reason }) .. " error")
    end

    return config
end

-- Ensure every configured app is present on the special workspace: spawn it if
-- it isn't running, otherwise move any stray clients onto the workspace.
local function place_apps(apps, special_workspace)
    local target = "special:" .. special_workspace
    local clients = hl.get_windows() or {}

    for _, app in pairs(apps) do
        if app.enable then
            local is_running, target_clients = get_clients(clients, app, special_workspace)

            if not is_running then
                if app.command then
                    hl.dispatch(hl.dsp.exec_cmd(shell_join(app.command), { workspace = target }))
                end
            elseif app.move then
                for _, target_client in ipairs(target_clients) do
                    if not target_client.is_in_place then
                        hl.dispatch(hl.dsp.window.move({ window = target_client.window, workspace = target, follow = false }))
                    end
                end
            end
        end
    end
end

local function toggle(special_workspace)
    return function()
        local active_workspace = hl.get_active_special_workspace()

        -- Generic special workspace toggle: close if any is open, or open "special"
        if special_workspace == "specialws" then
            local target = active_workspace and active_workspace.name:gsub("^special:", "") or "special"
            return hl.dispatch(hl.dsp.workspace.toggle_special(target))
        end

        local on_correct_ws = active_workspace and active_workspace.name == "special:" .. special_workspace

        -- Focus workspace before apps
        if not on_correct_ws then
            hl.dispatch(hl.dsp.focus({ workspace = "special:" .. special_workspace }))
        end

        local apps = load_toggle_config()[special_workspace]
        if apps then
            place_apps(apps, special_workspace)
        end

        -- Hide workspace if already active
        if on_correct_ws then
            hl.dispatch(hl.dsp.workspace.toggle_special(special_workspace))
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
