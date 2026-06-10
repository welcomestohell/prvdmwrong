local richterm = require "@batteries/richterm"

local PRIMARY = richterm.red
local SECONDARY = richterm.yellow

return table.freeze {
	PRIMARY = PRIMARY,
	SECONDARY = SECONDARY,

	BASE_TOP = "▄ █ ▀█▀ █ ▄",
	BASE_BOT = " █▀█ █ █▀█ ",

	RICH_TOP = `{PRIMARY "▄ █ "}{SECONDARY "▀█▀"}{PRIMARY " █ ▄"}`,
	RICH_BOT = `{PRIMARY " █▀█"}{SECONDARY " █ "}{PRIMARY "█▀█ "}`,

	INDENT = "           ",
}
