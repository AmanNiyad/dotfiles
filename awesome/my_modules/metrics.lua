local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local lain = require("lain")

local my_theme = require("my_modules/my_theme")
local my_utils = require("my_modules/my_utils")
dofile("/home/aman/.config/awesome/my_modules/rc_functions.lua")

local markup = lain.util.markup

separator = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	forced_width = 30,
	color = beautiful.separator,
	shape = gears.shape.powerline,
})

separator_reverse = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	forced_width = 30,
	span_ratio = 0.7,
	color = beautiful.separator,
	set_shape = function(cr, width, height)
		-- gears.shape.parallelogram(cr, width, height)
		gears.shape.powerline(cr, width, height, (height / 2) * -1)
	end,
})
-- Base container
local system_metrics_widget = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	spacing = dpi(10),
})

local sys_tooltip = get_tooltip(system_metrics_widget)

-- CPU widget
local cpu_widget = lain.widget.cpu({
	settings = function()
		local usage = cpu_now.usage or 0
		widget:set_markup("🧠 " .. usage .. "%")
	end,
})

-- MEM widget
local mem_widget = lain.widget.mem({
	settings = function()
		local used = mem_now.used or 0
		widget:set_markup("🗄️ " .. used .. "M")
	end,
})

-- TEMP widget
local temp_widget = lain.widget.temp({
	settings = function()
		local temp = coretemp_now or "?"
		widget:set_markup("🌡️ " .. temp .. "°C")
	end,
})

-- NET widget
local net_widget = lain.widget.net({
	settings = function()
		local down = net_now.received or "0"
		local up = net_now.sent or "0"
		widget:set_markup("🌐 ↓" .. down .. " ↑" .. up)
	end,
})

-- Add all widgets
system_metrics_widget:add(cpu_widget.widget)
system_metrics_widget:add(separator_reverse)
system_metrics_widget:add(mem_widget.widget)
system_metrics_widget:add(separator_reverse)
system_metrics_widget:add(temp_widget.widget)
system_metrics_widget:add(separator_reverse)
system_metrics_widget:add(net_widget.widget)

-- Refresh tooltips with dynamic text (optional)
local function update_tooltip()
	sys_tooltip.text = string.format(
		"CPU: %s%%\nMEM: %sM\nTEMP: %s°C\nNET: ↓%s ↑%s",
		cpu_now.usage or "?",
		mem_now.used or "?",
		coretemp_now or "?",
		net_now.received or "?",
		net_now.sent or "?"
	)
end

gears.timer({
	timeout = 5,
	autostart = true,
	call_now = true,
	callback = update_tooltip,
})

return system_metrics_widget
