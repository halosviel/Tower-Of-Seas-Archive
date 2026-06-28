local module = {}

function module:run(conveyor)
	while not conveyor:FindFirstChild("speed") do wait() end
	conveyor.Velocity = conveyor.CFrame.lookVector * conveyor.speed.Value
end

return module