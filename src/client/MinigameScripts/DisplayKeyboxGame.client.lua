-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Guis --
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')
local KeyboxGameGui = PlayerGui:WaitForChild('KeyboxGameGui')

-- Frames --
local BaseFrame = KeyboxGameGui:WaitForChild('BaseFrame')

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local CompletedKeyboxGui  = RemoteEvents:FindFirstChild('CompletedKeyboxGui')
local KeyboxGuiEvent = RemoteEvents:WaitForChild('KeyboxGuiEvent')

-- Buttons -- 
local Button = BaseFrame:WaitForChild('TextButton')

-- Local Functions --

-- Local function to display the keyboard game gui
local function onKeyboxEvent(showGui)
    KeyboxGameGui.Enabled = showGui
end

-- Local function to increase the key count
local function onButtonClicked()
    CompletedKeyboxGui:FireServer(1)
end

-- Event Bindings -- 
KeyboxGuiEvent.OnClientEvent:Connect(onKeyboxEvent)
Button.Activated:Connect(onButtonClicked)
