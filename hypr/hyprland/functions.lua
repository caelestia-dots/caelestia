local function wsaction(x, y, i)
	return function()
		local activews = hl.get_active_workspace()
		if not activews then
			return
		end

		local id = activews.id
		local s = (i - 1) * 10 + (id % 10)
		local t = math.floor((id - 1) / 10) * 10 + i

		if x == "move" then
			local z = (y == "g") and t or s
			return hl.dispatch(hl.dsp.window.move({ workspace = z }))
		else
			local z = (y == "g") and s or t
			return hl.dispatch(hl.dsp.focus({ workspace = z }))
		end
	end
end

local function resize_by_screen(x, y)
	local screen = hl.get_active_monitor()
	local w = 1080
	local h = 1920
	if screen and type(screen.width) == "number" and type(screen.height) == "number" then
		w = math.floor(screen.width * x / 100)
		h = math.floor(screen.height * y / 100)
	end

	return { x = w, y = h, relative = false }
end

local function resize_activewindow(x, y)
	local window = hl.get_active_window()
	local w = 800
	local h = 600

	if window and window.size and type(window.size) == "table" then
		local win_w = window.size[1]
		local win_h = window.size[2]

		if win_w and win_h then
			local cur_w = math.floor(win_w * x / 100)
			local cur_h = math.floor(win_h * y / 100)
			w = cur_w + win_w
			h = cur_h + win_h
		end
	end

	return { x = w, y = h, relative = true }
end

local function resizer(a, b, c, d, e)
	local window = hl.get_active_window()
	if not (window and window.title) then
		return
	end
	if window.title and string.find(window.title, a, 1, e) then
		local disp = (type(d) == "table") and d or { d }
		for _, x in ipairs(disp) do
			hl.dispatch(x)
		end
		hl.dispatch(hl.dsp.window.resize(resize_by_screen(b, c)))
	end
end
return {
	resizer = resizer,
	resize_by_screen = resize_by_screen,
	resize_activewindow = resize_activewindow,
	wsaction = wsaction,
}
