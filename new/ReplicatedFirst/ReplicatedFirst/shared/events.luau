--[=[
	[INFO]
	author: halosviel
]=]

local packet = require("./libs/packet")

return {
	selectStage = packet("SelectStage", packet.NumberU8):Response(packet.Boolean8, packet.Any),
	
	fetchMusicSetting = packet("FetchMusicSetting"):Response(packet.Boolean8),
	updateMusicSetting = packet("UpdateMusicSetting", packet.Boolean8)
}