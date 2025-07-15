local lain = require("lain")
local wibox = require("wibox")
local my_theme = require("my_modules/my_theme")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local icon = wibox.widget({
	image = gears.color.recolor_image(my_theme.mem_icon, my_theme.fg_normal),
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

local widget = wibox.container.margin(widget, dpi(2), dpi(4), dpi(2), dpi(2))

lain.widget.mem({
	settings = function()
		text:set_markup_silently(mem_now.used .. " MB")

		-- Optional: change icon color if usage > threshold
		local used_mb = tonumber(mem_now.used)
		local color = my_theme.fg_normal
		if used_mb >= 8000 then
			color = "#ff5555"
		elseif used_mb >= 4000 then
			color = "#ffaa00"
		end
		icon.image = gears.color.recolor_image(my_theme.mem_icon, color)
	end,
})

return widget
