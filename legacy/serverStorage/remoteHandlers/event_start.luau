local module = {}

local _workspace = game:GetService("Workspace")

module.run = function(self, arg1)
	if not self.Character then return end

	local humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end

	self.leaderstats.Stage.Value = tostring(arg1)
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	humanoid.MaxHealth = 100

	self.Character:SetPrimaryPartCFrame(_workspace.stages[arg1].spawn.CFrame * CFrame.new(0, 2, 0))
end

return module