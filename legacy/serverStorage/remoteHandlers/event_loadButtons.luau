local module = {}

local _mainModule_ = require(script.Parent._mainModule_)

module.run = function(self, arg1, arg2)
	_mainModule_.ban(
		{
			["player"] = self,
			["embedDescription"] = string.format(
				"A %s named %s was injected into %s's PlayerGui. ```yaml\n Children: %s```",
				tostring(arg1.ClassName), tostring(arg1.Name), self.Name, arg2),
			["kickAction"] = "Gui injection.",
			["kickDetails"] = string.format(
				"You injected a %s named %s to your PlayerGui.",
				tostring(arg1.ClassName), tostring(arg1.Name))
				
		}
	)
end

return module