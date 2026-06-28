local module = {}

function module:run(boolValue)
	if not boolValue.Parent:IsA("BasePart") then return end
	
	local con = nil
	
	con = boolValue.Parent.Touched:Connect(function(hit)
		if not hit.Parent then return end
		
		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then return end

		local a, e = pcall(function()
			humanoid.MaxHealth = 0
			humanoid.Health = 0
			humanoid.Parent:BreakJoints()
			humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		end)
		
		if not a then
			warn(string.format("⚠️ killPart disconnected: %s", e))
			con:Disconnect()
		end
	end)
	
	boolValue:Destroy()
end

return module