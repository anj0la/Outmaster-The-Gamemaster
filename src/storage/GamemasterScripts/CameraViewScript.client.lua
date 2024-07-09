-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

-- Remote Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local ToggleFirstPerson = RemoteEvents:WaitForChild('ToggleFirstPerson') -- note that this event is created via the Team Manager module

-- Local Player --
local Player = Players.LocalPlayer
print('hi, local player: ', Player)

-- Local Variables --
local backpack = Player:WaitForChild('Backpack')
local camera = workspace.CurrentCamera
local character = Player.Character
local hammer = backpack:WaitForChild('Hammer')
local humanoid = character:FindFirstChildOfClass('Humanoid')

-- Local Functions --

-- Local function to enable first-person view
local function toggleFirstPerson(firstPerson)
    if firstPerson then
        print('we should be running')
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = character.Head.CFrame
        character.Head.LocalTransparencyModifier = 0.5
        character.HumanoidRootPart.LocalTransparencyModifier = 0.5
        Player.CameraMode = Enum.CameraMode.LockFirstPerson
        -- disabling the backpack
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) 
        -- equipping the tool (has been cloned to player's backpack)
        humanoid:EquipTool(hammer)

    else -- firstPerson = false
        camera.CameraType = Enum.CameraType.Custom
        Player.CameraMode = Enum.CameraMode.Classic
        character.Head.LocalTransparencyModifier = 0
        character.HumanoidRootPart.LocalTransparencyModifier = 0
        -- enabling the backpack
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        -- no need to destroy the hammer, when players are respawned, the backpack contents are removed
    end

end

-- Event Bindings --
ToggleFirstPerson.OnClientEvent:Connect(toggleFirstPerson)
