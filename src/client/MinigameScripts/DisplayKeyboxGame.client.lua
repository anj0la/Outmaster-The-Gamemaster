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

-- Keybox --
local keyboxObj = nil -- going to be an array of keyboxes probably

-- Local Functions --

-- Local function to display the keyboard game gui
local function onKeyboxEvent(keybox, showGui)
    KeyboxGameGui.Enabled = showGui
    keyboxObj = keybox
end

-- Local function to increase the key count
local function onButtonClicked()
    CompletedKeyboxGui:FireServer(keyboxObj)
end

-- Event Bindings -- 
KeyboxGuiEvent.OnClientEvent:Connect(onKeyboxEvent)
Button.Activated:Connect(onButtonClicked)
