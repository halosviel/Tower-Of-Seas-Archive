local module = {}

local serverStorage = game:GetService("ServerStorage")
local _mainModule_ = require(serverStorage.remoteHandlers._mainModule_)

module.run = function(self, event, arg1, arg2)
	_mainModule_.ban(
		{
			["player"] = self,
			["embedDescription"] = string.format("Missing parameter (arg1) when FireServer() was called."
					.."```yaml\n event: %s```", tostring(event)),
			["kickAction"] = "RemoteEvent manipulation.",
			["kickDetails"] = "Missing an essential parameter (arg1) when calling remoteEvent 'toServer'. No false positives."
		}
	)
end

return module