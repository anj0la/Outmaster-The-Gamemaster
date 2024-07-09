local TeamManager = {}

-- Services --
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')
local Teams = game:GetService('Teams')

-- Module Folders --
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts --
local CloneTool = require(UtilityModules:WaitForChild('CloneTool'))
local InstanceFactory = require(UtilityModules:WaitForChild('InstanceFactory'))
local GamemasterChance = require(UtilityModules:WaitForChild('GamemasterChance'))

-- Gamemaster Scripts --
local GamemasterScripts = ServerStorage:WaitForChild('GamemasterScripts')

-- Remote Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local HammerDamageEvent = RemoteEvents:FindFirstChild('HammerDamageEvent')
local ToggleFirstPerson = RemoteEvents:FindFirstChild('ToggleFirstPerson')

-- Lobby Variables --
local Lobby = workspace:WaitForChild('Lobby')
local lobbySpawn = Lobby:WaitForChild('SpawnLocation')

-- Local Variables -- (may not need to store tbh)
local players = {}
local gamemaster = nil

-- Local Functions --

-- Local function to handle hammer damage
local function handleHammerDamage(attacker, hitPlayer)
    local hitHumanoid = hitPlayer.Character and hitPlayer.Character:FindFirstChild('Humanoid')
    local attackerHumanoid = attacker.Character and attacker.Character:FindFirstChild('Humanoid')
    local gamemasterTeam = Teams:WaitForChild('Gamemaster')
    local playersTeam = Teams:WaitForChild('Players')

    print('hit player: ', hitPlayer)

    print('attacker: ', attacker)

    if hitHumanoid and attackerHumanoid then
        local hitTeam = hitPlayer.Team
        local attackerTeam = attacker.Team
        
        if hitTeam and attackerTeam then
            -- check 1: if the hit team = player and the attacker = gamemaster, then kill the player
            if hitTeam == playersTeam and attackerTeam == gamemasterTeam then
                -- kill the player
                hitHumanoid.Health = 0
                -- increment xp for the Gamemaster
                -- decrease the number of players left
                -- by calling DisplayManager.updatePlayersLeft(players, nil)
                -- ALL WILL BE DONE LATER
            -- check 2: hit team = gamemaster, attacker team = player
            elseif hitTeam == gamemasterTeam and attackerTeam == playersTeam then
                -- end the round and kill the Gamemaster
                ToggleFirstPerson:FireClient(gamemaster, false) -- putting gamemaster back in third person
                hitHumanoid.Health = 0
                -- add additional logic to end the round here
                -- EndRound:Fire(gamemaster)
                -- {endGame = true, winner = attacker}
            -- check 3: attacker team = player and hit team = player
            elseif hitTeam == playersTeam and attackerTeam == playersTeam then
                -- kill both players and drop the hammer
                hitHumanoid.Health = 0
                attackerHumanoid.Health = 0
                -- {endGame = false, winner = nil}
                local hammerClone = attacker.Backpack:FindFirstChild('Golden Hammer'):Clone()
                hammerClone.Parent = workspace
                hammerClone.Handle.Position = attacker.Character.HumanoidRootPart.Position
            end
        end
    end
end

local function setUpGamemaster()
    -- clone the hammer to the gamemaster
    CloneTool.cloneHammerToPlayer(gamemaster)
    -- clone the local script to the gamemaster
    local cameraViewScriptClone = GamemasterScripts:WaitForChild('CameraViewScript'):Clone()
    cameraViewScriptClone.Parent = gamemaster.Character
    -- toggle first person (true = we set the gamemaster in first position, false = don't enable movement)
    ToggleFirstPerson:FireClient(gamemaster, true) -- gamemaster = player, the first argument to FireClient
end

-- Module Functions --

-- Function to initalize the events related to the teams
function TeamManager.init()
    -- creating events related to gamemaster and players
    if not HammerDamageEvent then
        HammerDamageEvent = InstanceFactory.createInstance('RemoteEvent', 'HammerDamageEvent', RemoteEvents)
    end
    if not ToggleFirstPerson then
        ToggleFirstPerson = InstanceFactory.createInstance('RemoteEvent', 'ToggleFirstPerson', RemoteEvents)
    end

    -- initalizing clone tool module for cloning the golden hammer (players) and regular hammer (gamemaster)
    CloneTool.init()

    -- Event Bindings --
    HammerDamageEvent.OnServerEvent:Connect(handleHammerDamage)
end

-- Function to initalize the gamemaster and players
function TeamManager.initTeams(activePlayers)
    -- getting the gamemaster and assigning them to the gamemaster team
    gamemaster = GamemasterChance.selectGamemaster(activePlayers)
    gamemaster.Team = Teams:WaitForChild('Gamemaster')

    -- put gamemaster in first person, clone tool to their backpack, and disable movement
    setUpGamemaster()

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

-- Function to spawn the gamemaster into the game
function TeamManager.spawnGamemasterInGame()
	local character = gamemaster.Character
	local gamemasterSpawnLocation = workspace:WaitForChild('GamemasterSpawnLocation')
	character.HumanoidRootPart.CFrame = gamemasterSpawnLocation.CFrame
end

-- Function to reset the gamemaster's view back to normal
function TeamManager.resetGamemasterView()
    ToggleFirstPerson:FireClient(gamemaster, false)
end

-- Function to spawn queued players back into the lobby
function TeamManager.spawnPlayersInLobby(queuedPlayers)
	-- we run this code AFTER the players have been assigned back to the waiting queue
	for i = #queuedPlayers, 1, -1 do
        local player = queuedPlayers[i]
        player.Team = Teams:WaitForChild('Spectators') -- moving the players to the spectator team
        -- removing all scripts inside of the players with LoadCharacter
        player:LoadCharacter()
		local character = player.Character
		character.HumanoidRootPart.CFrame = lobbySpawn.CFrame
    end
end 

return TeamManager