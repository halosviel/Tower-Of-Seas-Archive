local module = {}

local serverStorage = game:GetService("ServerStorage")
local _mainModule_ = require(serverStorage.remoteHandlers._mainModule_)

module.run = function(self, event, arg1, arg2)
	_mainModule_.ban(
		{
			["player"] = self,
			["embedDescription"] = string.format(
				"Invalid parameter (event) \n ```yaml\n Event: %s```",
				tostring(event)),
			["kickAction"] = "RemoteEvent manipulation.",
			["kickDetails"] = "A false parameter (event) was passed when calling RemoteEvent 'toServer'. No false positives."
		}
	)
end

return module