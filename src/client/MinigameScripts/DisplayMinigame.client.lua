-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Guis --
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')
local KeyboxGameGui = PlayerGui:WaitForChild('KeyboxGameGui')

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local KeyboxGuiEvent = RemoteEvents:WaitForChild('KeyboxGuiEvent')

-- Local Functions
local function onKeyboxEvent(showGui)
    print('are you even working?')
    KeyboxGameGui.Enabled = showGui
end

KeyboxGuiEvent.OnClientEvent:Connect(onKeyboxEvent)
