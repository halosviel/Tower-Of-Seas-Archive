return function(spinner: Part)
	local speed: number = spinner:GetAttribute("RotationSpeed")
	
	game.RunService.Heartbeat:Connect(function()
		spinner.CFrame *= CFrame.Angles(0, math.rad(speed / 360), 0)
	end)
end