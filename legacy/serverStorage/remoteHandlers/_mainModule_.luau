local module = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local dataStoreService = game:GetService("DataStoreService")
local httpService = game:GetService("HttpService")

local webhook_SL = "https://discord.com/api/webhooks/928279716211879957/MlN2kL_fNruSb0KpfgEY-ZvDx_A8a3IjpnZPvlc32-BHh0LGGG6Xndh-vGZr6srQnMIQ"
local bannedPlayers = dataStoreService:GetDataStore("bannedPlayers")

module.ban = function(info)
	local embed = {
		["embeds"] = {{
			["title"] = "squid:stages - Exploiter banned",
			["description"] = string.format(
				"**Player:** %s \n **UserId:** %s \n **Reason:** %s",
				info.player.Name, info.player.UserId, info.embedDescription
			),
			["thumbnail"] = {["url"] = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=150&height=150&format=png", info.player.UserId)},
			["color"] = 8029624
		}}
	}

	local data = httpService:JSONEncode(embed)
	httpService:PostAsync(webhook_SL, data)

	bannedPlayers:SetAsync(info.player.UserId, true)
	replicatedStorage.toClient:FireAllClients("sendChatMessage", string.format("%s was banned for exploiting", info.player.Name))
	info.player:Kick(
		string.format(
			"Banned. \n\n Offense Information \n ────────────────────── \n"
				.."Action: %s \n\n Details: %s \n\n Further Information \n ──────────────────────"
				.."\n You can appeal if you are a friend by showing my a screenshot of this prompt in my DMs."
				.."\n\n Your Username: %s \n Ban Date: %s \n ",
			info.kickAction, info.kickDetails, info.player.Name, DateTime.now():FormatLocalTime("LL", "en-gb")
		)
	)
end

return module