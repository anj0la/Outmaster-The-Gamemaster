-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Guis --
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')
local MapVotingGui = PlayerGui:WaitForChild('MapVotingGui')

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local VotingEvent = RemoteEvents:WaitForChild('VotingEvent')
local Voted = RemoteEvents:WaitForChild('Voted')

-- Frames --
local BaseFrame = MapVotingGui:WaitForChild('BaseFrame')
local MapFrames = BaseFrame:WaitForChild('MapFrames')

-- Local Variables --
local COOLDOWN_TIME = 0.5
local buttonCooldowns = {}

-- Local Functions --

-- Local function that gets all the map frames in the parent Frame MapFrames 
local function getAllMapFrames()
    local maps = {}
    local children = MapFrames:GetChildren()
    for _, child in children do
        if child:IsA('Frame') then
            table.insert(maps, child)
        end
    end
    return maps
end

-- Local function to handle clicking the voting button on a map
local function onButtonClicked(map, button)
	if buttonCooldowns[button] then return end
	buttonCooldowns[button] = true  -- Start cooldown for this button

	Voted:FireServer(map.Name)

	task.wait(COOLDOWN_TIME)
	buttonCooldowns[button] = false  -- End cooldown for this button
end

-- Local function to handle the voting event
local function onHandleVotingEvent(visible)
    local votableMaps = ReplicatedStorage.Shared:WaitForChild('Maps'):GetChildren()
    local allMapFrames = getAllMapFrames()
	MapVotingGui.Enabled = visible -- change this code so that when its not visible, we don't run this

    for i, map in ipairs(votableMaps) do
        local frame = allMapFrames[i]
        local button = frame.TextButton
        button.Active = visible

        -- changing each frame's name, label, numvotes and image to the votable maps
        frame.Name = map.Name
        frame.MapNameLabel.Text = map.Name
        frame.NumVotesLabel.Text = '0'
        -- TODO - frame.MapImageLabel.Image = 'rbxassetid://' .. map.Configuration.ImageId.Value

        if not buttonCooldowns[button] then  -- connect the event only once
            button.Activated:Connect(function()
                onButtonClicked(map, button)
            end)
            buttonCooldowns[button] = false  -- initialize cooldown state
        end

        -- making the text buttons active (clickable)
        for _, child in pairs(allMapFrames) do
			if child:IsA('Frame') then
				child.TextButton.Active = visible
			end
		end
	end
end

-- Local function to add a vote to the GUI
local function addVoteToGui(playerVotes)
	print('player votes after clicking button', playerVotes)
	local votes = {}
    local allMapFrames = getAllMapFrames()
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

-- Event Bindings --
VotingEvent.OnClientEvent:Connect(onHandleVotingEvent)
Voted.OnClientEvent:Connect(addVoteToGui)
