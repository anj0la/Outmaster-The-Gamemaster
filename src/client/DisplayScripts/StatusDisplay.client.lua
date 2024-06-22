-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

-- Guis
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')
local StatusDisplayGui = PlayerGui:WaitForChild('StatusDisplayGui')

-- Frames
local baseFrame = StatusDisplayGui:WaitForChild('BaseFrame')
local gamemasterFrame = baseFrame:WaitForChild('GamemasterFrame')
local playersLeftFrame = baseFrame:WaitForChild('PlayersLeftFrame')
local timerFrame = baseFrame:WaitForChild('TimerFrame')

-- Events
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local UpdateGamemasterFrame = RemoteEvents:WaitForChild('UpdateGamemasterFrame')
local UpdatePlayersLeft = RemoteEvents:WaitForChild('UpdatePlayersLeft')
local UpdateTimer = RemoteEvents:WaitForChild('UpdateTimer')

-- Local Variables
local gamemasterImageLabel = gamemasterFrame:WaitForChild('GamemasterImageLabel')
local playersLeftLabel = playersLeftFrame:WaitForChild('PlayersLeftLabel')
local statusLabel = timerFrame:WaitForChild('StatusLabel')
local timerLabel = timerFrame:WaitForChild('TimerLabel')

-- Local Functions
local function getGamemasterThumbnail(gamemaster)
	-- Fetch the thumbnail
	local userId = gamemaster.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size100x100
	local content, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	
	-- Set the ImageLabel's content to the user thumbnail
	gamemasterImageLabel.Image = content
end

local function onUpdateTimer(newTimeLeft, newStatus)
	if newTimeLeft ~= nil then
		local minutes = math.floor(newTimeLeft / 60) -- % 60
		local seconds = math.floor(newTimeLeft) % 60
		timerLabel.Text = string.format('%02d:%02d', minutes, seconds)
	end
	if newStatus ~= nil then
		statusLabel.Text = newStatus
	end
end

local function onUpdatePlayersLeft(newPlayersLeft, visible)
	playersLeftLabel.Text = newPlayersLeft	
	playersLeftFrame.Visible = visible
end

local function onUpdateGamemasterFrame(gamemaster, visible)
	if gamemaster ~= nil then
		getGamemasterThumbnail(gamemaster)
	end
	gamemasterFrame.Visible = visible
end

-- Event Binding
UpdateTimer.OnClientEvent:Connect(onUpdateTimer)
UpdatePlayersLeft.OnClientEvent:Connect(onUpdatePlayersLeft)
UpdateGamemasterFrame.OnClientEvent:Connect(onUpdateGamemasterFrame)
