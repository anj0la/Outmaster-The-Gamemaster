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

-- Local function to change the activated game text
local function changeActivateGameText()
    local activateGame = keyboxObj:WaitForChild('ActivateGame')
    local activateGameGui = activateGame:WaitForChild('ActivateGameGui')
    local baseFrame = activateGameGui:WaitForChild('BaseFrame')
    local activateGameLabel = baseFrame:WaitForChild('ActivateGameLabel')
    local uiGradient = activateGameLabel:WaitForChild('UIGradient')
    local uiStroke = activateGameLabel:WaitForChild('UIStroke')

    -- colours for the gradient and stroke
    local c0 = Color3.new(0, 1, 0)
    local c1 = Color3.new(0, 0.12, 0)
    local c2 = Color3.new(0, 0.47, 0)

    -- changing the text to Game Completed
    activateGameLabel.Text = 'GAME COMPLETED'

    -- changing the ui gradient and stroke
    uiGradient.Color = ColorSequence.new(c0, c1)
    uiStroke.Color = c2

end

-- Local function to display the keyboard game gui
local function onKeyboxEvent(keybox, showGui)
    KeyboxGameGui.Enabled = showGui
    keyboxObj = keybox
end

-- Local function to allow the key to be collected
local function onButtonClicked()
    KeyboxGameGui.Enabled = false -- disable the game gui since the game has been completed
    -- changing the text to indicate that its been solved
    changeActivateGameText()
    CompletedKeyboxGui:FireServer(keyboxObj)
end

-- Event Bindings -- 
KeyboxGuiEvent.OnClientEvent:Connect(onKeyboxEvent)
Button.Activated:Connect(onButtonClicked)
