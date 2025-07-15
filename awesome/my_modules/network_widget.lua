local lain = require("lain")
local wibox = require("wibox")
local my_theme = require("my_modules/my_theme")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local icon = wibox.widget({
	image = gears.color.recolor_image(my_theme.web_icon, my_theme.fg_normal),
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

lain.widget.net({
	settings = function()
		text:set_markup_silently(net_now.received .. "↓ " .. net_now.sent .. "↑")

		-- Optional: colorize if traffic is high
		local down = tonumber(net_now.received) or 0
		local up = tonumber(net_now.sent) or 0
		local color = my_theme.fg_normal
		if down > 500 or up > 500 then
			color = "#ffaa00"
		end
		if down > 1000 or up > 1000 then
			color = "#ff5555"
		end
		icon.image = gears.color.recolor_image(my_theme.web_icon, color)
	end,
})

return widget
