-- local lain = require("lain")
-- local awful = require("awful")
-- local wibox = require("wibox")
-- local gears = require("gears")
-- local my_utils = require('my_modules/my_utils')
-- local beautiful = require("beautiful")
-- local dpi = require('beautiful').xresources.apply_dpi
--
-- volume_widget = lain.widget.pulse {
-- 	settings = function()
-- 		local soundlevel_emoji = my_utils.create_markup{
-- 			text="",
-- 			size="large",
-- 			fg="#6c71c4",
-- 			font="LineIcons"
-- 		}
-- 		local soundlevel_text = my_utils.create_markup{
-- 			text=volume_now.left .. '%',
-- 			rise="3000"
-- 		}
-- 		if volume_now.left == nil then
-- 			soundlevel_emoji = "X"
-- 		elseif tonumber(volume_now.left) > 120 then
-- 			soundlevel_emoji = my_utils.create_markup{
-- 				text="",
-- 				size="xx-large",
-- 				fg="#dc322f",
-- 				font="LineIcons"
-- 			}
-- 		elseif tonumber(volume_now.left) > 70 then
-- 			soundlevel_emoji = my_utils.create_markup{
-- 				text="",
-- 				size="xx-large",
-- 				fg="#6c71c4",
-- 				font="LineIcons"
-- 			}
-- 		elseif tonumber(volume_now.left) > 40 then
-- 			soundlevel_emoji = my_utils.create_markup{
-- 				text="",
-- 				size="xx-large",
-- 				fg="#6c71c4",
-- 				font="LineIcons"
-- 			}
-- 		elseif tonumber(volume_now.left) > 10 then
-- 			soundlevel_emoji = my_utils.create_markup{
-- 				text="",
-- 				size="x-large",
-- 				fg="#6c71c4",
-- 				font="LineIcons"
-- 			}
-- 		end
-- 		if volume_now.muted == "yes" then
-- 			soundlevel_emoji = my_utils.create_markup{
-- 				text="",
-- 				size="x-large",
-- 				fg="#ff8c40",
-- 				font="LineIcons"
-- 			}
-- 			soundlevel_text = my_utils.create_markup{
-- 				text=volume_now.left .. '%',
-- 				fg="#ff8c40",
-- 				rise="3000"
-- 			}
-- 		end
-- 		widget:set_markup(soundlevel_emoji .. " " .. soundlevel_text .. " ")
-- 	end
-- }
--
-- function get_results_as_table(command)
--     local lines = {}
--     local file = io.popen(command)
--     for line in file:lines() do
--         table.insert(lines, line)
--     end
--     file:close()
--     return lines
-- end
--
-- sound_popup = awful.popup {
--     ontop = true,
--     visible = false,
--     shape = function(cr, width, height)
--         gears.shape.rounded_rect(cr, width, height, 4)
--     end,
--     border_width = 1,
--     border_color = beautiful.bg_focus,
--     maximum_width = dpi(400),
--     offset = { y = 5 },
--     widget = {}
-- }
--
-- sound_popup:connect_signal("mouse::leave", function(c)
--     if sound_popup.visible then
--         sound_popup.visible = not sound_popup.visible
--     end
-- end)
--
-- function refresh_sound_popup()
--     sinks_table = get_results_as_table('paoutput -g')
--
--     local sound_rows = { layout = wibox.layout.fixed.vertical }
--
--     for _, item in ipairs(sinks_table) do
--
--         local row = wibox.widget {
--             {
--                 {
--                     {
--                         text = item,
--                         widget = wibox.widget.textbox
--                     },
--                     spacing = 12,
--                     layout = wibox.layout.fixed.horizontal
--                 },
--                 margins = 8,
--                 widget = wibox.container.margin
--             },
--             bg = beautiful.bg_normal,
--             widget = wibox.container.background
--         }
--
--         -- Change item background on mouse hover
--         row:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)
--         row:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
--
--         -- Change cursor on mouse hover
--         local old_cursor, old_wibox
--         row:connect_signal("mouse::enter", function()
--             local wb = mouse.current_wibox
--             old_cursor, old_wibox = wb.cursor, wb
--             wb.cursor = "hand1"
--         end)
--         row:connect_signal("mouse::leave", function()
--             if old_wibox then
--                 old_wibox.cursor = old_cursor
--                 old_wibox = nil
--             end
--         end)
--
--         -- Mouse click handler
--         row:buttons(
--             awful.util.table.join(
--                 awful.button({}, 1, function()
--                     sound_popup.visible = not sound_popup.visible
--                     awful.spawn.with_shell('paoutput -s ' .. item)
-- 		            volume_widget.update()
--                 end)
--             )
--         )
--
--         -- Insert created row in the list of rows
--         table.insert(sound_rows, row)
--     end
--
--     -- Add rows to the popup
--     sound_popup:setup(sound_rows)
-- end
--
-- refresh_sound_popup()
--
-- volume_widget.widget:buttons(awful.util.table.join(
--     awful.button({}, 1, function()
--         if sound_popup.visible then
--             sound_popup.visible = not sound_popup.visible
--         else
--             refresh_sound_popup()
--             sound_popup:move_next_to(mouse.current_widget_geometry)
--         end
--     end),
-- 	awful.button({}, 2, function()
-- 			os.execute(string.format("pactl set-sink-mute %s toggle", volume_widget.device))
-- 			volume_widget.update()
-- 	end),
--     awful.button({}, 3, function() -- middle
--         awful.spawn("pavucontrol")
--     end),
-- 	awful.button({}, 4, function() -- scroll up
-- 			os.execute(string.format("pactl set-sink-volume %s +5%%", volume_widget.device))
-- 			volume_widget.update()
-- 	end),
-- 	awful.button({}, 5, function() -- scroll down
-- 			os.execute(string.format("pactl set-sink-volume %s -5%%", volume_widget.device))
-- 			volume_widget.update()
-- 	end)
-- ))
--
-- return volume_widget
--
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local my_utils = require("my_modules/my_utils")
local dpi = require("beautiful").xresources.apply_dpi

-- Textbox widget
local volume_widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	forced_width = dpi(60),
	font = beautiful.font,
})

-- Cache card/control
local detected_card = nil
local detected_control = nil

-- Detect card
local function detect_card()
	local f = io.popen("aplay -l | grep '^card' | head -n1 | awk '{print $2}' | sed 's/://'")
	if not f then
		return nil
	end
	local card = f:read("*l")
	f:close()
	return card or "0"
end

-- Detect mixer control (PCM > Master > fallback)
local function detect_control(card)
	local f = io.popen("amixer -c " .. card .. " scontrols")
	if not f then
		return "Master"
	end
	local controls = f:read("*a")
	f:close()

	if string.find(controls, "PCM") then
		return "PCM"
	elseif string.find(controls, "Master") then
		return "Master"
	else
		local found = string.match(controls, "'(.-)'")
		return found or "Master"
	end
end

-- Setup detected values
detected_card = detect_card()
detected_control = detect_control(detected_card)

-- Helper to get volume and mute state using amixer
local function get_volume_info()
	local f = io.popen(string.format("amixer -c %s get '%s'", detected_card, detected_control))
	if not f then
		return nil
	end

	local out = f:read("*all")
	f:close()

	local volume = string.match(out, "(%d?%d?%d)%%")
	local mute = string.match(out, "%[(o[nf]*)%]")

	return tonumber(volume), mute == "off"
end

-- Widget update logic
local function update_volume_widget()
	local vol, is_muted = get_volume_info()

	local icon = ""
	local fg = "#6c71c4"
	local size = "large"

	if vol == nil then
		icon = "X"
	elseif vol > 120 then
		icon = ""
		fg = "#dc322f"
		size = "xx-large"
	elseif vol > 70 then
		icon = ""
		size = "xx-large"
	elseif vol > 40 then
		icon = ""
		size = "x-large"
	elseif vol > 10 then
		icon = ""
		size = "large"
	else
		icon = ""
		size = "large"
	end

	if is_muted then
		icon = ""
		fg = "#ff8c40"
	end

	local icon_markup = my_utils.create_markup({
		text = icon,
		size = size,
		fg = fg,
		font = "LineIcons",
	})

	local text_markup = my_utils.create_markup({
		text = (vol or 0) .. "%",
		fg = fg,
		rise = "3000",
	})

	volume_widget.markup = icon_markup .. " " .. text_markup .. " "
end

-- Set up buttons
volume_widget:buttons(awful.util.table.join(
	awful.button({}, 1, function()
		awful.spawn(string.format("amixer -c %s sset '%s' toggle", detected_card, detected_control), false)
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

-- Signal hook to sync volume from hotkeys
awesome.connect_signal("volume_change", function()
	update_volume_widget()
end)

-- Initial update
update_volume_widget()

return volume_widget
