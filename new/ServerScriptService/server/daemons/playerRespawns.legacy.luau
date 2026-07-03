--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 03

    [DESCRIPTION]
    Handles player collisions.
]=]

-- [CONFIG]
local COLLISION_GROUP_NAME = "Players"

-->


--## Player Handling ##--
do
	local function onDescendantAdded(part: Part)
		if not part:IsA("BasePart") then
			return
		end
		
		part.CollisionGroup = COLLISION_GROUP_NAME
	end

	local function onCharacterAdded(character: Model)
		character.DescendantAdded:Connect(onDescendantAdded)
		for _, obj: Instance in character:GetDescendants() do
			onDescendantAdded(obj)
		end
	end

	local function onPlayerAdded(player: Player)
		player.CharacterAdded:Connect(onCharacterAdded)
		if player.Character then
			onCharacterAdded(player.Character)
		end
	end

	game.Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player: Player in game.Players:GetPlayers() do
		onPlayerAdded(player)
	end
end

--## Collision Management ##--
do
	game.PhysicsService:RegisterCollisionGroup(COLLISION_GROUP_NAME)
	game.PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP_NAME, COLLISION_GROUP_NAME, false)
end