local lain = require("lain")
local wibox = require("wibox")
local my_theme = require("my_modules/my_theme")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local icon = wibox.widget({
	image = gears.color.recolor_image(my_theme.cpu_icon, my_theme.fg_normal),
	resize = true,
	forced_height = dpi(18),
	forced_width = dpi(18),
	widget = wibox.widget.imagebox,
})

local text = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = my_theme.font,
})

local text_margined = wibox.container.margin(text, dpi(5), 0, 0, 0)

local widget = wibox.widget({
	icon,
	text_margined,
	layout = wibox.layout.fixed.horizontal,
})

local widget = wibox.container.margin(widget, dpi(3), dpi(5), dpi(3), dpi(3))

lain.widget.cpu({
	settings = function()
		local usage = tonumber(cpu_now.usage)
		text:set_markup_silently(usage .. "%")

		-- optional: dynamic color
		local color = my_theme.fg_normal
		if usage >= 90 then
			color = "#ff5555"
		elseif usage >= 70 then
			color = "#ffaa00"
		end
		icon.image = gears.color.recolor_image(my_theme.cpu_icon, color)
	end,
})

return widget
