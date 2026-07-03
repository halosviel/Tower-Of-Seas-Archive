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
local console = require("@game/ReplicatedFirst/pip/console")
local import = require("@game/ReplicatedFirst/pip/import")

local stateMachine = require("@game/ReplicatedFirst/shared/utils/stateMachine")
local events = require("@game/ReplicatedFirst/shared/events")

-- [TYPES]
type self = types.MusicService

-->

return {
	constructor = function(self: self)
		-- [IMPORTS]
		self.interfaceService = import "./interfaceService"
		
		-- [ENTRIES]
		self.songs = {}
		self.currentSong = nil
		self.isPlaying = false
		self.stateMachine = stateMachine.new("musicStateMachine", {
			playing = {
				enter = function(state: stateMachine.State)
					
				end,
				exit = function(state: stateMachine.State)
					
				end,
			},
			
			paused = {
				enter = function(state: stateMachine.State)
					
				end,
				exit = function(state: stateMachine.State)
					
				end,
			}
		})
	end,
	
	play = function(self: self)
		if self.isPlaying == true then
			console.warn("Music already playing")
			return
		end
		
		self.stateMachine:setState("playing") --# do audio stuffs
		self.isPlaying = true
		
		self.interfaceService:_setMusicButtonEnabled(true) --# change text
		events.updateMusicSetting:Fire(true) --# save
	end,
	
	--# same comments as bove
	pause = function(self: self)
		if self.isPlaying == false then
			console.warn("No music playing")
			return
		end
		
		self.stateMachine:setState("paused")
		self.isPlaying = false
		
		self.interfaceService:_setMusicButtonEnabled(false)
		events.updateMusicSetting:Fire(false)
	end,
	
	ready = function(self: self)
		
		--## Cache Songs ##--
		for _, sound: Sound in game.SoundService.bgm:GetChildren() do
			table.insert(self.songs, sound)
		end
		
		--## Request Data ##--
		do
			task.spawn(function()
				local musicSetting: boolean = events.fetchMusicSetting:Fire()
				if musicSetting == nil then
					console.warn("fetchMusicSetting event returned nil", "Doing nothing...")
					return
				end
				
				if typeof(musicSetting) ~= "boolean" then
					console.warn("fetchMusicSetting event returned a non-boolean value", `Got {tostring(musicSetting)} ({typeof(musicSetting)})`)
				end
				
				if musicSetting == true then
					self:play()
				else
					self:pause()
				end
				
				self.interfaceService:_setMusicButtonVisible(true)
				self.interfaceService:_setMusicButtonEnabled(musicSetting)
			end)
		end
	end,
} :: self