local module = {}

local _mainModule_ = require(script.Parent._mainModule_)

module.run = function(self, arg1)
	_mainModule_.ban(
		{
			["player"] = self,
			["embedDescription"] = string.format(
				"A suspicious asset was injected into %s's CoreGui. \n ```yaml\nAsset: %s```",
				self.Name, arg1),
			["kickAction"] = "Asset injection.",
			["kickDetails"] = string.format(
				"You injected a suspicious asset into the CoreGui.",
				tostring(arg1.ClassName), tostring(arg1.Name))

		}
	)
end

return module 