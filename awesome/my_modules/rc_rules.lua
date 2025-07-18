local awful = require("awful")
local beautiful = require("beautiful")
local my_utils = require("my_modules/my_utils")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

function set_rules(clientkeys)
	-- {{{ Rules
	-- Rules to apply to new clients (through the "manage" signal).
	awful.rules.rules = {
		-- All clients will match this rule.
		{
			rule = {},
			properties = {
				border_width = beautiful.border_width,
				border_color = beautiful.border_normal,
				focus = awful.client.focus.filter,
				raise = true,
				keys = clientkeys,
				buttons = clientbuttons,
				screen = awful.screen.preferred,
				maximized_horizontal = false,
				maximized_vertical = false,
				maximized = false,
				placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			},
		},
		-- Floating clients.
		{
			rule_any = {
				instance = {
					"copyq", -- Includes session name in class.
					"pinentry",
				},
				type = {
					"popup_menu",
					"dropdown_menu",
					"toolbar",
					"dialog",
					"menu",
					"notification",
				},
				class = {
					"Arandr",
					"Blueman-manager",
					"Gpick",
					"Kruler",
					"MessageWin", -- kalarm.
					"myshittydropdown",
					"Sxiv",
					"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
					"Wpa_gui",
					"veromix",
					"xtightvncviewer",
					"gcr-prompter",
					"Gcr-prompter",
					"No Man's Sky",
				},
				-- Note that the name property shown in xprop might be set slightly after creation of the client
				-- and the name shown there might not match defined rules here.
				name = {
					"Event Tester", -- xev.
					"myshittydropdown",
				},
				role = {
					"AlarmWindow", -- Thunderbird's calendar.
					"ConfigManager", -- Thunderbird's about:config.
					"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
					"menu",
				},
			},
			properties = {
				floating = true,
			},
		},

		{
			rule_any = {
				name = {
					"Media viewer",
				},
				class = {
					"telegram-desktop",
				},
			},
			properties = {
				skip_decoration = true,
				ontop = true,
				floating = true,
			},
		},

		{
			rule = {
				name = "Microsoft Teams Notification",
			},
			properties = {
				focus = false,
				draw_backdrop = false,
				skip_decoration = true,
				ontop = true,
				sticky = true,
				skip_taskbar = true,
				floating = true,
				callback = function(c)
					awful.placement.top_right(c, { honor_workarea = true })
				end,
			},
		},

		{
			rule = {
				name = "Picture-in-Picture",
			},
			properties = {
				ontop = true,
				sticky = true,
				skip_taskbar = true,
				floating = true,
				dockable = false,
			},
		},

		{
			rule = {
				name = "Onboard",
			},
			properties = {
				focusable = false,
				ontop = true,
				sticky = true,
				skip_taskbar = true,
				floating = true,
			},
		},

		{
			rule_any = {
				class = {
					"chromium-browser",
					"gathertown",
				},
			},
			properties = {
				ontop = true,
				floating = true,
				sticky = true,
				skip_taskbar = true,
				width = dpi(1800),
				height = dpi(250),
				callback = function(c)
					awful.placement.top_right(c, { honor_workarea = true })
				end,
			},
		},

		-- Titlebars
		{
			rule_any = {
				type = {
					"dialog",
				},
				class = {
					"gcr-prompter",
					"Gcr-prompter",
				},
				name = {
					"Discord Updater",
				},
			},
			properties = {
				titlebars_enabled = true,
				placement = awful.placement.centered,
				height = dpi(500),
				width = dpi(600),
			},
		},

		{
			rule = {
				type = "normal",
			},
			except_any = {
				class = {
					"gcr-prompter",
					"Gcr-prompter",
				},
			},
			properties = {
				titlebars_enabled = false,
			},
		},

		-- Window binding
		{
			rule_any = {
				class = {
					"alacritty",
				},
			},
			except_any = {
				class = {
					"gathertown",
				},
			},
			properties = {
				tag = awful.tag.find_by_name(nil, "Term"),
			},
		},

		{
			rule_any = {
				class = {
					"firefox",
				},
			},
			except_any = {
				class = {
					"myshittydropdown",
				},
			},
			properties = {
				tag = awful.tag.find_by_name(nil, "Web"),
				size_hints_honor = false, -- don't try to be clever
			},
		},
		{
			rule_any = {
				class = {
					"thunderbird",
				},
			},
			properties = {
				tag = awful.tag.find_by_name(nil, "Mail"),
			},
		},
		{
			rule_any = {
				class = {
					"thunar",
					-- "Soffice" -- << Really? Hidden class for open files, FUCK LIBREOFFICE
				},
			},
			except_any = {
				type = {
					"dialog",
				},
			},
			properties = {
				tag = awful.tag.find_by_name(nil, "Misc"),
				maximized = true,
			},
		},
	}
end
