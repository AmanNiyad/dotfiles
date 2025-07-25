pcall(require, "luarocks.loader")

-- local edid = require("my_modules/edid")
-- local naughty = require("naughty")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local my_utils = require("my_modules/my_utils")
local lain = require("lain")
local capslock = require("my_modules/capslock")
local nextthing = require("my_modules/nextthing")
local cpu_widget = require("my_modules/cpu_widget")
local mem_widget = require("my_modules/mem_widget")
local net_widget = require("my_modules/network_widget")
local sound_widget = require("my_modules/sound-widget")
local mic_widget = require("my_modules/mic-widget")
local helpers = require("my_modules/geo_helpers")
local naughty = require("naughty")
local dpi = require("beautiful").xresources.apply_dpi
local hotkeys_popup = require("awful.hotkeys_popup")

-- debug stuff if needed
local printmore = false

require("awful.hotkeys_popup.keys")
require("awful.autofocus")

hostname = io.popen("uname -n"):read()

-- Theme initialize
beautiful.init("/home/aman/.config/awesome/my_modules/my_theme.lua")

-- Error handling
dofile("/home/aman/.config/awesome/my_modules/rc_errorhandling.lua")

-- Functions definition
dofile("/home/aman/.config/awesome/my_modules/rc_functions.lua")

-- Tags definition
dofile("/home/aman/.config/awesome/my_modules/rc_tags.lua")

-- Volume/Brightness OSD notifications
dofile("/home/aman/.config/awesome/my_modules/rc_fn_actions.lua") -- Needs work!!!

clientkeys = gears.table.join(
	-- Increase/decrease windows sizes on tiled layout: Win + asdf
	awful.key({ win }, "d", function()
		awful.tag.incmwfact(0.01)
	end),
	awful.key({ win }, "a", function()
		awful.tag.incmwfact(-0.01)
	end),
	awful.key({ win }, "s", function()
		awful.client.incwfact(0.01)
	end),
	awful.key({ win }, "w", function()
		awful.client.incwfact(-0.01)
	end),
	-- Quit window: Win + shift + c
	awful.key({ win, "Shift" }, "c", function(c)
		c:kill()
	end),
	-- Swap master windows: Win + enter
	awful.key({ win }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end),
	-- Movement and focus:
	-- Win                + Arrows -> Swap focus between windows
	-- Win        + Shift + WASD   -> Move windows to that direction
	-- Win + Ctrl         + Arrows -> Expand windows to that direction
	-- Win + Ctrl + Shift + Arrows -> Shrink windows from that direction
	awful.key({ ctrl, win }, "Right", function(c)
		move_or_expand(c, "expand", "right")
	end),
	awful.key({ win, "Shift" }, "a", function(c)
		move_or_expand(c, "move", "left")
	end),
	awful.key({ ctrl, win, "Shift" }, "Left", function(c)
		move_or_expand(c, "shrink", "left")
	end),
	awful.key({ ctrl, win }, "Left", function(c)
		move_or_expand(c, "expand", "left")
	end),
	awful.key({ ctrl, win, "Shift" }, "Right", function(c)
		move_or_expand(c, "shrink", "right")
	end),
	awful.key({ win, "Shift" }, "d", function(c)
		move_or_expand(c, "move", "right")
	end),
	awful.key({ ctrl, win }, "Down", function(c)
		move_or_expand(c, "expand", "down")
	end),
	awful.key({ ctrl, win, "Shift" }, "Up", function(c)
		move_or_expand(c, "shrink", "up")
	end),
	awful.key({ ctrl, win }, "Up", function(c)
		move_or_expand(c, "expand", "up")
	end),
	awful.key({ win, "Shift" }, "s", function(c)
		move_or_expand(c, "move", "down")
	end),
	awful.key({ win, "Shift" }, "w", function(c)
		move_or_expand(c, "move", "up")
	end),
	awful.key({ ctrl, win, "Shift" }, "Down", function(c)
		move_or_expand(c, "shrink", "down")
	end),
	awful.key({ win }, "Right", function(c)
		switch_focus_without_mouse(c, "right", printmore)
	end),
	awful.key({ win }, "Left", function(c)
		switch_focus_without_mouse(c, "left", printmore)
	end),
	awful.key({ win }, "Down", function(c)
		if c.sticky then
			-- in case it's on top
			awful.client.focus.history.previous()
		else
			awful.client.focus.bydirection("down")
		end
	end),
	awful.key({ win }, "Up", function(c)
		local cls = client.get()
		local stickies = {}
		-- Get all the stickies
		for _, c in ipairs(cls) do
			if c.sticky then
				table.insert(stickies, c)
			end
		end
		if my_utils.table_length(stickies) == 0 then
			awful.client.focus.bydirection("up")
		else
			awful.client.focus.history.previous()
		end
	end),
	-- Minimize window: Win + z
	awful.key({ win }, "z", function(c)
		c.minimized = true
	end),
	-- Suspend the window's app with SIGSTOP: Ctrl + Alt + s
	awful.key({ ctrl, alt }, "s", function(c)
		suspend_toggle(c)
	end),
	-- Shrink window and make it sticky & on top (e.g. conference call): Ctrl + Alt + w
	awful.key({ ctrl, alt }, "w", function(c)
		float_toggle(c)
	end),
	awful.key({ ctrl, alt }, "f", function(c)
		c.fullscreen = not c.fullscreen
	end),
	-- Sticky toggle for window: Ctrl + Alt + Shift + s
	awful.key({ ctrl, alt, "Shift" }, "s", function(c)
		sticky_toggle(c)
	end),
	-- Hide stickies to the bottom-right corner (toggle) : Win + Esc
	awful.key({ win }, "Escape", function(c)
		hide_stickies()
	end),
	awful.key({ win }, "F7", nil, function(c)
		resize_screen(c.screen, screens_table, false)
	end),
	awful.key({ win }, "F8", nil, function(c)
		resize_screen(c.screen, screens_table, true)
	end)
)

my_systray = wibox.widget.systray()
my_systray:set_base_size(dpi(24))

function set_keys_after_screen_new(clientkeys, globalkeys, printmore)
	if screen:count() > 1 then
		-- Shortcut for moving window between screens
		clientkeys = gears.table.join(
			clientkeys,
			awful.key({ win, "Shift" }, "Left", function(c)
				c:move_to_screen(c.screen.index - 1)
			end),
			awful.key({ win, "Shift" }, "Right", function(c)
				c:move_to_screen(c.screen.index + 1)
			end)
		)
	end

	-- not sure why we're doing 10+ here 🤷
	globalkeys = gears.table.join(
		globalkeys,
		awful.key({ win }, "#10", function()
			switch_to_tag("Term", printmore)
		end),
		awful.key({ win }, "#11", function()
			switch_to_tag("Web", printmore)
		end),
		awful.key({ win }, "#12", function()
			switch_to_tag("Mail", printmore)
		end),
		awful.key({ win }, "#13", function()
			switch_to_tag("Misc", printmore)
		end),
		awful.key({ win, "Shift" }, "#10", function()
			move_focused_client_to_tag("Term")
		end),
		awful.key({ win, "Shift" }, "#11", function()
			move_focused_client_to_tag("Web")
		end),
		awful.key({ win, "Shift" }, "#12", function()
			move_focused_client_to_tag("Mail")
		end),
		awful.key({ win, "Shift" }, "#13", function()
			move_focused_client_to_tag("Misc")
		end)
	)

	return clientkeys, globalkeys
end

-- some aliases
terminal = "alacritty"
browser = "firefox"
editor = "nvim"
editor_cmd = terminal .. " -e " .. editor
greenclip_cmd = "rofi -dpi " .. dpi(80) .. " -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}' "
rofi_cmd = "rofi -dpi " .. dpi(80) .. " -show run"
rofi_emoji_cmd = "rofi -dpi " .. dpi(80) .. " -show emoji -modi emoji"
rofi_calc_cmd = "rofi -dpi " .. dpi(80) .. " -show calc -modi calc"
rofi_subsuper = "rofi -dpi " .. dpi(80) .. " -show fb -modes 'fb:rofi-subsuper'"

win = "Mod4"
alt = "Mod1"
ctrl = "Control"

-- dropdown terminal from lain
my_dropdown = lain.util.quake({
	app = terminal,
	argname = "--class %s",
	name = "myshittydropdown",
	height = 0.5,
	followtag = true,
	visible = false,
})

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ win }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ win }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewprev(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewnext(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 2, function(c)
		c:kill()
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

separator = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	forced_width = 30,
	color = beautiful.separator,
	shape = gears.shape.powerline,
})

separator_empty = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	forced_width = 10,
	color = beautiful.bg_normal,
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
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local lain = require("lain")
local beautiful = require("beautiful")
local my_utils = require("my_modules/my_utils")
local awful = require("awful")

-- Detect battery adapter
local adapter_name = "BAT0"
if my_utils.file_exists("/sys/class/power_supply/BAT1/status") then
	adapter_name = "BAT1"
end

-- Icon widget with forced size
local battery_image_widget = wibox.widget({
	image = beautiful.battery_icon_empty,
	resize = true,
	forced_height = dpi(18),
	forced_width = dpi(18),
	widget = wibox.widget.imagebox,
})

-- Tooltip on hover
local bat_tooltip = get_tooltip(battery_image_widget)

-- Text widget
local battery_text_widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = beautiful.font,
})

-- Margin between icon and text
local battery_text_margin = wibox.container.margin(battery_text_widget, dpi(5), 0, 0, 0)

-- Horizontal layout
local battery_inner_widget = wibox.widget({
	battery_image_widget,
	battery_text_margin,
	layout = wibox.layout.fixed.horizontal,
})

-- Outer margin
local battery_widget = wibox.container.margin(battery_inner_widget, dpi(2), dpi(4), dpi(2), dpi(2))

-- Lain battery logic
lain.widget.bat({
	battery = adapter_name,
	full_notify = "off",
	settings = function()
		local perc = ""
		local battery_widget_color = beautiful.fg_normal
		local battery_image = beautiful.battery_icon_full

		if bat_now.status == "Charging" then
			battery_widget_color = beautiful.fg_normal_alt or "#8ec07c"
			battery_image = beautiful.battery_icon_charging
		elseif bat_now.status == "Full" then
			battery_image = beautiful.battery_icon_full
			perc = ""
		else
			battery_widget_color = beautiful.fg_normal_alt or "#a89984"
			if tonumber(bat_now.perc) then
				if bat_now.perc > 80 then
					battery_image = beautiful.battery_icon_full
				elseif bat_now.perc > 40 then
					battery_image = beautiful.battery_icon_medium
				elseif bat_now.perc > 20 then
					battery_image = beautiful.battery_icon_low
				else
					battery_image = beautiful.battery_icon_empty
					battery_widget_color = "#fb4934" -- alert red
				end
			end
		end

		if bat_now.perc ~= "N/A" and tonumber(bat_now.perc) and bat_now.perc <= 90 then
			perc = bat_now.perc .. "%"
		end

		battery_text_widget:set_markup(lain.util.markup.fontfg(beautiful.font, battery_widget_color, perc))
		battery_image_widget:set_image(gears.color.recolor_image(battery_image, battery_widget_color))
		bat_tooltip.text = bat_now.status .. " (" .. perc .. ")"
	end,
})

-- Click to manually update
battery_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
	battery_text_widget:update()
end)))

-- @Reference
-- When a new sound device is added/removed,
-- create a temporary popup to change default output device
-- function sound_device_change(signal)
-- refresh_sound_popup()
-- temp_sound_popup = sound_popup
-- primary_screen = awful.screen.focused()
-- if docked then
-- -- Use secondary screen, on the right side
-- for s in screen do
-- if not my_utils.is_screen_primary(s) then
-- primary_screen = s
-- end
-- end
-- end
-- temp_sound_popup.screen = primary_screen
-- awful.placement.top_right(temp_sound_popup, {honor_workarea=true})
-- temp_sound_popup.visible = true
-- hide_popup = gears.timer {
-- timeout   = 10,
-- single_shot = true,
-- callback  = function()
-- temp_sound_popup.visible = false
-- temp_sound_popup = nil
-- end
-- }
-- hide_popup:start()
-- end
-- dbus.add_match("system","type='signal',interface='org.custom.aman'")
-- dbus.connect_signal("org.custom.aman", sound_device_change)

-- Create a textclock widget and attach the calendar
mytextclock = wibox.widget({
	widget = wibox.widget.textclock,
	format = " %d %b %H:%M (%a) ",
	refresh = 30,
})
calendarwidget = lain.widget.cal({
	followtag = true,
	week_number = "left",
	attach_to = { mytextclock },
	notification_preset = {
		font = beautiful.font_big,
		fg = beautiful.fg_normal,
		bg = beautiful.bg_focus,
	},
})

-- change tag names dynamically
refresh_tag_name = function()
	for s = 1, screen.count() do
		-- get a list of all tags
		local atags = screen[s].tags
		for i, t in ipairs(atags) do
			local clients_on_this_tag = 0
			for i, c in ipairs(t:clients()) do
				if not c.skip_taskbar then
					clients_on_this_tag = clients_on_this_tag + 1
				end
			end
			original_name = my_utils.get_first_word(t.name)
			t.name = original_name .. " " .. string.rep(".", clients_on_this_tag)
		end
	end
end

-- signal function to execute when a client disappears
client.connect_signal("unmanage", function(c, startup)
	if c.type == "normal" then
		focus_previous_client(c.screen.selected_tag.name, printmore)
	end
	refresh_tag_name()
end)

psi_timer = gears.timer({
	timeout = 15,
	autostart = true,
	callback = function()
		psi_widget:check()
	end,
})

nextthing_timer = gears.timer({
	timeout = 30,
	autostart = true,
	call_now = true,
	callback = function()
		nextthing:check()
	end,
})

local void_logo = wibox.widget.imagebox()
void_logo.image = gears.surface.load_uncached("/home/aman/.config/awesome/my_modules/assets/void.svg") -- Use a valid path
void_logo.resize = true
void_logo.forced_height = dpi(20)
void_logo.forced_width = dpi(20)
local function screen_organizer(s, primary, is_extra)
	debug_print("Now organizing screen: " .. s["name"], printmore)

	local void_logo_margin = wibox.container.margin(void_logo, dpi(6), dpi(8), dpi(4), dpi(4))

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s["object"].mylayoutbox = awful.widget.layoutbox(s["object"])
	s["object"].mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))

	-- some convenience stuff
	if screen:count() > 1 then
		taglist_width = dpi(250)
		wibar_height = dpi(25)
	else
		taglist_width = dpi(350)
		wibar_height = dpi(23)
	end

	if not is_extra then
		-- Create a taglist widget
		s["object"].mytaglist = awful.widget.taglist({
			screen = s["object"],
			filter = awful.widget.taglist.filter.all,
			style = {
				shape = gears.shape.powerline,
			},
			layout = {
				spacing = -15,
				spacing_widget = {
					color = beautiful.bg_normal,
					shape = gears.shape.powerline,
					widget = wibox.widget.separator,
				},
				layout = wibox.layout.flex.horizontal,
				forced_width = taglist_width,
				-- max_widget_width = taglist_width /50
			},
			widget_template = {
				{
					{
						{
							id = "text_role",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.flex.horizontal,
					},
					left = 24,
					right = 12,
					widget = wibox.container.margin,
				},
				id = "background_role",
				widget = wibox.container.background,
			},
			buttons = taglist_buttons,
		})

		-- Create a tasklist widget
		s["object"].mytasklist = awful.widget.tasklist({
			screen = s["object"],
			filter = awful.widget.tasklist.filter.currenttags,
			style = {
				shape = gears.shape.powerline,
			},
			layout = {
				spacing = -15,
				spacing_widget = {
					color = beautiful.bg_normal,
					shape = gears.shape.powerline,
					widget = wibox.widget.separator,
				},
				layout = wibox.layout.flex.horizontal,
			},
			widget_template = {
				{
					{
						{
							id = "text_role",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.flex.horizontal,
					},
					left = 18,
					right = 18,
					widget = wibox.container.margin,
				},
				id = "background_role",
				widget = wibox.container.background,
			},
			buttons = tasklist_buttons,
		})
	end

	-- Create the wibox
	s["object"].mywibox = awful.wibar({
		position = "top",
		screen = s["object"],
		height = wibar_height,
	})

	systray_right_widgets = {
		layout = wibox.layout.fixed.horizontal,
	}

	table.insert(systray_right_widgets, separator_empty)
	if primary then
		if screen:count() == 1 and (hostname == "bebop" or hostname == "splinter") then
			table.insert(systray_right_widgets, touch_widget)
			if hostname == "bebop" then
				table.insert(systray_right_widgets, rotate_widget)
			end
		end
		-- table.insert(systray_right_widgets, separator_reverse)
		-- table.insert(systray_right_widgets, keyboard_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, battery_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, cpu_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, mem_widget)
		table.insert(systray_right_widgets, separator_reverse)
		-- table.insert(systray_right_widgets, temp_widget)
		-- table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, net_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, sound_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, mic_widget)
		table.insert(systray_right_widgets, my_systray)
	end
	table.insert(systray_right_widgets, capslock)
	if primary then
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, mytextclock)
	else
		-- Not visible on single screen, by choice
		table.insert(systray_right_widgets, nextthing)
		table.insert(systray_right_widgets, separator_empty)
	end
	table.insert(systray_right_widgets, s["object"].mylayoutbox)

	-- Add widgets to the wibox
	if is_extra then
		-- Doesn't get much stuff on this screen by default
		-- Only if we move some shit to it
		s["object"].mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				void_logo_margin,
				layout = wibox.layout.align.horizontal,
				separator,
			},
			systray_right_widgets,
		})
	else
		-- Normal setup, tag and taskslists
		s["object"].mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				void_logo_margin,
				layout = wibox.layout.align.horizontal,
				s["object"].mytaglist,
				separator,
			},
			s["object"].mytasklist, -- Middle widget
			systray_right_widgets,
		})
	end
end

function place_tags(properties, primary, screens_table)
	if my_utils.table_length(screens_table) == 1 then
		-- Only 1 screen here, no need for drama
		for _, tag in pairs(root.tags()) do
			table.insert(screens_table[properties["name"]]["tags"], tag)
			if tag.screen ~= properties["object"] then
				tag.screen = properties["object"]
			end
		end
	else
		for _, tag in pairs(root.tags()) do
			local first_word = my_utils.get_first_word(tag.name)
			if primary == false and (first_word == "Web" or first_word == "Mail") then
				if tag.screen ~= properties["object"] then
					debug_print("Re-assigning " .. first_word, printmore)
					tag.screen = properties["object"]
					table.insert(screens_table[properties["name"]]["tags"], tag)
				else
					debug_print(first_word .. " is already on correct screen", printmore)
					table.insert(screens_table[properties["name"]]["tags"], tag)
				end
			elseif primary == true and (first_word == "Term" or first_word == "Misc") then
				if tag.screen ~= properties["object"] then
					debug_print("Re-assigning " .. first_word, printmore)
					tag.screen = properties["object"]
					table.insert(screens_table[properties["name"]]["tags"], tag)
				else
					debug_print(first_word .. " is already on correct screen", printmore)
					table.insert(screens_table[properties["name"]]["tags"], tag)
				end
			end
		end
	end

	-- ordering shit
	for _, tag in pairs(root.tags()) do
		if tag.name == "Term" then
			tag.index = 1
		elseif tag.name == "Mail" then
			tag.index = 3
		elseif tag.name == "Web" then
			tag.index = 2
		else
			tag.index = 4
		end
	end
end

function process_screens(systray, screens_table, printmore)
	systray = systray or nil

	debug_print("Processing screens result: " .. my_utils.dump(screens_table), printmore)

	second_screen_already_processed = false
	for name, properties in pairs(screens_table) do
		-- In case we have more than 2 screens, we will register first
		-- non-primary screen as 2nd, others won't get tags.
		if properties["primary"] then
			-- this is the "primary" screen so it should have the systray
			systray:set_screen(properties["object"])
			screen_organizer(properties, true, false, false)
			debug_print("Checking tags for: " .. name .. " (primary) ", printmore)
			place_tags(properties, true, screens_table)
		else
			screen_organizer(properties, false, second_screen_already_processed)
			if second_screen_already_processed then
				debug_print("Extra screen found: " .. my_utils.dump(properties["object"]), printmore)
			else
				debug_print("Checking tags for: " .. name .. " (not primary) ", printmore)
				place_tags(properties, false, screens_table)
				second_screen_already_processed = true
			end
		end
	end
	-- define rules since we have filled the screen table
	dofile("/home/aman/.config/awesome/my_modules/rc_rules.lua")

	clientkeys, globalkeys = set_keys_after_screen_new(clientkeys, globalkeys, printmore)
	dofile("/home/aman/.config/awesome/my_modules/rc_clientbuttons.lua")
	root.keys(globalkeys)
	set_rules(clientkeys)
end

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 4, awful.tag.viewprev), awful.button({}, 5, awful.tag.viewnext)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ win, "Shift" }, "h", function()
		hotkeys_popup.show_help(nil, awful.screen.focused())
	end, { description = "show help", group = "awesome" }),
	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn.with_shell("bash /home/aman/.config/awesome/brightness_control.sh up")
	end, { description = "+10%", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn.with_shell("bash /home/aman/.config/awesome/brightness_control.sh down")
	end, { description = "-10%", group = "hotkeys" }),

	-- ALSA volume control
	awful.key({}, "0x1008ff13", function()
		awful.spawn("amixer sset Master 5%+", false)
		awesome.emit_signal("volume::change")
	end, { description = "volume up", group = "hotkeys" }),

	awful.key({}, "0x1008ff11", function()
		awful.spawn("amixer sset Master 5%-", false)
		awesome.emit_signal("volume::change")
	end, { description = "volume down", group = "hotkeys" }),

	awful.key({}, "0x1008ffb2", function()
		awful.spawn("amixer sset Capture toggle", false)
		awesome.emit_signal("mic")
	end, { description = "toggle mute", group = "hotkeys" }),

	awful.key({}, "XF86AudioNext", function()
		awful.spawn("mpc next", false)
	end, { description = "next music", group = "hotkeys" }),

	awful.key({}, "XF86AudioPrev", function()
		awful.spawn("mpc prev", false)
	end, { description = "previous music", group = "hotkeys" }),

	awful.key({}, "XF86AudioPlay", function()
		awful.spawn("mpc toggle", false)
	end, { description = "play/pause music", group = "hotkeys" }),

	-- Ctrl + sound knob switches between tmux panes and firefox tabs 🤯
	-- awful.key({ ctrl         }, "XF86AudioRaiseVolume",  nil, function()
	--                                                             root.fake_input('key_press', 'Ctrl_L')
	--                                                             root.fake_input('key_press', 'Tab')
	--                                                             root.fake_input('key_release', 'Tab')
	--                                                             root.fake_input('key_release', 'Ctrl_L')
	--                                                           end),
	-- awful.key({ ctrl         }, "XF86AudioLowerVolume",  nil, function()
	--                                                             root.fake_input('key_press', 'Shift_L')
	--                                                             root.fake_input('key_press', 'Ctrl_L')
	--                                                             root.fake_input('key_press', 'Tab')
	--                                                             root.fake_input('key_release', 'Tab')
	--                                                             root.fake_input('key_release', 'Ctrl_L')
	--                                                             root.fake_input('key_release', 'Shift_L')
	--                                                           end),
	-- Win + sound knob switches between all windows 🤯
	awful.key({ win }, "XF86AudioRaiseVolume", nil, function()
		root.fake_input("key_press", 196)
		root.fake_input("key_release", 196)
	end),
	awful.key({ win }, "XF86AudioLowerVolume", nil, function()
		root.fake_input("key_press", "Shift_L")
		root.fake_input("key_press", 196)
		root.fake_input("key_release", 196)
		root.fake_input("key_release", "Shift_L")
	end),
	-- Smart plug toggle
	-- awful.key({              }, "XF86HomePage",          nil, function() awful.spawn(bulb_toggle) end),
	-- For laptop, which doesn't have next/prev buttons
	awful.key({ win }, "F9", nil, function()
		awful.spawn("rofi-pulse-select sink")
	end),
	-- Dropdown terminal: F12
	awful.key({}, "F12", nil, function()
		my_dropdown:toggle()
	end),
	awful.key({}, "Print", nil, function()
		awful.spawn("flameshot gui")
	end),
	awful.key({ "Shift" }, "Print", function()
		awful.spawn("flameshot full -c")
	end),
	awful.key({ win }, "p", function()
		awful.spawn(rofi_cmd)
	end),
	awful.key({}, "F9", nil, function()
		awful.spawn(rofi_emoji_cmd)
	end),
	awful.key({ ctrl }, "F9", nil, function()
		awful.spawn(rofi_calc_cmd)
	end),
	awful.key({ "Shift" }, "F9", nil, function()
		awful.spawn(rofi_subsuper)
	end),
	awful.key({ ctrl, alt }, "c", function()
		awful.spawn(greenclip_cmd)
	end),
	awful.key({ win, "Shift" }, "Return", function()
		awful.spawn(terminal)
	end),
	awful.key({ win }, "m", function()
		awful.spawn("thunderbird")
	end),
	awful.key({ win }, "f", function()
		awful.spawn("thunar")
	end),
	awful.key({ win }, "XF86WakeUp", nil, function()
		awful.spawn("sudo systemctl suspend")
	end),
	awful.key({ alt, "Shift" }, "t", function()
		awful.spawn("wezterm --config-file /home/aman/.config/wezterm/old-nomux.lua start")
	end),
	awful.key({ win }, "c", function()
		awful.spawn("chromium")
	end),
	awful.key({ ctrl, alt }, "p", function()
		notifytest()
	end),
	awful.key({ win }, "b", function()
		awful.spawn(browser)
	end),

	awful.key({ win }, "l", function()
		awful.spawn("sudo slock")
	end),
	-- awful.key({ win, "Shift" }, "l",                          function() awful.spawn("xdotool search --name \" Slack\" windowactivate &&  sleep 1 && xdotool key ctrl+k && sleep 0.8 && xdotool key g u r k a n Return && sleep 0.8 && xdotool key slash a w a y Return && sleep 0.8 && xdotool key slash s t a t u s space semicolon a y o o semicolon space l u n c h Return") end),
	-- If something goes wrong with loose setup
	awful.key({ win }, "r", function()
		awful.spawn("loose rotate")
	end),
	-- Cycle between available layouts
	awful.key({ win }, "space", function()
		awful.layout.inc(1)
	end),
	awful.key({ win }, "x", function()
		awful.spawn("pcmanfm-qt")
	end),
	awful.key({ win }, "Tab", function()
		awful.client.focus.byidx(1)
	end),
	awful.key({ win, "Shift" }, "Tab", function()
		awful.client.focus.byidx(-1)
	end),
	-- There is no "win-capslock", we meant win-tab probably
	awful.key({ win }, "Caps_Lock", function()
		awful.tag.viewnext(get_screen_of_focused())
	end),
	awful.key({ win, "Shift" }, "Tab", function()
		awful.tag.viewprev(get_screen_of_focused())
	end),
	awful.key({ win, ctrl }, "q", awesome.quit),
	awful.key({ win, ctrl }, "r", function()
		save_current_tags(screens_table)
		awesome.restart()
	end),
	awful.key({ win, "Shift" }, "z", unminimize_client)
)
if hostname == "splinter" then
	gears.table.merge(
		globalkeys,
		gears.table.join(
			awful.key({ win }, "v", function()
				awful.spawn("innovpn-toggle 'Innogames Wireguard (Primary)'")
			end),
			awful.key({ win, "Shift" }, "v", function()
				awful.spawn("innovpn-toggle 'Innogames Wireguard (Secondary)'")
			end)
		)
	)
	-- Shortcut cemetery
	-- awful.key({ win          }, "u",                          function() awful.spawn("/home/aman/clicky") end),
	-- awful.key({ ctrl, alt    }, "p",                          function() reset_pulse() end),
	-- awful.key({ win          }, "k",                          function() keyboard_widget:toggle() end),
	-- awful.key({ win          }, "e",                          function() keyboard_widget:toggle() end),
end

-- needed for capslock helper
gears.table.merge(globalkeys, capslock.possible_combinations)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	refresh_tag_name()
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	if not awesome.startup then
		awful.client.setslave(c)
	end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("property::minimized", function(c)
	-- If a sticky window is minimized, ensure it's visible on taskbar
	if c.sticky then
		c.skip_taskbar = false
	end
	if c.type == "normal" then
		focus_previous_client(c.screen.selected_tag.name, printmore)
	end
end)

client.connect_signal("focus", function(c)
	-- If a sticky window is unminimized, remove from taskbar
	if c.sticky and not c.minimized then
		c.skip_taskbar = true
	end
	-- border setup
	c.border_color = beautiful.border_focus
	-- transparency
	-- if c.opacity == 0.95 then
	-- c.opacity = 1
	-- end
end)

-- Screen handling
screen.connect_signal("list", function()
	debug_print("List signal received", printmore)
	if my_utils.file_age("/home/aman/.awesome_screen_setup_lock", printmore) < 4 then
		debug_print("There is already another lock waiting, skipping this screen change", printmore)
	else
		os.execute("touch /home/aman/.awesome_screen_setup_lock")
		debug_print("Sleeping for 2 secs", printmore)
		os.execute("sleep 2")
		screens_table = get_screens()
		process_screens(my_systray, screens_table, printmore)
	end
end)

os.execute("touch /home/aman/.awesome_screen_setup_lock")
screens_table = get_screens()
process_screens(my_systray, screens_table, printmore)

tag.connect_signal("request::screen", function(t)
	-- recover tags on a removed screen
	naughty.notify({ text = "Recovering tag: " .. t.name })
	for s in screen do
		t.screen = s
		my_dropdown.screen = s
		my_dropdown.visible = false
		return
	end
end)

-- I only need 2 of these though 😬 max, tile or bust.
tag.connect_signal("request::default_layouts", function()
	-- awful.layout.append_default_layouts({
	--   awful.layout.suit.tile,
	--   awful.layout.suit.max,
	-- }) # Changed on awesome-git
	awful.layout.layouts = {
		awful.layout.suit.tile,
		awful.layout.suit.max,
	}
end)

client.connect_signal("mouse::enter", function(c)
	if c.ontop and c.sticky and c.skip_taskbar and c.marked then
		c.opacity = 0.9
		-- Run away from mouse, to the other side of the screen
		if c.x > (c.screen.geometry.x + c.screen.geometry.width - 600) then
			c:relative_move(-(c.screen.geometry.width - c.width), 0, 0, 0)
		else
			c:relative_move((c.screen.geometry.width - c.width), 0, 0, 0)
		end
	end
end)

client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

-- @Reference: Reflect click to the client below
-- Still can't "undo" click on the original client, but fun to play
-- client.connect_signal("button::press", function (c)
-- if c.ontop and c.sticky and c.skip_taskbar and c.marked then
-- next_client = awful.client.next (1, c, true)
-- helpers.async("xdotool click --window " .. next_client.window .. " 1", function(out)
-- end)
-- end
-- end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

awesome.connect_signal("save-tags", function()
	-- We are about to exit / restart awesome, save our last used tag
	save_current_tags(screens_table)
end)

tag.connect_signal("property::layout", function(t)
	-- make the focused window master on layout change
	local c = client.focus
	if c and awful.layout.get(t.screen).name == "max" then
		awful.client.setmaster(c)
		c:raise()
	end
end)

client.connect_signal("property::size", function(c)
	-- workaround for exiting fullscreen on floating windows
	-- some params do not stay as they should, so we enforce them
	if c.floating and c.skip_taskbar and not c.fullscreen then
		c.sticky = true
		c.ontop = true
	end
end)

client.connect_signal("unfocus", function(c)
	-- border setup
	c.border_color = beautiful.border_normal

	-- transparency
	-- if c.opacity == 1 and not c.fullscreen then
	-- c.opacity = 0.95
	-- end

	-- auto-hide dropdown
	if c.instance == my_dropdown.name then
		my_dropdown.visible = not my_dropdown.visible
		my_dropdown:display()
	end
end)

-- HACK START --
-- Git version workaround, shit is not complete (e.g. slack does not switch to)
-- alerting chat etc. but at least hovers the app itself
-- https://github.com/awesomeWM/awesome/issues/3182 waiting for proper fix
-- naughty.connect_signal('destroyed', function(n, reason)
--   client_to_jump = nil
--   if reason == require('naughty.constants').notification_closed_reason.dismissed_by_user then
--     if n.clients then
--       -- notification thingy (maybe) gave us some client names, use them
--       for _, notification_client in ipairs(n.clients) do
--         if not notification_client then
--           -- Means this is nothingburger
--           goto noclient
--         end
--         client_to_jump = notification_client
--         debug_print('Jumping to notification-client: ' .. client_to_jump.name, printmore)
--         break
--         ::noclient::
--       end
--     else
--       -- no notification client is here
--       -- we will just assume when we clicked the pop-up, we have created
--       -- an urgent client. So we will be optimistic, will just jump to it
--       client_to_jump = get_latest_urgent_client()
--       debug_print('Jumping to latest urgent one: ' .. client_to_jump.name, printmore)
--     end
--   end
--   if client_to_jump then
--     x, y, prev_scr = save_mouse_location()
--     client_to_jump:jump_to()
--     restore_mouse_location(x, y, prev_scr, printmore, true)
--   end
-- end)

client.connect_signal("property::urgent", function(c)
	if c.urgent then
		c.urgent_since = os.time()
	end
end)
-- HACK END --

-- Show OSD notification of current status on volume:change signal
awesome.connect_signal("volume::change", function()
	-- check if it's muted first
	awful.spawn.easy_async("pamixer --get-mute", function(stdout, stderr, reason, exit_code)
		-- f*king whitespaces
		stdout = stdout:gsub("%s+", "")
		if stdout == "true" then
			-- muted, only show state
			triggerwibox("mute")
			return
		else
			helpers.async("pamixer --get-volume", function(out)
				vb_slider.widget.value = tonumber(out)
				triggerwibox("volume")
			end)
		end
	end)
end)

-- Show OSD notification of current brightness on brightness:change signal
awesome.connect_signal("brightness:change", function()
	awful.spawn.easy_async("brightnessctl -q get", function(current)
		awful.spawn.easy_async("brightnessctl -q max", function(max)
			vb_slider.widget.value = 100 * tonumber(current) / tonumber(max)
			triggerwibox("brightness")
		end)
	end)
end)

-- When switching to a tag with urgent clients, raise them.
awful.tag.attached_connect_signal(s, "property::selected", function()
	local urgent_clients = function(c)
		return awful.rules.match(c, { urgent = true })
	end
	for c in awful.client.iterate(urgent_clients) do
		if c.first_tag == mouse.screen.selected_tag then
			client.focus = c
			c:raise()
		end
	end
end)

awesome.connect_signal("startup", function(s, state)
	awful.spawn.with_shell("start-pipewire")
	run_once("picom")

	-- standard alt+tab
	run_once(
		'alttab -w 1 -t 400x300 -frame "' .. string.upper(beautiful.fg_normal) .. '" -i 100x100 -font xft:firacode-20',
		"400x300"
	)
	-- Alt+Tab for switching all windows
	run_once(
		'alttab -w 1 -t 250x100 -frame "'
			.. string.upper(beautiful.fg_normal)
			.. '" -d 1 -kk 0x1008ff49 -mk Super_L -i 50x50 -font xft:firacode-10 -vertical -p none',
		"0x1008ff49"
	)
end)

for s in screen do
	set_wallpaper(s)
end

debug_print("Last state of the screens table is: \n" .. my_utils.dump(screens_table), printmore)
load_last_active_tags(screens_table, printmore)
-- vim: set ts=2 sw=2 tw=0 :
