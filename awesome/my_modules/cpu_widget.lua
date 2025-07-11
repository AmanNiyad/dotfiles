local lain = require("lain")
local wibox = require("wibox")
local my_theme = require("my_modules/my_theme")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local icon = wibox.widget({
	image = gears.color.recolor_image(my_theme.cpu_icon, my_theme.fg_normal),
	resize = true,
	widget = wibox.widget.imagebox,
})

local text = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = my_theme.font,
})

local widget = wibox.widget({
	icon,
	text,
	layout = wibox.layout.fixed.horizontal,
})

local widget = wibox.container.margin(widget, dpi(6), dpi(8), dpi(4), dpi(4))

lain.widget.cpu({
	settings = function()
		text:set_markup_silently(cpu_now.usage .. "%")
	end,
})

return widget
