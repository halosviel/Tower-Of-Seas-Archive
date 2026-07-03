--[=[
    [INFO]
    author: @halosviel
    created: 2026 July 03
    
    [DESCRIPTION]
    The code to make the player stay on top of moving/spinning platforms.
]=]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local previousCFrame: CFrame? = nil
local previousPart: BasePart? = nil

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

RunService.RenderStepped:Connect(function()
	local character: Model? = Players.LocalPlayer.Character
	if not character then
		return
	end
	
	local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	
	local root: BasePart? = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	
	raycastParams.FilterDescendantsInstances = { character }
	
	local origin: Vector3 = root.Position + Vector3.new(0, -root.Size.Y * 1.5 + 0.1, 0)
	local direction: Vector3 = Vector3.new(0, -0.2, 0)
	
	local result: RaycastResult? = workspace:Raycast(origin, direction, raycastParams)
	local movingPart: BasePart? = result and result.Instance
	
	if movingPart and previousCFrame and movingPart == previousPart then
		root.CFrame = movingPart.CFrame:ToWorldSpace(previousCFrame:ToObjectSpace(root.CFrame))
	end
	
	previousPart = movingPart
	previousCFrame = movingPart and movingPart.CFrame
end)