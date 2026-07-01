--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 1
	
	[DESCRIPTION]
	Handles character spawning when an external server source calls
	LoadCharacterAsync().
]=]

-- [REQUIRES]
local console = require("@game/ReplicatedFirst/pip/console")
local boot = require("@game/ReplicatedFirst/pip/boot")
local import = require("@game/ReplicatedFirst/pip/import")

local _types = require("@game/ServerScriptService/server/services/_types")

repeat task.wait() until boot.modules["stageService"] ~= nil --# hacky workaround, making a new framework anyway..
local stageService: _types.StageService = import "@game/ServerScriptService/server/services/stageService"

local teleport = require("@game/ServerScriptService/server/utils/teleport")

-->

local function onCharacterAdded(character: Model)
	local player: Player = game.Players:GetPlayerFromCharacter(character)
	local currentStageId: number? = stageService.players[player]
	
	if currentStageId == nil then
		currentStageId = 1 --# fallback :D
	end
	
	local stage: Model = workspace.static.stages:FindFirstChild(currentStageId) --# should already be validated by stageService
	local spawn: Part = stage:FindFirstChild("Spawn")
	if not spawn then
		console.devErr(`Spawn part in stage {currentStageId} does not exist!`)
		return
	end
	
	teleport(character, spawn.CFrame)
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