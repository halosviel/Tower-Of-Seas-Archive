local module = {}

local runService = game:GetService("RunService")
local _workspace = game:GetService("Workspace")

function module:run(conveyor)
	repeat wait() until conveyor:FindFirstChild("speed") and conveyor:FindFirstChild("texture")

	local con = nil
	local speed = conveyor.speed.Value
	conveyor.speed:Destroy()

	con = runService.Heartbeat:Connect(function()
		pcall(function()
			conveyor.texture.OffsetStudsV = -(_workspace.DistributedGameTime 
				* speed
			) % conveyor.texture.StudsPerTileV
		end)
	end)
end

return module