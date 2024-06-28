local TeamManager = {}

-- Services --
local ServerScriptService = game:GetService('ServerScriptService')
local Teams = game:GetService('Teams')

-- Module Folders --
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts --
local GamemasterChance = require(UtilityModules:WaitForChild('GamemasterChance'))

-- Lobby Variables --
local Lobby = workspace:WaitForChild('Lobby')
local lobbySpawn = Lobby:WaitForChild('SpawnLocation')

-- Local Variables --
local players = {}
local gamemaster = nil

-- Local Functions --


-- Module Functions --

-- Function to initalize the gamemaster and players
function TeamManager.init(activePlayers)
    -- getting the gamemaster and assigning them to the gamemaster team
    gamemaster = GamemasterChance.selectGamemaster(activePlayers)
    gamemaster.Team = Teams:WaitForChild('Gamemaster')

    -- now, assigning the rest of the players to the player team
    for i = #activePlayers, 1, -1 do
        local player = activePlayers[i]
        if player ~= gamemaster then
            player.Team = Teams:WaitForChild('Players') -- moving the players (other than the gamemaster) to the players team
        end
    end 
    players = Teams:WaitForChild('Players'):GetPlayers()
end

-- Function to reset the gamemaster and players to their default values
function TeamManager.resetTeams()
    gamemaster = nil
    players = {}
end

-- Function to get the gamemaster
function TeamManager.getGamemaster()
	return gamemaster
end

-- Function to get the players
function TeamManager.getPlayers()
	return players
end

-- Function to spawn the players into the game
function TeamManager.spawnPlayersInGame()
	local chosenMapSpawns = workspace:WaitForChild('SpawnLocations'):GetChildren()
	print('chosen map spawns', chosenMapSpawns)
	for i = #players, 1, -1 do
        local player = players[i]
		local character = player.Character
		local randomIndex = math.random(1, #chosenMapSpawns)
		character.HumanoidRootPart.CFrame = chosenMapSpawns[randomIndex].CFrame
    end
end

-- Function to spawn the gamemaster into the gzme
function TeamManager.spawnGamemasterInGame()
	local character = gamemaster.Character
	local gamemasterSpawnLocation = workspace:WaitForChild('GamemasterSpawnLocation')
	character.HumanoidRootPart.CFrame = gamemasterSpawnLocation.CFrame
end

-- Function to spawn queued players back into the lobby
function TeamManager.spawnPlayersInLobby(queuedPlayers)
	-- we run this code AFTER the players have been assigned back to the waiting queue
	for i = #queuedPlayers, 1, -1 do
        local player = queuedPlayers[i]
        player.Team = Teams:WaitForChild('Spectators') -- moving the players to the spectator team
        -- INSTEAD, JUST CALL PLAYER:LOADCHARACTER()
        -- player:LoadCharacter()
		local character = player.Character
		character.HumanoidRootPart.CFrame = lobbySpawn.CFrame
    end
end 

return TeamManager