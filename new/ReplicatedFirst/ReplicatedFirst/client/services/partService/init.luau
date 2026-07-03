--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 03
	
	[DESCRIPTION]
	The service for making client parts work.
	
	[NOTES]
	- Tags are legacy (not bothered to remove).
	- We now use the name of the part.
]=]

-- [REQUIRES]
local types = require("./_types")
local console = require("@game/ReplicatedFirst/pip/console")

-- [TYPES]
type self = types.PartService

-->

return {
	constructor = function(self: self)
		self.names = {"KillPart", "Conveyor", "Slider", "Spinner"}
		self.modules = {}
	end,
	
	ready = function(self: self)
		
		--[[
			Check if the part is:
			- A BasePart
			- Is whitelisted in self.names (probs redundant but whatevs)
			- Has a function in self.modules
		]]
		local function checkPart(part: Part)
			if not part:IsA("BasePart") then
				return
			end
			
			local partName: string = part.Name
			if not table.find(self.names, part.Name) then
				return
			end
			
			local callbackName: string = `{partName:sub(1, 1):lower()}{partName:sub(2, #partName)}`
			local callback: (( part: Part ) -> nil)? = self.modules[callbackName]
			if not callback then
				return
			end
			
			--print("calling for", part)
			callback(part)
		end
		
		--## Cache Functions ##--
		
		for _, moduleScript: ModuleScript in script:GetChildren() do
			local module = require(moduleScript)
			self.modules[moduleScript.Name] = module
		end
		
		--## Initiate Parts ##--
		
		for _, stage: Model in workspace.static.stages:GetChildren()do
			local model: Model = stage:FindFirstChildOfClass("Model")
			if not model then
				console.warn(`Ignoring parts for stage {stage.Name}: No stage model found`)
				continue
			end
			
			for _, obj: Instance in model:GetChildren() do
				checkPart(obj)
			end
		end
	end,
} :: self