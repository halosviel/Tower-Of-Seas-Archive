--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 03
	
	[DESCRIPTION]
	A dedicated script for Teleportation Tower.
]=]

local cooldowns = {}

for _, portal: Model in pairs(workspace.static.stages["22"]:FindFirstChildOfClass("Model").Portals:GetChildren()) do
	if not portal:FindFirstChild("Enter") then
		continue
	end
	portal.Enter.Touched:Connect(function(hit: Instance)
		if table.find(cooldowns, hit.Parent) then
			return
		end
		
		local humanoid: Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		
		table.insert(cooldowns, hit.Parent)
		task.defer(function()
			wait(0.1)
			table.remove(cooldowns, table.find(cooldowns, hit.Parent))
		end)
		
		hit.Parent:PivotTo(portal.Parent[tonumber(portal.Name) + 1].Exit.CFrame)
	end)
end