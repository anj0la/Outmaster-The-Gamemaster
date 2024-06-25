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

-- Local Variables -- 
local assignedKeyboxes = {}

-- Module Functions --

-- Function to initalize the keybox manager module by creating the required event and running the proximity check
function KeyboxManager.init()
    if not KeyboxGuiEvent  then
        KeyboxGuiEvent  = EventCreator.createEvent('RemoteEvent', 'KeyboxGuiEvent', RemoteEvents)
    end
end

function KeyboxManager.run(players)
    local keyboxes = workspace:WaitForChild('Keyboxes'):GetChildren()
    for _, keybox in ipairs(keyboxes) do
        assignedKeyboxes[keybox] = nil
    end

    -- here is where we would run our proximity code
    RunService.Heartbeat:Connect(function()
        KeyboxManager.checkProximity(players)
    end)
end

 -- Function to check proximity of players to keyboxes
function KeyboxManager.checkProximity(players)
    print('hi, are you working?')
    for _, player in ipairs(players) do
        -- importance check, if what is being collided is not a player, don't run this code
        if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
            for keybox, assignedPlayer in pairs(assignedKeyboxes) do

                -- getting the keybox position
                local keyboxPosition = keybox.Position
                local distance = player:GetDistanceFromCharacter(keyboxPosition)

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
    assignedKeyboxes[keybox] = player
    KeyboxGuiEvent:FireClient(player, true) -- show GUI
end

-- Function to release a keybox
function KeyboxManager.releaseKeybox(player, keybox)
    assignedKeyboxes[keybox] = nil
    KeyboxGuiEvent:FireClient(player, false) -- hide GUI
end

return KeyboxManager




