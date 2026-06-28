local module = {}

local tweenService = game:GetService("TweenService")

function module:run(slider)
	repeat wait() until slider:FindFirstChild("stayTime")
		and slider:FindFirstChild("travelTime") 
		and slider:FindFirstChild("finish")
	
	local stayTime = slider.stayTime.Value
	local travelTime = slider.travelTime.Value
	local finish = slider.finish.Position
	
	slider.stayTime:Destroy()
	slider.travelTime:Destroy()
	slider.finish:Destroy()

	local originalPosition = slider.Position
	local tweenInfo = TweenInfo.new(
		travelTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut
	)

	while true do
		local a, e = pcall(function()
			local forward = tweenService:Create(slider, tweenInfo, {Position = finish})
			forward:Play()
			forward.Completed:Wait()
			
			wait(stayTime)
			
			local back = tweenService:Create(slider, tweenInfo, {Position = originalPosition})
			back:Play()
			back.Completed:Wait()
			
			wait(stayTime)
		end)
		
		if not a then
			warn(string.format("⚠️ Slider disconnected: %s", e))
			break
		end
	end
end

return module