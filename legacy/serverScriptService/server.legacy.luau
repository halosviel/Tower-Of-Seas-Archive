local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local dataStoreService = game:GetService("DataStoreService")
local teleportService = game:GetService("TeleportService")
local physicsService = game:GetService("PhysicsService")
local serverStorage = game:GetService("ServerStorage")
local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local _workspace = game:GetService("Workspace")
local players = game:GetService("Players")

physicsService:CreateCollisionGroup("playerCollision")
physicsService:CollisionGroupSetCollidable("playerCollision", "playerCollision", false)

local remoteParams = {"start", "reset", "loadButtons", "loadStages", "loadAssets"}
local bannedPlayers = dataStoreService:GetDataStore("bannedPlayers")

_workspace.Name = httpService:GenerateGUID(true)
players.Name = httpService:GenerateGUID(true)
replicatedStorage.Name = httpService:GenerateGUID(true)
serverScriptService.Name = httpService:GenerateGUID(true)
_workspace.stages:Clone().Parent = replicatedStorage

local function characterAdded(character)
	local self = players:GetPlayerFromCharacter(character)

	if self.leaderstats.Stage.Value ~= 0 then
		wait(0.1)
		character:SetPrimaryPartCFrame(
			_workspace.stages[self.leaderstats.Stage.Value].spawn.CFrame + Vector3.new(0, 2, 0)
		)
	end

	character.HumanoidRootPart.Name = "root"
	character.Humanoid.Name = "humanoid"

	for _, c in pairs(character:GetChildren()) do
		if not c:IsA("BasePart") then continue end
		physicsService:SetPartCollisionGroup(c, "playerCollision")
	end
end

local function connectPart(basePart)
	local module = serverStorage.partHandlers:FindFirstChild(basePart.Name)
	if not module then return end
	require(module):run(basePart)
end

replicatedStorage.toServer.OnServerEvent:Connect(function(self, event, arg1, arg2)
	if not event then
		require(serverStorage.remoteHandlers["ban_missingEvent"]).run(self, event, arg1, arg2)
		return
	end

	if not table.find(remoteParams, tostring(event)) then
		require(serverStorage.remoteHandlers["ban_invalidEvent"]).run(self, event, arg1, arg2)
		return
	end

	if not arg1 then
		require(serverStorage.remoteHandlers["ban_missingArg"]).run(self, event, arg1, arg2)
		return
	end

	require(serverStorage.remoteHandlers[string.format("event_%s", event)]).run(self, arg1, arg2)
end)

players.PlayerAdded:Connect(function(self)
	if bannedPlayers:GetAsync(self.UserId) then
		self:Kick("Banned. \n\n You do not have access to play the game.")
		return
	end

	if self.AccountAge < 500 then
		self:Kick(string.format("%s%s%s", "Sorry.\n\n",
			"This game is only available to accounts with an account age of over 500 days.\n\n",
			string.format("Your account age: %s/500 days.\n", self.AccountAge)))
		return
	end
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = self

	local Stage = Instance.new("NumberValue")
	Stage.Name = "Stage"
	Stage.Parent = leaderstats

	self.CharacterAdded:Connect(characterAdded)
	if self.Character then
		characterAdded(self.Character)
	end
	
	replicatedStorage.toClient:FireClient(self, "start")
end)

_workspace.DescendantAdded:Connect(connectPart)
for _, part in pairs(_workspace:GetDescendants()) do
	connectPart(part)
end

game:BindToClose(function()
	if runService:IsStudio() then return end

	replicatedStorage.toClient:FireAllClients("chatMessage",
		"{Server}: This server will shut down for updates."
	)

	wait(2)
	
	local a, e = pcall(function()
		teleportService:TeleportPartyAsync(game.PlaceId, players:GetPlayers())
	end)
	
	if not a then
		replicatedStorage.toClient:FireAllClients("chatMessage",
			"{Server}: Failed to teleport all players. Please rejoin instead."
		)
	end
end)