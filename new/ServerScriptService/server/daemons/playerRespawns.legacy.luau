--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 03

    [DESCRIPTION]
    The daemon for manually respawning players
]=]

-- [CONFIG]
local RESPAWN_TIME = 2

-->

local function onCharacterAdded(character: Model)
	local player: Player = game.Players:GetPlayerFromCharacter(character)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	
	humanoid.Died:Connect(function()
		task.delay(RESPAWN_TIME, function()
			player:LoadCharacterAsync()
		end)
	end)
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
for _, player: Player in game.Players:GetPlayers() do
	onPlayerAdded(player)
end