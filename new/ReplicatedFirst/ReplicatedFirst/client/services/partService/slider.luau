-- [REQUIRES]
local tweenUtils = require("@game/ReplicatedFirst/shared/utils/tweenUtils")

-->

return function(slider: Part)
	local pauseTime: number = slider:GetAttribute("PauseTime")
	local travelTime: number = slider:GetAttribute("TravelTime")
	
	local finish: Part = slider:FindFirstChild("Finish")
	local finishPos: Vector3 = slider.Finish.Position
	finish:Destroy()
	
	local originalPosition = slider.Position
	local tweenInfo = tweenUtils.getPreset(travelTime)
	
	task.defer(function()
		while true do
			task.wait(pauseTime)
			
			local forward: Tween = game.TweenService:Create(slider, tweenInfo, { Position = finishPos })
			forward:Play()
			forward.Completed:Wait()

			task.wait(pauseTime)

			local back: Tween = game.TweenService:Create(slider, tweenInfo, { Position = originalPosition })
			back:Play()
			back.Completed:Wait()
		end
	end)
end