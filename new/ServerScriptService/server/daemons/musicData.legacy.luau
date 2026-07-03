--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 03
	
	[DESCRIPTION]
	A very basic data system to keep one value: musicEnabled.
]=]

-- [REQUIRES]
local try = require("@game/ReplicatedFirst/pip/try")
local console = require("@game/ReplicatedFirst/pip/console")
local events = require("@game/ReplicatedFirst/shared/events")

local musicStore: DataStore = game.DataStoreService:GetDataStore("musicStore")

events.fetchMusicSetting.OnServerInvoke = function(player: Player) : boolean
	local _, value: boolean? = try {
		function()
			local data: boolean = musicStore:GetAsync(player.UserId)
			if not data then
				console.warn("No data returned from musicStore", `player: {tostring(player)}`)
				return nil
			end
			
			if typeof(data) ~= "boolean" then
				console.warn("Invalid type returned from musicStore", `got {tostring(data)} {typeof(data)}`, `player: {tostring(player)}`)
				return nil
			end
			
			console.log("data read", data)
			return data
		end,
		function(err: string?)
			console.warn("Data fetch failed", `err: {tostring(err)}`, `player: {tostring(player)}`)
			return nil
		end,
	}
	
	console.log("data returned B)", value)
	return value
end

events.updateMusicSetting.OnServerEvent:Connect(function(player: Player, value: boolean?)
	if typeof(value) ~= "boolean" then
		console.warn("Remote tampering for value?", `got {tostring(value)} {typeof(value)}`, `player: {tostring(player)}`)
		return
	end
	
	local done: boolean, _ = try {
		function()
			musicStore:SetAsync(player.UserId, value)
		end,
		function(err: string?)
			console.warn("Data save failed", `err: {tostring(err)}`, `player: {tostring(player)}`)
			return nil
		end,
	}
	
	console.log("data saved status:", done)
end)