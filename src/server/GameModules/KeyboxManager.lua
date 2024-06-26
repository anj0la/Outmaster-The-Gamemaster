local KeyboxManager = {}

-- Services --
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ServerScriptService = game:GetService('ServerScriptService')

-- Module Folders --
local Configurations = ServerScriptService.Server:WaitForChild('Configurations')
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts --
local GameSettings = require(Configurations:WaitForChild('GameSettings'))
local EventCreator = require(UtilityModules:WaitForChild('EventCreator'))

-- Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local KeyboxGuiEvent  = RemoteEvents:FindFirstChild('KeyboxGuiEvent')
local CompletedKeyboxGui  = RemoteEvents:FindFirstChild('CompletedKeyboxGui')

-- Local Variables -- 
local assignedKeyboxes = {}
local collectedKeyboxes = 0
local required_keyboxes = nil

-- Local Functions -- 

local function increaseKeyCount()
    print('increasing the key count')
    collectedKeyboxes += 1
    print('collected keyboxes: ', collectedKeyboxes)
end

-- Module Functions --

-- Function to initalize the keybox manager module by creating the required event and running the proximity check
function KeyboxManager.init()
    if not KeyboxGuiEvent  then
        KeyboxGuiEvent  = EventCreator.createEvent('RemoteEvent', 'KeyboxGuiEvent', RemoteEvents)
    end
    if not CompletedKeyboxGui  then
        CompletedKeyboxGui  = EventCreator.createEvent('RemoteEvent', 'CompletedKeyboxGui', RemoteEvents)
    end

    -- Event Bindings --
    CompletedKeyboxGui.OnServerEvent:Connect(increaseKeyCount)
end

function KeyboxManager.run(players)
    local keyboxes = workspace:WaitForChild('Keyboxes'):GetChildren()
    required_keyboxes = #keyboxes

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
                    if not assignedPlayer then 
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
    KeyboxGuiEvent:FireClient(player, true) -- show GUI
end

-- Function to release a keybox
function KeyboxManager.releaseKeybox(player, keybox)
    print('running the released code')
    assignedKeyboxes[keybox] = nil
    KeyboxGuiEvent:FireClient(player, false) -- hide GUI
end

return KeyboxManager




