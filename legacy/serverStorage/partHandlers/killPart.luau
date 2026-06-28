local module = {}

local serverStorage = game:GetService("ServerStorage")
local touchHandler = require(serverStorage.touchHandler)

function module:run(killPart)
	touchHandler.new(killPart):Connect(function(hit)
		pcall(function()
			hit.Parent.humanoid.MaxHealth = 0
			hit.Parent.humanoid.Health = 0
			hit.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		end)
	end)
end

return module