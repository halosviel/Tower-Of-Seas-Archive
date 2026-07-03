return function(killPart: Part)
	killPart.Touched:Connect(function(hit: Instance)
		local character: Model = game.Players.LocalPlayer.Character
		if not character then
			return
		end
		
		if hit:IsDescendantOf(character) then
			local humanoid: Humanoid = character:FindFirstChild("Humanoid")
			if not humanoid then
				return
			end
			if humanoid.Health == 0 then
				return
			end
			
			humanoid.Health = 0
			--print("ded")
		end
	end)
end