local marketPlaceService = game:GetService("MarketplaceService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local _workspace = game:GetService("Workspace")
local players = game:GetService("Players")

local self = players.LocalPlayer

local currentSong = nil
local previousSong = nil
local hasPass = false

local selectedCamera = 1

local function playRandomSong()
	local songs = _workspace.songs:GetChildren()
	if #songs == 0 then return end

	repeat
		currentSong = songs[math.random(1, #songs)]
		wait()
	until currentSong ~= previousSong

	previousSong = currentSong
	currentSong:Play()
	
	currentSong.Ended:Wait()
	currentSong:Stop()
	playRandomSong()
end

local callCoreGui do
	function callCoreGui(Method, ...)
		local result = {}

		for attempts = 1, 7 do
			result = {pcall(starterGui[Method], starterGui, ...)}
			if result[1] then break end

			runService.Stepped:Wait()
		end

		return unpack(result)
	end
end

repeat wait() until _workspace:FindFirstChild("Camera")
	and replicatedStorage:FindFirstChild("toClient")
	and replicatedStorage:FindFirstChild("toServer")

local mainFrame = script.Parent:WaitForChild("mainFrame")
local camera = _workspace:WaitForChild("Camera")

local function tweenCamera(length, cframe)
	local tweenInfo = TweenInfo.new(length, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	tweenService:Create(camera, tweenInfo, {CFrame = cframe}):Play()
end

pcall(callCoreGui, "SetCore", "ResetButtonCallback", false)
mainFrame.stageNumber.Text = string.format("%s/%s", selectedCamera, #_workspace.stages:GetChildren())

replicatedStorage.toClient.OnClientEvent:Connect(function(event, arg1)
	if event == "start" then
		camera.CameraType = Enum.CameraType.Scriptable

		mainFrame.Visible = true
		mainFrame.stageName.Text = _workspace.stages[selectedCamera]:FindFirstChildWhichIsA("Model").Name
		
		camera.CFrame = _workspace.stages[1].camera.CFrame
	elseif event == "chatMessage" then
		starterGui:SetCore("ChatMakeSystemMessage", {
			Text = arg1,
			Color = Color3.fromRGB(252, 66, 70)
		})
	end
end)

local lastResetInput = 0
userInputService.InputBegan:Connect(function(input, typing)
	if typing or script.Parent.mainFrame.donateButton.Visible then return end
	if input.KeyCode == Enum.KeyCode.R then
		if os.time() - lastResetInput < 1 then
			replicatedStorage.toServer:FireServer("reset", "r")
			mainFrame.resetLabel.Visible = false
			return
		end

		lastResetInput = os.time()
		mainFrame.resetLabel.Visible = true
		wait(1)
		mainFrame.resetLabel.Visible = false
	end
end)

mainFrame.toggleR.MouseButton1Click:Connect(function()
	selectedCamera += 1

	local stage = _workspace.stages:FindFirstChild(selectedCamera)

	if stage then
		mainFrame.stageName.Text = stage:FindFirstChildWhichIsA("Model").Name
		tweenCamera(1, _workspace.stages[selectedCamera].camera.CFrame)
	else
		selectedCamera = 1

		mainFrame.stageName.Text = _workspace.stages:FindFirstChild("1")
		:FindFirstChildWhichIsA("Model").Name

		tweenCamera(1, _workspace.stages["1"].camera.CFrame)
	end

	mainFrame.stageNumber.Text = string.format("%s/%s", selectedCamera, #_workspace.stages:GetChildren())
end)

mainFrame.toggleL.MouseButton1Click:Connect(function()
	selectedCamera -= 1

	local stage = _workspace.stages:FindFirstChild(selectedCamera)

	if stage then
		mainFrame.stageName.Text = stage:FindFirstChildWhichIsA("Model").Name
		tweenCamera(1, _workspace.stages[selectedCamera].camera.CFrame)
	else
		selectedCamera = #_workspace.stages:GetChildren()
		mainFrame.stageName.Text = _workspace.stages[#_workspace.stages:GetChildren()]
		:FindFirstChildWhichIsA("Model").Name
		
		tweenCamera(1, _workspace.stages[#_workspace.stages:GetChildren()].camera.CFrame)
	end

	mainFrame.stageNumber.Text = string.format("%s/%s", selectedCamera, #_workspace.stages:GetChildren())
end)

mainFrame.playButton.MouseButton1Click:Connect(function()
	if not self.Character then return end

	local humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end
	if humanoid.Health == 0 then return end

	replicatedStorage.toServer:FireServer("start", selectedCamera)
	camera.CameraType = Enum.CameraType.Custom

	pcall(callCoreGui, "SetCore", "ResetButtonCallback", true)

	for _, c in pairs(mainFrame:GetChildren()) do
		c.Visible = false
	end

	mainFrame.exit.Visible = true
end)

mainFrame.exit.MouseButton1Click:Connect(function()
	if not self.Character then return end
	if not self.Character:FindFirstChild("humanoid") then return end
	if self.Character.humanoid.Health == 0 then return end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = _workspace.stages[self.leaderstats.Stage.Value].camera.CFrame

	pcall(callCoreGui, "SetCore", "ResetButtonCallback", false)

	for _, c in pairs(mainFrame:GetChildren()) do
		if c.Name == "exit" or c.Name == "infoFrame" or c.Name == "resetLabel" then continue end
		c.Visible = true
	end

	mainFrame.exit.Visible = false
end)

mainFrame.infoLabel.MouseEnter:Connect(function()
	script.Parent.mainFrame.infoFrame.Visible = true
end)

mainFrame.infoLabel.MouseLeave:Connect(function()
	script.Parent.mainFrame.infoFrame.Visible = false
end)

mainFrame.donateButton.MouseButton1Click:Connect(function()
	pcall(function()
		marketPlaceService:PromptProductPurchase(self, 1224488648)
	end)
end)

task.defer(playRandomSong)