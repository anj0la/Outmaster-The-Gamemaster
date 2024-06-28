local KeyboxManager = {}

-- Services --
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')

-- Module Folders --
local Configurations = ServerScriptService.Server:WaitForChild('Configurations')
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts --
local GameSettings = require(Configurations:WaitForChild('GameSettings'))
local InstanceFactory = require(UtilityModules:WaitForChild('InstanceFactory'))

-- Remote Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local KeyboxGuiEvent = RemoteEvents:FindFirstChild('KeyboxGuiEvent')
local CompletedKeyboxGui = RemoteEvents:FindFirstChild('CompletedKeyboxGui')
local IncreaseKeyCount = RemoteEvents:FindFirstChild('IncreaseKeyCount')
local OpenSecretDoor = RemoteEvents:FindFirstChild('OpenSecretDoor')

-- Remote Functions --
local RemoteFunctions = ReplicatedStorage.Shared:WaitForChild('RemoteFunctions')
local CloneToolFunction = RemoteFunctions:FindFirstChild('CloneToolFunction')

-- Guis --
local Guis = ReplicatedStorage.Shared:WaitForChild('Guis')
local KeyboxGames = Guis:WaitForChild('KeyboxGames')
local TemplateKeyboxGames = Guis:WaitForChild('TemplateKeyboxGames')

-- Local Variables -- 
local assignedKeyboxes = {}
local unlockedKeyboxes = {}
local collectedKeyboxes = 0
local requiredKeyboxes = nil

-- Local Functions -- 

local function openKeyboxDoor(player, keybox)
    print('Destroying the door so that players can collect the key')
    local door = keybox:WaitForChild('Front')
    door:Destroy()

    unlockedKeyboxes[keybox] = true
    assignedKeyboxes[keybox] = nil
end

local function getKeyboxGames(keyboxes)
    local numKeyboxes = #keyboxes
    local keyboxGameGuis = TemplateKeyboxGames:GetChildren()

    -- assign the first three keyboxes specific GUIs
    for i = 1, math.min(3, numKeyboxes) do
        local keybox = keyboxes[i]
        local keyboxGameGui = keyboxGameGuis[i]:Clone()
        keyboxGameGui.Name = 'KeyboxGame_' .. keybox.Name
        keyboxGameGui.Parent = KeyboxGames
    end

    -- assign the remaining keyboxes random GUIs
    for i = 4, numKeyboxes do
        local keybox = keyboxes[i]
        local randomIndex = math.random(1, #keyboxGameGuis)
        local keyboxGameGui = keyboxGameGuis[randomIndex]:Clone()
        keyboxGameGui.Name = 'KeyboxGame_' .. keybox.Name
        keyboxGameGui.Parent = KeyboxGames
    end
end

local function increaseKeyCount(player)
    print('increasing the key count')
    collectedKeyboxes += 1
    print('collected keyboxes: ', collectedKeyboxes)

    if collectedKeyboxes >= requiredKeyboxes then
        local secretRoom = workspace:WaitForChild('SecretRoom')
        print('fire event to ALL clients to open the secret door and make it accessible for players')
        OpenSecretDoor:FireAllClients(secretRoom)     
    end
end

local function cloneToolToPlayer(player, toolName)
    -- check if the tool exists in ServerStorage
    local tool = ServerStorage:WaitForChild('Tools'):FindFirstChild(toolName)
    if tool then
        -- clone the tool
        local clonedTool = tool:Clone()
        -- parent the cloned tool to the player's backpack
        clonedTool.Parent = player:WaitForChild('Backpack')
        return true
    else
        warn('Tool not found in ServerStorage.')
        return false
    end
end 

-- Module Functions --

-- Function to initalize the keybox manager module by creating the required event and running the proximity check
function KeyboxManager.init()
    if not KeyboxGuiEvent then
        KeyboxGuiEvent = InstanceFactory.createInstance('RemoteEvent', 'KeyboxGuiEvent', RemoteEvents)
    end
    if not CompletedKeyboxGui then
        CompletedKeyboxGui = InstanceFactory.createInstance('RemoteEvent', 'CompletedKeyboxGui', RemoteEvents)
    end
    if not IncreaseKeyCount then
        IncreaseKeyCount = InstanceFactory.createInstance('RemoteEvent', 'IncreaseKeyCount', RemoteEvents)
    end
    if not OpenSecretDoor then
        OpenSecretDoor = InstanceFactory.createInstance('RemoteEvent', 'OpenSecretDoor', RemoteEvents)
    end
    if not CloneToolFunction then
        CloneToolFunction = InstanceFactory.createInstance('RemoteFunction', 'CloneToolFunction', RemoteFunctions)
    end

    -- Event Bindings --
    CompletedKeyboxGui.OnServerEvent:Connect(openKeyboxDoor)
    IncreaseKeyCount.OnServerEvent:Connect(increaseKeyCount)
    CloneToolFunction.OnServerInvoke = function(player)
        return cloneToolToPlayer(player, 'Golden Hammer')
    end
end

function KeyboxManager.run(players)
    local keyboxes = workspace:WaitForChild('Keyboxes'):GetChildren()
    requiredKeyboxes = #keyboxes

    getKeyboxGames(keyboxes)

    -- here is where we would run our proximity code
    RunService.Heartbeat:Connect(function()
        KeyboxManager.checkProximity(players, keyboxes)
    end)
end

 -- Function to check proximity of players to keyboxes
function KeyboxManager.checkProximity(players, keyboxes)

    for _, player in pairs(players) do
        -- if what is being collided is not a player, don't run this code
        if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then

            for _, keybox in pairs(keyboxes) do
                
                -- getting the keybox position
                local keyboxPosition = keybox:GetPivot().Position
                local distance = player:DistanceFromCharacter(keyboxPosition)

                -- getting the assigned player
                local assignedPlayer = assignedKeyboxes[keybox]
                -- print('printing the assigned player: ', assignedPlayer)

                -- if the distance is less than the threshold and hasn't been assigned to a player, display the minigame GUI
                if distance <= GameSettings.PROXIMITY_THRESHOLD then
                    if not assignedPlayer and not unlockedKeyboxes[keybox] then 
                        KeyboxManager.claimKeybox(player, keybox)
                    end
                -- otherwise, the player has moved far enough away from the keybox, so unassign them from it
                elseif assignedPlayer == player then
                    KeyboxManager.releaseKeybox(player, keybox)
                end
            end
        end
    end
end

-- Function to claim a keybox
function KeyboxManager.claimKeybox(player, keybox)
    print('running the claim code')
    assignedKeyboxes[keybox] = player
    KeyboxGuiEvent:FireClient(player, keybox, true) -- show GUI
end

-- Function to release a keybox
function KeyboxManager.releaseKeybox(player, keybox)
    print('running the released code')
    assignedKeyboxes[keybox] = nil
    KeyboxGuiEvent:FireClient(player, keybox, false) -- hide GUI
end

return KeyboxManager




