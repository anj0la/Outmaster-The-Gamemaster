-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Guis --
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local CompletedKeyboxGui  = RemoteEvents:FindFirstChild('CompletedKeyboxGui')
local KeyboxGuiEvent = RemoteEvents:WaitForChild('KeyboxGuiEvent')

-- Guis --
local Guis = ReplicatedStorage.Shared:WaitForChild('Guis')
local KeyboxGames = Guis:WaitForChild('KeyboxGames')

-- Local Functions --

-- Local function to change the activated game text
local function changeActivateGameText(keybox)
    local activateGame = keybox:WaitForChild('ActivateGame')
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

-- Local function to allow the key to be collected
local function onCompletedGame(keybox)
    local keyboxGameGui = PlayerGui:FindFirstChild('KeyboxGame_' .. keybox.Name)
    keyboxGameGui:Destroy()
    changeActivateGameText(keybox)
    CompletedKeyboxGui:FireServer(keybox)
end

-- Local function to display the keyboard game gui
local function onKeyboxEvent(keybox, showGui)
    local keyboxGameGui = PlayerGui:FindFirstChild('KeyboxGame_' .. keybox.Name)
    
    if not keyboxGameGui then
        local keyboxGameTemplate = KeyboxGames:FindFirstChild('KeyboxGame_' .. keybox.Name)
        if keyboxGameTemplate then
            keyboxGameGui = keyboxGameTemplate:Clone()
            keyboxGameGui.Parent = PlayerGui
        else
            warn('KeyboxGame GUI template for ' .. keybox.Name .. ' not found!')
            return
        end
    end
    
    -- show or hide the GUI
    keyboxGameGui.Enabled = showGui
    
    if showGui then
        -- set up the button event
        local button = keyboxGameGui:WaitForChild('BaseFrame'):WaitForChild('TextButton')
        button.Activated:Connect(function()
            onCompletedGame(keybox)
        end)
    else
        keyboxGameGui:Destroy()
    end
end


-- Event Bindings -- 
KeyboxGuiEvent.OnClientEvent:Connect(onKeyboxEvent)
