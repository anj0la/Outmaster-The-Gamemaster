-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Guis --
local Guis = ReplicatedStorage.Shared:WaitForChild('Guis')
local GamemasterGuis = Guis:WaitForChild('GamemasterGuis')
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')
local StatusDisplayGui = PlayerGui:WaitForChild('StatusDisplayGui')

-- Frames --
local baseFrame = StatusDisplayGui:WaitForChild('BaseFrame')
local gamemasterFrame = baseFrame:WaitForChild('GamemasterFrame')
local playersLeftFrame = baseFrame:WaitForChild('PlayersLeftFrame')
local timerFrame = baseFrame:WaitForChild('TimerFrame')

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local UpdateGamemasterFrame = RemoteEvents:WaitForChild('UpdateGamemasterFrame')
local UpdatePlayersLeft = RemoteEvents:WaitForChild('UpdatePlayersLeft')
local UpdateTimer = RemoteEvents:WaitForChild('UpdateTimer')
local DisplayGamemasterRoleInfo = RemoteEvents:WaitForChild('DisplayGamemasterRoleInfo')
local DisplayActivateGui = RemoteEvents:WaitForChild('DisplayActivateGui')


-- Local Variables --
local gamemasterImageLabel = gamemasterFrame:WaitForChild('GamemasterImageLabel')
local playersLeftLabel = playersLeftFrame:WaitForChild('PlayersLeftLabel')
local statusLabel = timerFrame:WaitForChild('StatusLabel')
local timerLabel = timerFrame:WaitForChild('TimerLabel')

-- Local Functions --

-- Local function to get the gamemaster's thumbnail image to be displayed
local function getGamemasterThumbnail(gamemaster)
	-- Fetch the thumbnail
	local userId = gamemaster.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size100x100
	local content, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	
	-- Set the ImageLabel's content to the user thumbnail
	gamemasterImageLabel.Image = content
end

-- Local function to update the timer and status labels based on visibility
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

-- Local function to update the players left label based on visibility
local function onUpdatePlayersLeft(newPlayersLeft, visible)
	playersLeftLabel.Text = newPlayersLeft	
	playersLeftFrame.Visible = visible
end

-- Local function to update the gamemaster thumbnail based on visibility
local function onUpdateGamemasterFrame(gamemaster, visible)
	if gamemaster ~= nil then
		getGamemasterThumbnail(gamemaster)
	end
	gamemasterFrame.Visible = visible
end

local function onDisplayGamemasterRoleInfo(gamemaster, visible)
	local gamemasterRoleGui = PlayerGui:FindFirstChild('GamemasterRoleGui')

	-- if not already cloned to the player gui, clone it
    if not gamemasterRoleGui then
        local gamemasterRoleGuiTemplate = GamemasterGuis:FindFirstChild('GamemasterRoleGui')
        if gamemasterRoleGuiTemplate then
            gamemasterRoleGui = gamemasterRoleGuiTemplate:Clone()
            gamemasterRoleGui.Parent = PlayerGui
        else
            warn('Gamemaster GUI template not found!')
            return
        end
	end

	-- enable or disable the gui
	gamemasterRoleGui.Enabled = visible

	-- if the gui should not be visible, we can destroy it
	if not visible then
		gamemasterRoleGui:Destroy()
	end
end

local function onDisplayActivateGui(gamemaster, visible)
	local activateGui = PlayerGui:FindFirstChild('ActivateGui')

		-- if not already cloned to the player gui, clone it
		if not activateGui then
			local activateGuiTemplate = GamemasterGuis:FindFirstChild('ActivateGui')
			if activateGuiTemplate then
				activateGui = activateGuiTemplate:Clone()
				activateGui.Parent = PlayerGui
			else
				warn('Gamemaster GUI template not found!')
				return
			end
		end
	
		-- enable or disable the gui
		activateGui.Enabled = visible
	
		-- if the gui should not be visible, we can destroy it
		if not visible then
			activateGui:Destroy()
		end

end

-- Event Bindings --
UpdateTimer.OnClientEvent:Connect(onUpdateTimer)
UpdatePlayersLeft.OnClientEvent:Connect(onUpdatePlayersLeft)
UpdateGamemasterFrame.OnClientEvent:Connect(onUpdateGamemasterFrame)
DisplayGamemasterRoleInfo.OnClientEvent:Connect(onDisplayGamemasterRoleInfo)
DisplayActivateGui.OnClientEvent:Connect(onDisplayActivateGui)