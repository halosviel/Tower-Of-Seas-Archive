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
local events = require("@game/ReplicatedFirst/shared/events")

-- [TYPES]
type self = types.MusicService

-->

return {
	constructor = function(self: self)
		-- [IMPORTS]
		self.interfaceService = import "./interfaceService"
		
		-- [ENTRIES]
		self.isPlaying = false
		self.currentSong = nil
	end,
	
	play = function(self: self)
		if self.isPlaying == true then
			console.warn("Music already playing")
			return
		end
		
		if self.currentSong then
			self.currentSong:Resume()
		end
		self.isPlaying = true
		
		self.interfaceService:_setMusicButtonEnabled(true) --# change text
		events.updateMusicSetting:Fire(true) --# save
	end,
	
	--# same comments as bove
	pause = function(self: self)
		if self.isPlaying == false then
			--console.warn("No music playing")
			return
		end
		
		if self.currentSong then
			self.currentSong:Pause()
		end
		self.isPlaying = false
		
		self.interfaceService:_setMusicButtonEnabled(false)
		events.updateMusicSetting:Fire(false)
	end,
	
	ready = function(self: self)
		
		--## Start Player Thread ##--
		do
			task.defer(function()
				while true do
					local sounds: { Sound } = game.SoundService.bgm:GetChildren()
					local randomSound: Sound?
					
					repeat
						task.wait()
						randomSound = sounds[math.random(1, #sounds)]
					until randomSound ~= self.currentSong
					
					if self.isPlaying then
						randomSound:Play()
					end
					
					self.currentSong = randomSound
					self.currentSong.Ended:Wait()
				end
			end)
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