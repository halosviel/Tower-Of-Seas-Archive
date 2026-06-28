local module = {}

local runService = game:GetService("RunService")

function module:run(spinner)
	while not spinner:FindFirstChild("turnSpeed") do wait() end
	
	local con = nil
	local turnSpeed = spinner.turnSpeed.Value
	spinner.turnSpeed:Destroy()

	con = runService.Heartbeat:Connect(function()
		local a, e = pcall(function()
			spinner.CFrame *= CFrame.Angles(0, math.rad(turnSpeed / 360), 0)
		end)

		if not a then
			warn(string.format("⚠️ Spinner disconnected: %s", e))
			con:Disconnect()
		end
	end)
end

return module