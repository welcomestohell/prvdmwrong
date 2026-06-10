local cli = require "@scripts/libs/cli"
local run = require "@scripts/libs/run"
local system = require "@lute/system"
local useMonorepo = require "@scripts/libs/monorepo/useMonorepo"

local args = cli.parser { description = "Opens a given place ID in Roblox Studio" }
args:add("place", "positional", { help = "Place name or ID to open", required = true })
args:parse { ... }

local function open(url)
	run(if system.os == "windows" then "explorer" elseif system.os == "Darwin" then "open" else "xdg-open", { url })
end

local place = args:get "place"
local placeId = tonumber(place)
if placeId == nil then
	-- monorepo alias
	local monorepo = useMonorepo()
	local member = monorepo[place] or error(`Unknown place ID or monorepo member named {place}`)
	local place = member.place or error(`Monorepo member must be a place`)
	placeId = place.placeId or error(`Monorepo member must be a real place (is placeId missing?)`)
end

open(`roblox-studio:1+task:EditPlace+placeId:{placeId}+universeId:0`)
