--[=[
	@halosviel | 2026 May 16
]=]

-- [REQUIRES]
local import = require("@game/ReplicatedFirst/pip/import")
local console = require("@game/ReplicatedFirst/pip/console")
local params = require("@game/ReplicatedFirst/pip/params")

local types = require("./_types")
local tweenUtils = require("@game/ReplicatedFirst/shared/utils/tweenUtils")
local soundUtils = require("@game/ReplicatedFirst/shared/utils/soundUtils")
local maid = require("@game/ReplicatedFirst/shared/libs/maid")
local events = require("@game/ReplicatedFirst/shared/events")

-- [TYPES]
type self = types.InterfaceService

-->

return {
	constructor = function(self: self)
		-- [CONFIG]
		self.TWEEN_PRESET = tweenUtils.getPreset(0.4) --# TweenInfo used for tweening to a stage
		
		-- [IMPORTS]
		self.clientService = import "./clientService"
		
		-- [ENTRIES]
		self.main = script.main:Clone() --# parented in ready()
		self.viewingStage = 1 --# view stage 1 by default (NOT a config)
		self.firstEnter = true --# for instant camera set on first join
		self.maid = maid.new()
		self.menuButtonMaid = maid.new()
	end,
	
	_getStageById = function(self: self, id: number) : Model
		params.expect("number", id)
		
		local static: Folder = workspace:FindFirstChild("static")
		local stages: Folder = static:FindFirstChild("stages")
		
		local stage: Model? = stages:FindFirstChild(tostring(id))
		if stage == nil then
			console.devErr(`No stage found with id "{id}"`)
		end
		
		return stage
	end,
	
	_viewStage = function(self: self, id: number) : Tween
		params.expect("number", id)
		
		local stage: Model = self:_getStageById(self.viewingStage)
		local stageCamera: Part = stage:FindFirstChild("Camera")
		
		local tween: Tween = game.TweenService:Create(
			workspace.CurrentCamera,
			self.TWEEN_PRESET,
			{
				CFrame = stageCamera.CFrame
			}
		)
		tween:Play()
		
		return tween
	end,
	
	enterMenu = function(self: self)
		workspace:WaitForChild("static"):WaitForChild("stages")
		
		--## Set Camera ##--
		do
			local camera: Camera = workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Scriptable
			
			local stage: Model = self:_getStageById(self.viewingStage)
			local stageCamera: Part = stage:WaitForChild("Camera")
			
			if self.firstEnter then
				camera.CFrame = stageCamera.CFrame
				self.firstEnter = false
				task.wait(1) --# hardcoded delay ☠️
			else
				local tween: Tween = self:_viewStage(self.viewingStage) --# tween is auto-played in the function
			end
		end
		
		--## Animate Menu ##--
		--# (assumes everything is already transparent)
		do
			--### Stage Info ###--
			do
				local title = self.main.dynamic.Menu.stageInfo.Title
				local id = self.main.dynamic.Menu.stageInfo.Id
				
				title.AnchorPoint = Vector2.new(0.5, 0.1)
				id.AnchorPoint = Vector2.new(0.5, 0.1)
				
				--## Open Animations ##--
				
				local function animateIn(textLabel: TextLabel)
					game.TweenService:Create(
						textLabel,
						tweenUtils.getPreset(0.75),
						{
							AnchorPoint = Vector2.new(0.5, 0.5),
							TextTransparency = 0
						}
					):Play()
					textLabel.Visible = true
				end
				
				animateIn(title)
				task.delay(0.3, function()
					animateIn(id)
				end)
				
				--## Hover Animations ##--
				
				local function initLabel(textLabel: TextLabel)
					local originalTextColor: Color3 = textLabel.TextColor3
					
					self.maid:GiveTask(textLabel.MouseEnter:Connect(function()
						game.TweenService:Create(
							textLabel,
							tweenUtils.getPreset(0.25),
							{
								TextColor3 = textLabel == id and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(255, 255, 255)
							}
						):Play()
					end))
					
					self.maid:GiveTask(textLabel.MouseLeave:Connect(function()
						game.TweenService:Create(
							textLabel,
							tweenUtils.getPreset(0.25),
							{
								TextColor3 = originalTextColor
							}
						):Play()
					end))
				end
				
				initLabel(title)
				initLabel(id)
			end
			
			--## Controls ##--
			do
				local controls = { --# hardcoded order ╥﹏╥
					self.main.dynamic.Menu.controls.Back,
					self.main.dynamic.Menu.controls.Play,
					self.main.dynamic.Menu.controls.Forward
				}
				
				local callbacks = {
					["Back"] = function()
						if self.viewingStage - 1 == 0 then
							self.viewingStage = #workspace.static.stages:GetChildren()
						else
							self.viewingStage -= 1
						end
						
						self:_viewStage(self.viewingStage)
					end,
					
					["Play"] = function()
						local response: boolean, message: string? = events.selectStage:Fire(self.viewingStage)
						if response == nil then
							console.warn(`No response received after requesting to select stage {self.viewingStage}`)
							return
						end
						
						if response == true then
							self.clientService.selectedStage = self.viewingStage
							self.clientService.stateMachine:setState("playing")
						else
							if message then
								console.warn(`Server rejected stage select request with message: {tostring(message)}`)
							else
								console.warn("Server rejected stage select request with no message")
							end
						end
					end,
					
					["Forward"] = function()
						if self.viewingStage + 1 > #workspace.static.stages:GetChildren() then
							self.viewingStage = 1
						else
							self.viewingStage += 1
						end
						
						self:_viewStage(self.viewingStage)
					end,
				}
				
				task.wait(0.7)
				
				--## hover effects + buttonUp & buttonDown ##--
				
				local function initButton(textButton: TextButton)
					local originalTextColor: Color3 = textButton.TextColor3
					local uiScale: UIScale = textButton:FindFirstChildOfClass("UIScale")
					
					self.maid:GiveTask(textButton.MouseEnter:Connect(function()
						for _, _textButton: TextButton in controls do
							if _textButton == textButton then
								continue
							end
							
							game.TweenService:Create(
								_textButton,
								tweenUtils.getPreset(0.25),
								{ TextTransparency = 0.5 }
							):Play()
						end
						
						soundUtils.wrap("hover")
							:clone()
							:autoDestroy()
							:setParent(game.SoundService.playing)
							:play()
						
						uiScale.Scale = 1.1
					end))
					
					self.maid:GiveTask(textButton.MouseLeave:Connect(function()
						for _, _textButton: TextButton in controls do
							if _textButton == textButton then
								continue
							end
							
							game.TweenService:Create(
								_textButton,
								tweenUtils.getPreset(0.25),
								{ TextTransparency = 0 }
							):Play()
						end
						
						uiScale.Scale = 1
					end))
					
					self.maid:GiveTask(textButton.MouseButton1Down:Connect(function()
						uiScale.Scale = 0.9
						soundUtils.wrap("click")
							:clone()
							:autoDestroy()
							:setParent(game.SoundService.playing)
							:play()
						
						--## Click Functionality ##--
						
						local callback: (() -> nil)? = callbacks[textButton.Name]
						if not callback then
							console.devErr(`Control callback "{textButton.Name}" does not exist`)
						end
						
						callback()
					end))
					
					self.maid:GiveTask(textButton.MouseButton1Up:Connect(function()
						uiScale.Scale = 1
					end))
				end
				
				--## Init ##--
				
				--# make them visible (enable mouse hover icon) first so that they dont come in one by one
				for _, textButton: TextButton in ipairs(controls) do
					textButton.Visible = true
				end
				
				for _, textButton: TextButton in ipairs(controls) do
					--# fade in
					game.TweenService:Create(
						textButton,
						tweenUtils.getPreset(0.75),
						{ TextTransparency = 0 }
					):Play()
					
					--# hover effects
					initButton(textButton)
					task.wait(0.2)
				end
			end
		end
	end,
	
	exitMenu = function(self: self)
		self.maid:DoCleaning()
		
		local controls = { --# hardcoded again lol (but its backwards)
			self.main.dynamic.Menu.controls.Forward,
			self.main.dynamic.Menu.controls.Play,
			self.main.dynamic.Menu.controls.Back
		}
		
		task.defer(function()
			
			--## Hide Controls First ##--
			
			for _, textButton: TextButton in ipairs(controls) do
				if not textButton:IsA("TextButton") then
					continue
				end
				
				local tween: Tween = game.TweenService:Create(
					textButton,
					tweenUtils.getPreset(0.5),
					{
						TextTransparency = 1
					}
				)
				tween:Play()
				tween.Completed:Once(function()
					if tween.PlaybackState == Enum.PlaybackState.Completed then
						return
					end
					textButton.Visible = false
				end)
			end
			
			--## Hide Stage Id Label ##--
			
			local tween1: Tween = game.TweenService:Create(
				self.main.dynamic.Menu.stageInfo.Id,
				tweenUtils.getPreset(0.5),
				{
					TextTransparency = 1
				}
			)
			tween1:Play()
			tween1.Completed:Once(function()
				if tween1.PlaybackState == Enum.PlaybackState.Completed then
					return
				end
				self.main.dynamic.Menu.stageInfo.Id.Visible = false
			end)
			task.wait(0.15)
			
			--## Hide Stage Name Label ##--
			
			local tween2: Tween = game.TweenService:Create(
				self.main.dynamic.Menu.stageInfo.Title,
				tweenUtils.getPreset(1),
				{
					TextTransparency = 1
				}
			)
			tween2:Play()
			tween2.Completed:Once(function()
				if tween2.PlaybackState == Enum.PlaybackState.Completed then
					return
				end
				self.main.dynamic.Menu.stageInfo.Title.Visible = false
			end)
			
			--## Reset Camera ##--
			
			local character: Model = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
			local humanoid: Humanoid  = character:FindFirstChild("Humanoid")
			workspace.CurrentCamera.CameraSubject = humanoid
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end)
	end,
	
	enableMenuButton = function(self: self)
		local menuButton = self.main.dynamic.MenuButton
		local originTextColor: Color3 = menuButton.TextColor3
		local uiScale: UIScale = menuButton.UIScale
		
		--## Hover Effects ##--
		
		self.menuButtonMaid:GiveTask(menuButton.MouseEnter:Connect(function()
			game.TweenService:Create(
				menuButton,
				tweenUtils.getPreset(0.25),
				{
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}
			):Play()
			
			soundUtils.wrap("hover")
				:clone()
				:autoDestroy()
				:setParent(game.SoundService.playing)
				:play()
			
			uiScale.Scale = 1.1
		end))

		self.menuButtonMaid:GiveTask(menuButton.MouseLeave:Connect(function()
			game.TweenService:Create(
				menuButton,
				tweenUtils.getPreset(0.25),
				{
					TextColor3 = originTextColor
				}
			):Play()
			
			uiScale.Scale = 1
		end))
		
		--## Functionality ##--
		
		self.menuButtonMaid:GiveTask(menuButton.MouseButton1Down:Connect(function()
			soundUtils.wrap("click")
				:clone()
				:autoDestroy()
				:setParent(game.SoundService.playing)
				:play()
			
			self.clientService.stateMachine:setState("browsing")
		end))
		
		--## Visibility ##--
		
		self.main.dynamic.MenuButton.Visible = true
		
		game.TweenService:Create(
			menuButton,
			tweenUtils.getPreset(0.25),
			{
				TextTransparency = 0
			}
		):Play()
	end,
	
	disableMenuButton = function(self: self)
		self.menuButtonMaid:DoCleaning()
		
		local menuButton = self.main.dynamic.MenuButton
		
		--## Visibility ##--
		
		local tween: Tween = game.TweenService:Create(
			menuButton,
			tweenUtils.getPreset(0.25),
			{
				TextTransparency = 1
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			if tween.PlaybackState == Enum.PlaybackState.Completed then
				return
			end
			self.main.dynamic.MenuButton.Visible = false
		end)
	end,
	
	ready = function(self: self)
		--## Init ##--
		do
			local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
			self.main.Parent = playerGui
		end
		
		--## Initial UI state ##--
		do
			for _, textButton: TextButton in self.main.dynamic.Menu.controls:GetChildren() do
				if not textButton:IsA("TextButton") then
					continue
				end
				
				textButton.TextTransparency = 1
				textButton.Visible = false
			end
			
			for _, textLabel: TextLabel in self.main.dynamic.Menu.stageInfo:GetChildren() do
				textLabel.TextTransparency = 1
				textLabel.Visible = false
			end
			
			self.main.dynamic.MenuButton.TextTransparency = 1
			self.main.dynamic.MenuButton.Visible = false
		end
	end,
} :: self