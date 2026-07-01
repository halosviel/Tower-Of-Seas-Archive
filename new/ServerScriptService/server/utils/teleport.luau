--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 1
	
	[DESCRIPTION]
	Reliably teleports the player to the given CFrame using magnitude checks.
	Adds 2 studs btw.
	
	[NOTES]
	- Runs asynchronously.
]=]

-- [CONFIG]
local VALID_RADIUS = 8 --# studs from the cframe that is considered a successful teleport
local TIMEOUT = 3 --# seconds to loop-teleport before giving up

-- [REQUIRES]
local console = require("@game/ReplicatedFirst/pip/console")
local params = require("@game/ReplicatedFirst/pip/params")

-->

return function(character: Model, cframe: CFrame)
	task.spawn(function()
		params.expect("Model", character)
		params.expect("CFrame", cframe)
		
		local root: Part = character:WaitForChild("HumanoidRootPart", 5)
		if not root then
			console.warn("Teleport request timed out: No HumanoidRootPart", `player: {tostring(character.Name)}`)
			return
		end
		
		local startTimestamp: number = os.clock()
		local teleported = false
		
		repeat
			task.wait() --# do NOT move wait below. only works if here bc of loading or smth
			root.CFrame = cframe + Vector3.new(0, 2, 0)
			
			local magnitude: number = (root.Position - cframe.Position).Magnitude
			if magnitude <= VALID_RADIUS then
				teleported = true
			end
		until teleported == true or os.clock() - startTimestamp >= TIMEOUT
		
		if os.clock() - startTimestamp >= TIMEOUT then
			console.warn("Teleport request timed out", `player: {tostring(character.Name)}`)
			return
		end
	end)
end