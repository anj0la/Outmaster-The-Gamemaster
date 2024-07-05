local DisplayManager = {}

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

-- EventCreator
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')
local InstanceFactory = require(UtilityModules:WaitForChild('InstanceFactory'))

-- Events
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local UpdateTimer = RemoteEvents:FindFirstChild('UpdateTimer')
local UpdatePlayersLeft = RemoteEvents:FindFirstChild('UpdatePlayersLeft')
local UpdateGamemasterFrame = RemoteEvents:FindFirstChild('UpdateGamemasterFrame')

-- Module Functions
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
end

function DisplayManager.updateTimer(newTimeLeft, newStatus)
	UpdateTimer:FireAllClients(newTimeLeft, newStatus)
end

function DisplayManager.updatePlayersLeft(newPlayersLeft, visible)
	UpdatePlayersLeft:FireAllClients(newPlayersLeft, visible)
end

-- we would get the Gamemaster from the Gamemaster module, for now, we just use player as a placeholder
function DisplayManager.updateGamemaster(gamemaster, visible)
	UpdateGamemasterFrame:FireAllClients(gamemaster, visible)
end

return DisplayManager