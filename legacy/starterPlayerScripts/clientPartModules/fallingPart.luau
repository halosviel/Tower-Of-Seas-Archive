local module = {}

local tweenService = game:GetService("TweenService")

function module:run(fallingTile)
	while not fallingTile:FindFirstChild("cooldown") do wait() end

	local originalCFrame = fallingTile.CFrame
	local cooldown = fallingTile.cooldown.Value
	local falling = false
	local con = nil

	fallingTile.cooldown:Destroy()

	con = fallingTile.Touched:Connect(function(hit)
		if not hit.Parent or falling then return end

		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then return end

		falling = true
		wait(1)

		local a, e = pcall(function()
			local tween = tweenService:Create(
				fallingTile,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Transparency = 1, CFrame = originalCFrame - Vector3.new(0, 30, 0)}
			)

			tween:Play()
			tween.Completed:Wait()

			wait(cooldown)

			fallingTile.Transparency = 0
			fallingTile.CFrame = originalCFrame
			
			wait(1)
			falling = false
		end)

		if not a then
			warn(string.format("⚠️ Falling Part disconnected: %s", e))
			con:Disconnect()
		end
	end)
end

return module