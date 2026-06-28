local module = {}

local serverStorage = game:GetService("ServerStorage")
local _mainModule_ = require(serverStorage.remoteHandlers._mainModule_)

module.run = function(self, event, arg1, arg2)
	_mainModule_.ban(
		{
			["player"] = self,
			["embedDescription"] = string.format(
				"Missing parameter (event) when FireServer() was called. ```yaml\n arg1: %s \n arg2: %s```",
				tostring(arg1), tostring(arg2)),
			["kickAction"] = "RemoteEvent manipulation.",
			["kickDetails"] = "Missing an essential parameter (event) when calling RemoteEvent 'toServer'. No false positives."
		}
	)
end

return module