local PlayerManager = {}

-- Services
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
-- local chosenMap = ReplicatedStorage.Shared:WaitForChild('Maps'):GetChildren()[1]
-- local chosenMapSpawns = chosenMap:WaitForChild('SpawnLocations'):GetChildren()

-- Local Variables
local activePlayers = {}
local queuedPlayers = {}
local teams = Teams:GetTeams()

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
		-- Check if the player already has leaderstats
		if not player:FindFirstChild('leaderstats') then
			loadLeaderstats(player)
		end

		-- Set the respawn location to the lobby spawn
		player.RespawnLocation = lobbySpawn

		-- Check if the player is already in the queuedPlayers table
		local isInQueue = false
		for _, queuedPlayer in ipairs(queuedPlayers) do
			if queuedPlayer == player then
				isInQueue = true
				break
			end
		end

		-- If the player is not in the queue, add them
		if not isInQueue then
			table.insert(queuedPlayers, player)
			print('adding player to queue', player)
			print('new queue: ', queuedPlayers)
		end

		-- Move the player to the spectator team (if needed)
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

function PlayerManager.loadPlayer(player)
	player:LoadCharacter()
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

--[[ function PlayerManager.respawnPlayerInLobby(player)
	player.RespawnLocation = lobbySpawn -- even if a game is underway
	player:LoadCharacter()
end

function PlayerManager.addPlayerToQueue(player)
	table.insert(queuedPlayers, player)
end ]]

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
-- Event Bindings
Players.PlayerAdded:Connect(onPlayerJoin)
Players.PlayerRemoving:Connect(removePlayerFromGame) -- when the player leaves, if they are in the queue, remove them

return PlayerManager
