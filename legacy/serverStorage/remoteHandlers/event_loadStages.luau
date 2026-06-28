local module = {}

local _mainModule_ = require(script.Parent._mainModule_)
local _workspace = game:GetService("Workspace")

module.run = function(self, arg1, arg2)
	_mainModule_.ban(
		{
			["player"] = self,
			["embedDescription"] = string.format(
				"A print was found in %s's console. ```yaml\n Message: %s```",
				self.Name, tostring(arg1)),
			["kickAction"] = "Console prints.",
			["kickDetails"] = "Detected a print in your console. Unlikey false positives. \n"
				..string.format("Print message: %s", tostring(arg1))
		}
	)
end

return module