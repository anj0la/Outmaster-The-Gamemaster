local DisplayManager = {}

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

-- EventCreator
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')
local EventCreator = UtilityModules:WaitForChild('EventCreator')

-- Events
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local UpdateTimer = RemoteEvents:WaitForChild('UpdateTimer')
local UpdatePlayersLeft = RemoteEvents:WaitForChild('UpdatePlayersLeft')
local UpdateGamemasterFrame = RemoteEvents:WaitForChild('UpdateGamemasterFrame')

-- Functions
function DisplayManager.init()
    if not UpdateTimer then
        UpdateTimer = EventCreator.createEvent('UpdateTimer', 'RemoteEvent', RemoteEvents)
    end
    if not UpdatePlayersLeft then
        UpdatePlayersLeft = EventCreator.createEvent('UpdatePlayersLeft', 'RemoteEvent', RemoteEvents)
    end
    if not UpdateGamemasterFrame then
        UpdateGamemasterFrame = EventCreator.createEvent('UpdateGamemasterFrame', 'RemoteEvent', RemoteEvents)
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