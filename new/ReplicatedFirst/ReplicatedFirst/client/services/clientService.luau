--[=[
	[INFO]
	author: @halosviel
	created: 2026 May 22
	
	[DESCRIPTION]
	The master module for client states.
	
	[NOTES]
	- USE THIS TO ENTER/EXIT MENU!!!
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
					self.interfaceService:disableMenuButton()
					self.interfaceService:enterMenu()
				end,
				exit = function(state: BrowsingState)
					self.interfaceService:exitMenu()
				end,
			},
			playing = {
				enter = function(state: PlayingState)
					task.delay(1, function() --# on god cba to fix anim bugs
						if self.stateMachine.state ~= "playing" then
							return
						end
						self.interfaceService:enableMenuButton()
					end)
				end,
				exit = function(state: PlayingState)
					
				end,
			}
		})
	end,
	
	ready = function(self: self)
		
		--### Initialise Client ###--
		
		self.stateMachine:setState("browsing") --# the formal way of entering menu
	end,
} :: self