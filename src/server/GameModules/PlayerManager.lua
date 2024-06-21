local PlayerManager = {}

-- Services
local Players = game:GetService('Players')
local Teams = game:GetService('Teams')
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
    --[[ if a player who creates the server (first player in the game) loads into the game before the player added event can be fired,
     then the actions of the player added event are performed on that player ]]--
	for _, player in ipairs(Players:GetPlayers()) do
		loadLeaderstats(player)
		player.RespawnLocation = lobbySpawn -- regardless of whether a game is underway, when a player joins the game, they will ALWAYS spawn in the lobby
		table.insert(queuedPlayers, player) -- added to the queue so they are able to play the next game
		--player.Team = Teams:WaitForChild('Spectators') -- moving the players to the spectator team
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
	
	--[[ if we haven't deleted the player from the queue (i.e., they don't exist in the queue),
	we know they are in the active queue and must delete them from it ]]--
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
	for playerKey, whichPlayer in ipairs(queuedPlayers) do
		table.remove(queuedPlayers, playerKey)
		table.insert(activePlayers, whichPlayer)
		whichPlayer.Team = Teams:WaitForChild('Players') -- moving the players to the players team
	end
end

function PlayerManager.removePlayersFromActive()
	for playerKey, whichPlayer in ipairs(activePlayers) do
		table.remove(activePlayers, playerKey)
		table.insert(queuedPlayers, whichPlayer)
		whichPlayer.Team = Teams:WaitForChild('Spectators') -- moving the players to the spectator team
	end
end


-- Event Bindings
Players.PlayerAdded:Connect(onPlayerJoin)
Players.PlayerRemoving:Connect(removePlayerFromGame) -- when the player leaves, if they are in the queue, remove them

return PlayerManager
