return function(conveyor: Part)
	local texture = conveyor:FindFirstChild("Texture")
	local speed: number = conveyor:GetAttribute("Speed")
	
	game.RunService.Heartbeat:Connect(function()
		texture.OffsetStudsV = -(workspace.DistributedGameTime 
			* speed
		) % texture.StudsPerTileV
	end)
	
	conveyor.AssemblyLinearVelocity = conveyor.CFrame.lookVector * speed
end