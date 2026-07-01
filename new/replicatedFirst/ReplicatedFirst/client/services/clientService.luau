--[=[
	[INFO]
	author: @halosviel
	created: 2026 May 22
	
	[DESCRIPTION]
	
	[NOTES]
	- 
]=]

-- [REQUIRES]
local types = require("./_types")
local import = require("@game/ReplicatedFirst/pip/import")
local stateMachine = require("@game/ReplicatedFirst/shared/utils/stateMachine")

-- [TYPES]
type BrowsingState = {}
type PlayingState = {}

type self = types.ClientService

-->

return {
	constructor = function(self: self)
		-- [IMPORTS]
		self.interfaceService = import "./interfaceService"
		
		-- [ENTRIES]
		self.selectedStage = 0 --# 0 is a special case for initial joiners
		self.stateMachine = stateMachine.new("client", {
			browsing = {
				enter = function(state: BrowsingState)
					self.interfaceService:enterMenu()
				end,
				exit = function(state: BrowsingState)
					self.interfaceService:enterMenu()
				end,
			},
			playing = {
				enter = function(state: PlayingState)
					game.Players.LocalPlayer:LoadCharacterAsync()
				end,
				exit = function(state: PlayingState)
					
				end,
			}
		})
	end,
	
	ready = function(self: self)
		--### Initialise Client ###--
		self.stateMachine:setState("browsing")
	end,
} :: self