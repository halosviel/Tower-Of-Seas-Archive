--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 1
	
	[DESCRIPTION]
	Handles requests to spawn into a stage sent by clients.
	Minimal on security because, well... it's not important.
	
	Also keeps track of which stages players are in.
]=]

-- [REQUIRES]
local console = require("@game/ReplicatedFirst/pip/console")
local events = require("@game/ReplicatedFirst/shared/events")
local types = require("./_types")

-- [TYPES]
type self = types.StageService

-->

return {
	constructor = function(self: self)
		self.players = {}
	end,
	
	ready = function(self: self)
		game.Players.PlayerRemoving:Connect(function(player: Player)
			self.players[player] = nil
		end)

		events.selectStage.OnServerInvoke = function(player: Player, stageId: number?) : ( boolean, string? )
			if typeof(stageId) ~= "number" then
				console.warn(
					`Player {tostring(player)} sent a non-number type for parameter "stageId"`
						..`(number expected, got {typeof(stageId)} with value {tostring(stageId)})`
				)
				return false, "Request denied"
			end
			
			--[[local currentStageId: number? = self.players[player]
			if currentStageId == stageId then
				console.warn(`Player {tostring(player)} tried to enter the same stage??`)
				return false, "Cannot enter same stage"
			end]]
			
			local stage: Model = workspace.static.stages:FindFirstChild(stageId)
			if not stage then
				console.warn(`Player {tostring(player)} tried to enter a non-existent stage ({tostring(stageId)})`)
				return false, "Stage does not exist"
			end
			
			self.players[player] = stageId
			player:LoadCharacterAsync()
			
			print(`Player {tostring(player)} now on stage {stageId}`)
			--# playerSpawnHandler takes care of the rest
			
			return true
		end
	end,
} :: self