--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 03
	
	[DESCRIPTION]
	The custom hitbox handler for non-strict hitboxes (we ditched
	.Touched on killparts).
	
	[NOTES]
	- The hitbox (accessory) itself is kept in StarterCharacterScripts.
]=]

local function onCharacterAdded(character: Model)
	local hitbox: Accessory = character:WaitForChild("Hitbox")
	local handle: Part = hitbox:WaitForChild("Handle")
	
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	
	handle.Touched:Connect(function(hit: Instance)
		if hit:IsA("BasePart") and hit.Name == "KillPart"
			or hit:IsA("BasePart") and table.find(hit:GetTags(), "KillPart")
		then
			humanoid.Health = 0
		end
	end)
end

game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if game.Players.LocalPlayer.Character then
	onCharacterAdded(game.Players.LocalPlayer.Character)
end