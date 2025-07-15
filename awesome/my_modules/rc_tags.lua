local awful = require("awful")
local l = awful.layout.suit

-- create tags
tag_Term = awful.tag.add("Term", {
	layout = l.tile,
	layouts = { l.tile, l.max },
	gap_single_client = false,
	gap = 4,
	selected = true,
})
tag_Web = awful.tag.add("Web", {
	layout = l.tile,
	layouts = { l.tile, l.max },
})
tag_Mail = awful.tag.add("Mail", {
	layout = l.tile,
	layouts = { l.tile, l.max },
	gap_single_client = false,
	gap = 4,
})
tag_Misc = awful.tag.add("Misc", {
	layout = l.tile,
	layouts = { l.tile, l.max },
	gap_single_client = false,
	gap = 4,
	master_width_factor = 0.5,
})
