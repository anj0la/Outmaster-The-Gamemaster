local PlayerManager = {}

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local ServerScriptService = game:GetService('ServerScriptService')
local Teams = game:GetService('Teams')

-- Module Folders
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts
local GamemasterChance = require(UtilityModules:WaitForChild('GamemasterChance'))
-- local ReplicatedStorage = game:GetService('ReplicatedStorage)

-- Map Variables (ONLY USED FOR RESPAWNING)
local lobby = workspace:WaitForChild('Lobby')
local lobbySpawn = lobby:WaitForChild('SpawnLocation')

-- Local Variables
local activePlayers = {}
local queuedPlayers = {}

-- Local Functions
local function loadLeaderstats(player)
	-- Setup leaderboard stats
	local leaderstats = Instance.new('Model')
	leaderstats.Name = 'leaderstats'
    leaderstats.Parent = player

	local level = Instance.new('IntValue')
	level.Name = 'Level'
    level.Parent = leaderstats
	level.Value = 0 -- saved value

	local xp = Instance.new('IntValue')
	xp.Name = 'XP'
    xp.Parent = player
	xp.Value = 0 -- saved value

    -- MIGHT REMOVE AND PUT INTO SERVERSTORAGE TO DECREASE EXPLOITABILITY
	local roundXP = Instance.new('IntValue')
	roundXP.Name = 'RoundXP'
    roundXP.Parent = player
	roundXP.Value = 0 -- saved value
end

local function onPlayerJoin()
	--if a player who creates the server (first player in the game) loads into the game before the player added event can be fired,
	-- then the actions of the player added event are performed on that player

	for _, player in ipairs(Players:GetPlayers()) do
		-- check if the player already has leaderstats
		if not player:FindFirstChild('leaderstats') then
			loadLeaderstats(player)
		end

		-- set the respawn location to the lobby spawn
		player.RespawnLocation = lobbySpawn

		-- check if the player is already in the queuedPlayers table
		local isInQueue = false
		for _, queuedPlayer in ipairs(queuedPlayers) do
			if queuedPlayer == player then
				isInQueue = true
				break
			end
		end

		-- if the player is not in the queue, add them
		if not isInQueue then
			table.insert(queuedPlayers, player)
			print('adding player to queue', player)
			print('new queue: ', queuedPlayers)
		end

		-- move the player to the spectator team (if needed)
		-- player.Team = Teams:WaitForChild('Spectators')
	end			
end


local function removePlayerFromQueue(player)
	for playerKey, whichPlayer in ipairs(queuedPlayers) do
		if whichPlayer == player then
			table.remove(queuedPlayers, playerKey)
		end
	end
end

local function removePlayerFromGame(player)
	local deletedPlayer = false
	for playerKey, whichPlayer in ipairs(queuedPlayers) do
		if whichPlayer == player then
			table.remove(queuedPlayers, playerKey)
			deletedPlayer = true
		end
	end
	
	-- if we haven't deleted the player from the queue (i.e., they don't exist in the queue),
	-- we know they are in the active queue and must delete them from it
	if not deletedPlayer then 
		for playerKey, whichPlayer in ipairs(activePlayers) do
			if whichPlayer == player then
				table.remove(activePlayers, playerKey)
			end
		end
	end
end

-- Module Functions
function PlayerManager.getPlayer(playerId)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == playerId then
			return player
		end
	end
	return nil -- if the player is no longer in the game, then we return nil
end

function PlayerManager.getPlayerCount()
	return #Players:GetPlayers()
end

function PlayerManager.removePlayer(player)
	player.Character:Destroy()
	for _, item in ipairs(player.Backpack:GetChildren()) do
		item:Destroy()
	end
end

function PlayerManager.getQueuedPlayers()
	return queuedPlayers
end

function PlayerManager.getActivePlayers()
	return activePlayers
end

function PlayerManager.removePlayerFromQueue(player)
	for playerKey, whichPlayer in ipairs(queuedPlayers) do
		if whichPlayer == player then
			table.remove(queuedPlayers, playerKey)
			player.Team = Teams:WaitForChild('Spectators') -- moving the player to the spectator team
		end
	end
end

function PlayerManager.addPlayersToActive()
    for i = #queuedPlayers, 1, -1 do
        local player = queuedPlayers[i]
        table.remove(queuedPlayers, i)
        table.insert(activePlayers, player)
        player.Team = Teams:WaitForChild('Players') -- moving the players to the players team
    end
end

function PlayerManager.removePlayersFromActive()
    for i = #activePlayers, 1, -1 do
        local player = activePlayers[i]
        table.remove(activePlayers, i)
        table.insert(queuedPlayers, player)
        player.Team = Teams:WaitForChild('Spectators') -- moving the players to the spectator team
    end
end

function PlayerManager.assignGamemaster()
	local gamemaster = GamemasterChance.selectGamemaster(activePlayers)
	gamemaster.Team = Teams:WaitForChild('Gamemaster')
end

function PlayerManager.getGamemaster()
	local gamemasterTeam = Teams:WaitForChild('Gamemaster')
	return gamemasterTeam:GetPlayers()[1]
end

function PlayerManager.spawnPlayersInGame()
	local chosenMapSpawns = workspace:WaitForChild('SpawnLocations'):GetChildren()
	print('chosen map spawns', chosenMapSpawns)
	local players = Teams:WaitForChild('Players'):GetPlayers()
	for i = #players, 1, -1 do
        local player = players[i]
		local character = player.Character
		local randomIndex = math.random(1, #chosenMapSpawns)
		character.HumanoidRootPart.CFrame = chosenMapSpawns[randomIndex].CFrame
        -- player.RespawnLocation = chosenMapSpawns[randomIndex]
		-- player:LoadCharacter()
    end
end

function PlayerManager.spawnGamemasterInGame()
	local gamemaster = PlayerManager.getGamemaster()
	local character = gamemaster.Character

	-- probably will have a 'GamemasterSpawnLocation' in the map, but for now, will just assign a random index
	local chosenMapSpawns = workspace:WaitForChild('SpawnLocations'):GetChildren()
	local randomIndex = math.random(1, #chosenMapSpawns)
	-- the three lines of code above will be replaced into one line containing the gamemaster spawn when completed
	print('chosen map spawns', chosenMapSpawns)

	character.HumanoidRootPart.CFrame = chosenMapSpawns[randomIndex].CFrame
	--gamemaster.RespawnLocation = chosenMapSpawns[randomIndex]
	--gamemaster:LoadCharacter()
end

function PlayerManager.spawnPlayersInLobby()
	-- we run this code AFTER the players have been assigned back to the waiting queue
	for i = #queuedPlayers, 1, -1 do
        local player = queuedPlayers[i]
		local character = player.Character
		character.HumanoidRootPart.CFrame = lobbySpawn.CFrame
    end
end 

-- Event Bindings
Players.PlayerAdded:Connect(onPlayerJoin)
Players.PlayerRemoving:Connect(removePlayerFromGame) -- when the player leaves, if they are in the queue, remove them

return PlayerManager
