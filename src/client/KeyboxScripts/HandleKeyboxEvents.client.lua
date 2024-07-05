-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Guis --
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')

-- Remote Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local CompletedKeyboxGui = RemoteEvents:WaitForChild('CompletedKeyboxGui')
local KeyboxGuiEvent = RemoteEvents:WaitForChild('KeyboxGuiEvent')
local IncreaseKeyCount = RemoteEvents:WaitForChild('IncreaseKeyCount')
local OpenSecretDoor = RemoteEvents:WaitForChild('OpenSecretDoor')

-- Remote Functions --
local RemoteFunctions = ReplicatedStorage.Shared:WaitForChild('RemoteFunctions')
local CloneToolFunction = RemoteFunctions:WaitForChild('CloneToolFunction')

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

-- Local function to collect the key
local function onCollectedKey(player, key)
    print('player who collected the key: ', player)
    
    -- destroying the key (along with the prompt) to indicate that it has been 'collected'
    key:Destroy()

    -- increasing the key count (which will be unlocked from the server side)
    IncreaseKeyCount:FireServer()
    
end

-- Local function to allow the key to be collected
local function onCompletedGame(keybox)
    local keyboxGameGui = PlayerGui:FindFirstChild('KeyboxGame_' .. keybox.Name)
    local key = keybox:WaitForChild('Key')

     -- creating a proximity prompt and parenting it the key
     local proximityPrompt = Instance.new('ProximityPrompt')
     proximityPrompt.Name = 'ProximityPrompt'
     proximityPrompt.HoldDuration = 1
     proximityPrompt.ObjectText = 'Golden Key'
     proximityPrompt.ActionText = 'Collect Key'
     proximityPrompt.Enabled = true
     proximityPrompt.Parent = key

    -- adding event to collect the key (and destroy it afterwards)
    proximityPrompt.Triggered:Connect(function(player)
    onCollectedKey(player, key)
    end)

    keyboxGameGui:Destroy()
    changeActivateGameText(keybox)
    CompletedKeyboxGui:FireServer(keybox)
end

-- Local function to display the keyboard game gui
local function onKeyboxEvent(keybox, showGui)
    print(keybox)
    print(showGui)
    local keyboxGameGui = PlayerGui:FindFirstChild('KeyboxGame_' .. keybox.Name)
    print('did we fire??? here is the keybox: ', keybox)
    print('show gui: ', showGui)
    
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

local function onCollectedGoldenHammer(player, goldenHammer)
    goldenHammer:Destroy()
    -- call the RemoteFunction to clone the tool to the player's backpack
    local success = CloneToolFunction:InvokeServer()
    if success then
        print('Tool successfully cloned to backpack.') -- delete later
        -- fire event to run local script
        -- local characterFolder = player:Character:WaitForChild('Character')
        -- local goldenHammerScript = 
    else
        warn('Failed to clone tool to backpack.')
    end

end

-- Local Function to enable the proximity prompt
local function onOpenSecretDoor(secretRoom)
    local front = secretRoom:WaitForChild('Front')
    local goldenHammer = secretRoom:WaitForChild('GoldenHammer')

    -- creating a proximity prompt and parenting it the golden hammer
    local proximityPrompt = Instance.new('ProximityPrompt')
    proximityPrompt.Name = 'ProximityPrompt'
    proximityPrompt.HoldDuration = 1
    proximityPrompt.ObjectText = 'Golden Hammer'
    proximityPrompt.ActionText = 'Obtain Golden Hammer'
    proximityPrompt.Enabled = true
    proximityPrompt.Parent = goldenHammer

    -- adding event to collect the hammer (and destroy it afterwards)
    proximityPrompt.Triggered:Connect(function(player)
        onCollectedGoldenHammer(player, goldenHammer)
        end)
    
    front:Destroy()
end

-- Event Bindings -- 
KeyboxGuiEvent.OnClientEvent:Connect(onKeyboxEvent)
OpenSecretDoor.OnClientEvent:Connect(onOpenSecretDoor)
