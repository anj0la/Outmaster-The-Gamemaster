local MapManager = {}

-- Services --
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Module Folders --
local Configurations = ServerScriptService.Server:WaitForChild('Configurations')
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- EventCreator --
local EventCreator = require(UtilityModules:WaitForChild('EventCreator'))

-- Module Scripts --
local GameSettings = require(Configurations:WaitForChild('GameSettings'))

-- Maps --
local Maps = ServerStorage:WaitForChild('Maps')

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local VotingEvent = RemoteEvents:FindFirstChild('VotingEvent')
local Voted = RemoteEvents:FindFirstChild('Voted')

-- Variables --
local playerVotes = {}
local votableMaps = nil

-- Initialization --
if not VotingEvent then
    VotingEvent = EventCreator.createEvent('RemoteEvent', 'VotingEvent', RemoteEvents)
end
if not Voted then
    Voted = EventCreator.createEvent('RemoteEvent', 'Voted', RemoteEvents)
end

-- Local Functions --

-- Local function to add a player vote
local function addPlayerVote(player, mapName)
	if playerVotes[player] ~= mapName then
		playerVotes[player] = mapName
		print('player voted for map: ', playerVotes[player])
		Voted:FireAllClients(playerVotes)
	end
end

-- Local function to reduce the map voting to the determined limit (3)
local function reduceMapsToLimit()
	local maps = Maps:GetChildren()
	while #maps > GameSettings.MAX_VOTABLE_MAPS do
		table.remove(maps, math.random(1, #maps))
	end
	return maps
end

-- Local function to initalize map voting
local function initalizeMapVoting()
	local votes = {}
	for _, map in pairs(votableMaps) do
		votes[map.Name] = 0
	end
	return votes
end

-- Local function to get the map with the highest votes
local function getMapWithHighestVotes(votes)
	local highestVotes = 0
	local highestVotedFor = nil

	for mapName, voteCount in pairs(votes) do
		if voteCount > highestVotes then
			highestVotes = voteCount
			highestVotedFor = mapName
		end
	end
	
    -- if highestVotedFor is nil, choose a random map out of the three
	if highestVotedFor == nil then
		highestVotedFor = votableMaps[math.random(1, #votableMaps)].Name
	end
	
	return highestVotedFor
end

-- Function to determine the number of keyboxes to spawn
local function getNumKeyboxes(activePlayers)
	local numKeyboxes = nil
	-- Getting the number of keyboxes
	if #activePlayers >= 8 then
		numKeyboxes = GameSettings.MIN_KEYBOXES + 2
	elseif #activePlayers < 8 and #activePlayers >= 6 then -- 6-7 active players (5-6 players and 1 gamemaster)
		numKeyboxes = GameSettings.MIN_KEYBOXES + 1
	else -- 4-5 active players (3-4 players and 1 gamemaster)
		numKeyboxes = GameSettings.MIN_KEYBOXES
	end
	return numKeyboxes
end

-- Function to spawn the keyboxes into the chosen map
local function spawnKeyboxes(numKeyboxes, keyboxSpawnLocations, chosenMap)
	local keyboxes = Instance.new('Model')
	keyboxes.Name = 'Keyboxes'
	local keybox = ServerStorage:WaitForChild('GameObjects'):WaitForChild('Keybox')
	local children = keyboxSpawnLocations:GetChildren()

	for i = numKeyboxes, 1, -1 do
		-- get a random location in the spawn locations
		local randomIndex = math.random(1, #children)
		local keyboxSpawn = children[randomIndex]
		-- clone the keybox and set the position to be the spawn's position
		local clonedKeybox = keybox:Clone()
		clonedKeybox.Name = 'Keybox ' .. (numKeyboxes - i + 1)
		clonedKeybox:PivotTo(CFrame.new(keyboxSpawn.Position))

		-- parenting the keybox into the keyboxes model
		clonedKeybox.Parent = keyboxes
	end

	-- now we destroy the keybox spawn locations, since we don't need them anymore
	keyboxSpawnLocations:Destroy()
	-- make sure to parent keyboxes to the chosen maps folder
	keyboxes.Parent = chosenMap
end


-- Module Functions --


function MapManager.startMapVoting()
	print('player votes before resetting: ', playerVotes)
	playerVotes = {}
	print('player votes after resetting: ', playerVotes)
	votableMaps = reduceMapsToLimit()
	
	-- replicating the selected maps to vote for to ReplicatedStorage
    local maps = ReplicatedStorage.Shared:WaitForChild('Maps')
	for _, map in pairs(votableMaps) do
		local clonedMap = map:Clone()
		clonedMap.Parent = maps
	end
	
    -- we fire true to make the map voting gui visible
	VotingEvent:FireAllClients(true)
end

function MapManager.selectChosenMap()
	local votes = initalizeMapVoting()
	
	print('selecting chosen map with playerVotes: ', playerVotes)
	-- count votes from players
	for _, votedMap in pairs(playerVotes) do
		-- increment the vote count for the selected map
		if votes[votedMap] then
			votes[votedMap] += 1
		end
	end
	-- chose the map with the highest amount of votes
	local chosenMap = getMapWithHighestVotes(votes)
	print('Chosen Map: ', chosenMap)
	
	-- delete the maps not voted for in ReplicatedStorage
	local votingMaps = ReplicatedStorage.Shared:WaitForChild('Maps')
	for _, map in pairs(votingMaps:GetChildren()) do
		if map.Name ~= chosenMap then
			map:Destroy()
		end
	end
end

-- Function to load the chosen map into the workspace
function MapManager.loadMap(activePlayers)
	local chosenMap = ReplicatedStorage.Shared:WaitForChild('Maps'):GetChildren()[1]
	local numKeyboxes = getNumKeyboxes(activePlayers)
	local keyboxSpawnLocations = chosenMap:WaitForChild('KeyboxSpawnLocations')

	-- spawning the keyboxes
	spawnKeyboxes(numKeyboxes, keyboxSpawnLocations, chosenMap)

	-- now, cloning the map with the spawned keyboxes
	local clonedMap = chosenMap:Clone()

	-- loading the map into the game
	for _, child in pairs(clonedMap:GetChildren()) do
		child.Parent = workspace
	end
end

function MapManager.endMapVoting()
	VotingEvent:FireAllClients(false)
end

function MapManager.removeMap()
	-- get the chosen map from the Maps folder in ReplicatedStorage
	-- update for less exploitability - grab the map from serverstorage instead
	local map = ReplicatedStorage.Shared:WaitForChild('Maps'):GetChildren()[1]
	 
	-- destroy the map in Workspace
    print(map:GetChildren())
    for _, child in ipairs(workspace:GetChildren()) do
        for _, mapChild in ipairs(map:GetChildren()) do
            if child.Name == mapChild.Name then
                child:Destroy()
            end
        end
	end

    -- destroy the map in ReplicatedStorage
    map:Destroy()
end

-- Event Bindings
Voted.OnServerEvent:Connect(addPlayerVote)

return MapManager
