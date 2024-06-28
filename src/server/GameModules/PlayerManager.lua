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

-- Local Variables
local activePlayers = {}
local queuedPlayers = {}
local connectedPlayers = {}

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

local function onCharacterDespawned(character)
	local player = Players:GetPlayerFromCharacter(character)
	-- if player is actively in a game, removes from the active queue and places them in the waiting queue
	PlayerManager.removePlayerFromGame(player) 
	player.RespawnLocation = lobbySpawn
end

local function onPlayerAdded()
	--if a player who creates the server (first player in the game) loads into the game before the player added event can be fired,
	-- then the actions of the player added event are performed on that player

	for _, player in ipairs(Players:GetPlayers()) do
		-- check if the player already has leaderstats
		if not player:FindFirstChild('leaderstats') then
			loadLeaderstats(player)
			-- connecting the character removing and onDied events here to ensure they are only connnected once
			-- might put into Player.init() and run it there
			player.CharacterRemoving:Connect(onCharacterDespawned)
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

		-- connect the character removing event so that when a player resets or is eliminated from the game, they are sent back to the lobby
		-- edge case: if the gamemaster resets, then the game is over, so disabling the gamemaster from resetting maybe?
		
		-- connectedPlayers[player] = player.CharacterRemoving:Connect(onCharacterRespawn)
	
		-- move the player to the spectator team (if needed)
		-- player.Team = Teams:WaitForChild('Spectators')
	end			
end

local function removePlayerFromQueue(player)
	local deletedPlayer = false
	for i = #queuedPlayers, 1, -1 do
        local queuedPlayer = queuedPlayers[i]
		if queuedPlayer == player then
			table.remove(queuedPlayers, i)
			table.remove(connectedPlayers, i) -- need to remove from connectedPlayers table
			deletedPlayer = true
			break
		end  
    end
	
	-- if we haven't deleted the player from the queue (i.e., they don't exist in the queue),
	-- we know they are in the active queue and must delete them from it
	if not deletedPlayer then 
		for i = #activePlayers, 1, -1 do
			local activePlayer = activePlayers[i]
			if activePlayer == player then
				table.remove(activePlayers, i)
				table.remove(connectedPlayers, i) -- need to remove from connectedPlayers table
				break
			end  
		end
	end

end

-- Module Functions
function PlayerManager.init()
	print('player init worked')
	-- Event Bindings
	--Players.PlayerAdded:Connect(onPlayerAdded)
	--Players.PlayerRemoving:Connect(removePlayerFromQueue) -- when the player leaves, if they are in the queue, remove them
	for _, player in ipairs(Players:GetPlayers()) do
		player.CharacterRemoving:Connect(onCharacterDespawned)
	end 
end

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
	for playerKey, whichPlayer in ipairs(activePlayers) do
		if whichPlayer == player then
			table.remove(activePlayers, playerKey)
		end
	end
end

function PlayerManager.getQueuedPlayers()
	return queuedPlayers
end

function PlayerManager.getActivePlayers()
	return activePlayers
end

function PlayerManager.removePlayerFromGame(player)
	for i = #activePlayers, 1, -1 do
        local activePlayer = activePlayers[i]
		if activePlayer == player then
			table.remove(activePlayers, i)
			table.insert(queuedPlayers, player)
			-- create bindable event here to remove player from team, and update number of players on team left
			player.Team = Teams:WaitForChild('Spectators') -- moving the players to the spectator team ()
			break
		end  
    end
end

function PlayerManager.addPlayersToActive()
    for i = #queuedPlayers, 1, -1 do
        local player = queuedPlayers[i]
        table.remove(queuedPlayers, i)
        table.insert(activePlayers, player)
    end
end

function PlayerManager.removePlayersFromActive()
    for i = #activePlayers, 1, -1 do
        local player = activePlayers[i]
        table.remove(activePlayers, i)
        table.insert(queuedPlayers, player)
    end
end

-- Event Bindings
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removePlayerFromQueue) -- when the player leaves, if they are in the queue, remove them

return PlayerManager
