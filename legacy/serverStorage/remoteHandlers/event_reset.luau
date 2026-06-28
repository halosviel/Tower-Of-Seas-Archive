local module = {}

local _workspace = game:GetService("Workspace")

module.run = function(self)
	self:LoadCharacter()
end

return module