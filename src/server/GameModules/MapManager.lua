local MapManager = {}

-- Services
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Module Folders
local Configurations = ServerScriptService.Server:WaitForChild('Configurations')
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- EventCreator
local EventCreator = require(UtilityModules:WaitForChild('EventCreator'))

-- Module Scripts
local GameSettings = require(Configurations:WaitForChild('GameSettings'))

-- Maps
local Maps = ServerStorage:WaitForChild('Maps')

-- Events
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local VotingEvent = RemoteEvents:FindFirstChild('VotingEvent')
local Voted = RemoteEvents:FindFirstChild('Voted')

-- Variables
local playerVotes = {}
local votableMaps = nil

-- Initialization
if not VotingEvent then
    VotingEvent = EventCreator.createEvent('RemoteEvent', 'VotingEvent', RemoteEvents)
end
if not Voted then
    Voted = EventCreator.createEvent('RemoteEvent', 'Voted', RemoteEvents)
end

-- Local Functions
local function addPlayerVote(player, mapName)
	if playerVotes[player] ~= mapName then
		playerVotes[player] = mapName
		print('player voted for map: ', playerVotes[player])
		Voted:FireAllClients(playerVotes)
	end
end

local function reduceMapsToLimit()
	local maps = Maps:GetChildren()
	while #maps > GameSettings.MAX_VOTABLE_MAPS do
		table.remove(maps, math.random(1, #maps))
	end
	return maps
end

local function initalizeMapVoting()
	local votes = {}
	for _, map in pairs(votableMaps) do
		votes[map.Name] = 0
	end
	return votes
end

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

local function loadMap()
	local chosenMap = ReplicatedStorage.Shared:WaitForChild('Maps'):GetChildren()[1]
	for _, child in pairs(chosenMap:GetChildren()) do
		child.Parent = workspace
	end
end

-- Module Functions
function MapManager.startMapVoting()
	print('player votes before resetting: ', playerVotes)
	playerVotes = {}
	print('player votes after resetting: ', playerVotes)
	votableMaps = reduceMapsToLimit()
	
	-- Replicating the selected maps to vote for to ReplicatedStorage
    local maps = ReplicatedStorage.Shared:WaitForChild('Maps')
	for _, map in pairs(votableMaps) do
		local clonedMap = map:Clone()
		clonedMap.Parent = maps
	end
	
    -- We fire true to make the map voting gui visible
	VotingEvent:FireAllClients(true)
end

function MapManager.selectChosenMap()
	local votes = initalizeMapVoting()
	
	print('selecting chosen map with playerVotes: ', playerVotes)
	-- Count votes from players
	for _, votedMap in pairs(playerVotes) do
		-- Increment the vote count for the selected map
		if votes[votedMap] then
			votes[votedMap] += 1
		end
	end
	-- Chose the map with the highest amount of votes
	local chosenMap = getMapWithHighestVotes(votes)
	print('Chosen Map: ', chosenMap)
	
	-- Delete the maps not voted for in ReplicatedStorage
	local votingMaps = ReplicatedStorage.Shared:WaitForChild('Maps')
	for _, map in pairs(votingMaps:GetChildren()) do
		if map.Name ~= chosenMap then
			map:Destroy()
		end
	end
	
	loadMap()
end

function MapManager.endMapVoting()
	VotingEvent:FireAllClients(false)
end

function MapManager.removeMap()
	-- Get the chosen map from the Maps folder in ReplicatedStorage
	local map = ReplicatedStorage.Shared:WaitForChild('Maps'):GetChildren()[1]
	 
	for _, child in workspace:GetChildren() do
		if child.Name == map.Name then
			child:Destroy()
			break
		end
	end

    -- Destroy the map in ReplicatedStorage
    map:Destroy()
end

-- Event Bindings
Voted.OnServerEvent:Connect(addPlayerVote)

return MapManager
