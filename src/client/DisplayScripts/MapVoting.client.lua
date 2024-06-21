-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')

-- Events
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local VotingEvent = RemoteEvents:WaitForChild('VotingEvent')
local Voted = RemoteEvents:WaitForChild('Voted')

-- Gui
local mapVotingGui = PlayerGui:WaitForChild('MapVotingGui')

-- Frames
local baseFrame = mapVotingGui:WaitForChild('BaseFrame')
local mapFrames = baseFrame:WaitForChild('MapFrames')

-- Local Variables
local COOLDOWN_TIME = 0.5
local buttonCooldowns = {}

-- Local Functions
local function updateMapFrame(map, mapFrame)
	local mapName = map.Name
	-- Update the map frame details here
end

local function fireSelectedMap(map)
	Voted:FireServer(map.Name)
end

local function getMapFrames()
    local maps = {}
    local children = mapFrames:GetChildren()
    for _, child in children do
        if child:IsA('Frame') then
            table.insert(maps, child)
        end
    end
    return maps
end

local function onButtonClicked(map, button)
	if buttonCooldowns[button] then return end
	buttonCooldowns[button] = true  -- Start cooldown for this button

	Voted:FireServer(map.Name)

	task.wait(COOLDOWN_TIME)
	buttonCooldowns[button] = false  -- End cooldown for this button
end

local function onHandleVotingEvent(visible)
    local votableMaps = ReplicatedStorage.Shared:WaitForChild('Maps'):GetChildren()
    local allMapFrames = getMapFrames()
	mapVotingGui.Enabled = visible

    for i, map in ipairs(votableMaps) do
        local frame = allMapFrames[i]
        local button = frame.TextButton
        button.Active = visible

        frame.Name = map.Name
        frame.MapNameLabel.Text = map.Name
        frame.NumVotesLabel.Text = '0'
        -- TODO - frame.MapImageLabel.Image = 'rbxassetid://' .. map.Configuration.ImageId.Value

        if not buttonCooldowns[button] then  -- Connect the event only once
            button.Activated:Connect(function()
                onButtonClicked(map, button)
            end)
            buttonCooldowns[button] = false  -- Initialize cooldown state
        end
    
        for _, child in pairs(allMapFrames) do
			if child:IsA('Frame') then
				child.TextButton.Active = visible
			end
		end
	end
end

local function addVoteToGui(playerVotes)
	print('player votes after clicking button', playerVotes)
	local votes = {}
    local allMapFrames = getMapFrames()
	for _, votedMap in pairs(playerVotes) do
		if not votes[votedMap] then -- the first time a player has voted for the map
			votes[votedMap] = 1
		else
			votes[votedMap] += 1
		end	
	end

	for _, child in pairs(allMapFrames) do
        if child:IsA('Frame') then
			child.NumVotesLabel.Text = (votes[child.Name] or 0)
        end
	end
end

-- Event Bindings
VotingEvent.OnClientEvent:Connect(onHandleVotingEvent)
Voted.OnClientEvent:Connect(addVoteToGui)
