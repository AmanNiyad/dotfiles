local lain = require("lain")
local wibox = require("wibox")
local my_theme = require("my_modules/my_theme")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local icon = wibox.widget({
	image = gears.color.recolor_image(my_theme.mem_icon, my_theme.fg_normal),
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

lain.widget.mem({
	settings = function()
		text:set_markup_silently(mem_now.used .. "MB")
	end,
})

return widget
