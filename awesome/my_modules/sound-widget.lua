local awfullocal
awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local my_utils = require("my_modules/my_utils")
local dpi = require("beautiful").xresources.apply_dpi

-- Base widgets
local icon = wibox.widget({
	widget = wibox.widget.textbox,
	font = "LineIcons 12",
	align = "center",
	valign = "center",
})

local text = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = beautiful.font,
})

-- Margin around text
local text_margined = wibox.container.margin(text, dpi(5), 0, 0, 0)

-- Horizontal layout: icon + spacer + text
local inner_widget = wibox.widget({
	icon,
	text_margined,
	layout = wibox.layout.fixed.horizontal,
})

-- Margin around full widget
local volume_widget = wibox.container.margin(inner_widget, dpi(6), dpi(8), dpi(4), dpi(4))

-- -- Auto-detect audio card
-- local detected_card = nil
-- local detected_control = nil
--
-- local function detect_card()
-- 	local f = io.popen("aplay -l | grep '^card' | head -n1 | awk '{print $2}' | sed 's/://'")
-- 	if not f then
-- 		return nil
-- 	end
-- 	local card = f:read("*l")
-- 	f:close()
-- 	return card or "0"
-- end
--
-- local function detect_control(card)
-- 	local f = io.popen("amixer -c " .. card .. " scontrols")
-- 	if not f then
-- 		return "Master"
-- 	end
-- 	local controls = f:read("*a")
-- 	f:close()
-- 	if string.find(controls, "PCM") then
-- 		return "PCM"
-- 	elseif string.find(controls, "Master") then
-- 		return "Master"
-- 	else
-- 		return string.match(controls, "'(.-)'") or "Master"
-- 	end
-- end
--
-- detected_card = detect_card()
-- detected_control = detect_control(detected_card)

-- Get current volume
local function get_volume_info()
	local f = io.popen(string.format("amixer get Master"))
	if not f then
		return nil
	end
	local out = f:read("*all")
	f:close()
	local volume = tonumber(string.match(out, "(%d?%d?%d)%%"))
	local mute = string.match(out, "%[(o[nf]*)%]") == "off"
	return volume, mute
end

-- Update logic
local function update_volume_widget()
	local vol, is_muted = get_volume_info()
	local fg = "#6c71c4"
	local icon_char = ""

	if vol == nil then
		icon_char = "󰝟 "
	elseif is_muted then
		icon_char = "󰖁 "
		fg = "#ff8c40"
	elseif vol > 120 then
		icon_char = "󰝝 "
		fg = "#dc322f"
	elseif vol > 70 then
		icon_char = "󰕾 "
	elseif vol > 40 then
		icon_char = "󰖀 "
	elseif vol > 10 then
		icon_char = "󰕿 "
	else
		icon_char = "󰝟 "
	end

	icon.markup = my_utils.create_markup({
		text = icon_char,
		size = "large",
		font = "LineIcons",
		fg = fg,
	})

	text.markup = my_utils.create_markup({
		text = (vol or 0) .. "%",
		rise = "3000",
		fg = fg,
	})
end

-- Mouse controls
volume_widget:buttons(awful.util.table.join(
	awful.button({}, 1, function()
		awful.spawn(string.format("amixer sset Master toggle"), false)
		update_volume_widget()
	end),
	awful.button({}, 2, function()
		awful.spawn(string.format("amixer -c %s sset '%s' toggle", detected_card, detected_control), false)
		update_volume_widget()
	end),
	awful.button({}, 3, function()
		awful.spawn("pavucontrol", false)
	end),
	awful.button({}, 4, function()
		awful.spawn(string.format("amixer -c %s sset '%s' 5%%+", detected_card, detected_control), false)
		update_volume_widget()
	end),
	awful.button({}, 5, function()
		awful.spawn(string.format("amixer -c %s sset '%s' 5%%-", detected_card, detected_control), false)
		update_volume_widget()
	end)
))

-- Signal hook for external updates
awesome.connect_signal("volume::change", function()
	update_volume_widget()
end)

-- Initial run
update_volume_widget()

return volume_widget
