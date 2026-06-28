local replicatedStorage = game:GetService("ReplicatedStorage")
local contentProvider = game:GetService("ContentProvider")
local runService = game:GetService("RunService")
local logService = game:GetService("LogService")
local starterGui = game:GetService("StarterGui")
local _workspace = game:GetService("Workspace")
local players = game:GetService("Players")

local buttonNames = {"BubbleChat", "Chat", "Freecam", "RbxCameraUI", "ui", "mobileShiftlock"}
local clientPartModules = script.Parent:WaitForChild("clientPartModules")

local currentStage = nil
local previousStage = nil

local logConnection = nil
local guiConnection = nil

local self = players.LocalPlayer

repeat wait() until self:FindFirstChild("leaderstats")
	and self.leaderstats:FindFirstChild("Stage")
	and _workspace:FindFirstChild("stages")

self.leaderstats.Stage:GetPropertyChangedSignal("Value"):Connect(function()
	local stage = _workspace.stages[self.leaderstats.Stage.Value]
	if not stage then return end

	if currentStage == stage then return end
	currentStage = stage

	pcall(function()
		replicatedStorage.stages[previousStage.Name]:Clone().Parent = _workspace.stages
		previousStage:Destroy()
	end)

	previousStage = stage

	for _, d in pairs(stage:FindFirstChildWhichIsA("Model"):GetDescendants()) do
		task.defer(function()
			local module = clientPartModules:FindFirstChild(d.Name)
			if not module then return end

			require(module):run(d)
		end)
	end
end)

logConnection = logService.MessageOut:Connect(function(message, _type)
	wait(1)
	if _type ~= Enum.MessageType.MessageOutput or string.find(message, "Server")
		or string.find(message, "MarketplaceService") then
		return
	end

	local a, e = pcall(function()
		replicatedStorage.toServer:FireServer("loadStages", message)
	end)

	if not a then
		logConnection:Disconnect()
		while true do end
	end
end)

guiConnection = self.PlayerGui.ChildAdded:Connect(function(gui)
	if table.find(buttonNames, gui.Name) then return end
	logConnection:Disconnect()

	local children = {}

	for _, c in pairs(gui:GetChildren()) do
		table.insert(children, c.Name)
	end

	local a, e = pcall(function()
		replicatedStorage.toServer:FireServer("loadButtons", gui, table.concat(children, ", "))
	end)

	if not a then
		guiConnection:Disconnect()
		while true do end
	end
end)

contentProvider:PreloadAsync({game:GetService("CoreGui")}, function(asset)
	if not asset:find("rbxassetid://") then return end
	
	local a, e = pcall(function()
		replicatedStorage.toServer:FireServer("loadAssets", asset)
	end)

	if not a then
		while true do end
	end
end)

task.defer(function()
	local previousCFrame = nil
	local previousPart = nil

	runService.RenderStepped:Connect(function()
		pcall(function()
			local humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
			local root = self.Character:FindFirstChild("root")

			if humanoid.Health == 0 then return end

			local origin = root.Position + Vector3.new(0, -root.Size.Y * 1.5 + 0.1, 0)
			local lookDirection = origin + Vector3.new(0, -0.11, 0)
			local raycast = Ray.new(origin, (lookDirection - origin).unit * 0.1 * 2)
			local movingPart = _workspace:FindPartOnRay(raycast, self.Character)

			if movingPart and previousCFrame and movingPart == previousPart then
				root.CFrame = movingPart.CFrame:toWorldSpace(previousCFrame:toObjectSpace(root.CFrame))
			end

			previousPart = movingPart
			previousCFrame = movingPart and movingPart.CFrame
		end)
	end)
end)