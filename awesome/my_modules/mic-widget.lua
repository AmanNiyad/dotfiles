local lain = require("lain")
local wibox = require("wibox")
local my_theme = require("my_modules/my_theme")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local awful = require("awful")

-- === ICON WIDGET ===
local mic_icon = wibox.widget({
	image = gears.color.recolor_image(my_theme.mic_icon or my_theme.cpu_icon, my_theme.fg_normal),
	resize = true,
	forced_height = dpi(18),
	forced_width = dpi(18),
	widget = wibox.widget.imagebox,
})

local mic_widget = wibox.container.margin(mic_icon, dpi(3), dpi(5), dpi(3), dpi(3))

-- === TOOLTIP ===
local mic_tooltip = awful.tooltip({
	objects = { mic_widget },
	timer_function = function()
		return mic_widget.status_text or "Mic: Unknown"
	end,
})

-- === UPDATE FUNCTION ===
local function update_mic_status()
	awful.spawn.easy_async_with_shell("amixer get Capture", function(stdout)
		local mic_on = stdout:match("%[on%]") ~= nil

		local color = mic_on and "#ff5555" or "#888888"
		mic_icon.image = gears.color.recolor_image(my_theme.mic_icon or my_theme.cpu_icon, color)

		-- Store text for tooltip
		mic_widget.status_text = mic_on and "Mic: On" or "Mic: Muted"
	end)
end

-- Initial update
update_mic_status()

-- Timer to refresh every 3 seconds
gears.timer({
	timeout = 3,
	autostart = true,
	call_now = true,
	callback = update_mic_status,
})

-- Optional: Click to toggle mute
mic_widget:buttons(gears.table.join(awful.button({}, 1, function()
	awful.spawn("amixer set Capture toggle")
	update_mic_status()
end)))

return mic_widget
