local DisplayManager = {}

-- Services --
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

-- EventCreator --
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')
local InstanceFactory = require(UtilityModules:WaitForChild('InstanceFactory'))

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local UpdateTimer = RemoteEvents:FindFirstChild('UpdateTimer')
local UpdatePlayersLeft = RemoteEvents:FindFirstChild('UpdatePlayersLeft')
local UpdateGamemasterFrame = RemoteEvents:FindFirstChild('UpdateGamemasterFrame')
local DisplayGamemasterRoleInfo = RemoteEvents:FindFirstChild('DisplayGamemasterRoleInfo')

-- Module Functions --

-- Function to initalize the events related to display in the game
function DisplayManager.init()
    if not UpdateTimer then
        UpdateTimer = InstanceFactory.createInstance('RemoteEvent', 'UpdateTimer', RemoteEvents)
    end
    if not UpdatePlayersLeft then
        UpdatePlayersLeft = InstanceFactory.createInstance('RemoteEvent', 'UpdatePlayersLeft', RemoteEvents)
    end
    if not UpdateGamemasterFrame then
        UpdateGamemasterFrame = InstanceFactory.createInstance('RemoteEvent', 'UpdateGamemasterFrame', RemoteEvents)
    end
    if not DisplayGamemasterRoleInfo then
        DisplayGamemasterRoleInfo = InstanceFactory.createInstance('RemoteEvent', 'DisplayGamemasterRoleInfo', RemoteEvents)
    end
end

-- Function to update the timer
function DisplayManager.updateTimer(newTimeLeft, newStatus)
	UpdateTimer:FireAllClients(newTimeLeft, newStatus)
end

-- Function to update the players left
function DisplayManager.updatePlayersLeft(newPlayersLeft, visible)
	UpdatePlayersLeft:FireAllClients(newPlayersLeft, visible)
end

-- Function to update the gamemaster frame
function DisplayManager.updateGamemaster(gamemaster, visible)
	UpdateGamemasterFrame:FireAllClients(gamemaster, visible)
end

-- Function to display the gamemaster role information to the gamemaster
function DisplayManager.displayGamemasterRoleInfo(gamemaster, visible)
    DisplayGamemasterRoleInfo:FireClient(gamemaster, gamemaster, visible)
end

return DisplayManager