-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Player --
local Player = Players.LocalPlayer

-- Local Variables --
local goldenHammer = script.Parent
local debounce = false
local canDamage = false
local swingTrack = nil
local r6AnimationId = 'rbxassetid://18240152719' 
local r15AnimationId = 'rbxassetid://18239965862'

-- Remote Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local GoldenHammerDamageEvent = RemoteEvents:WaitForChild('GoldenHammerDamageEvent')

-- Local Functions --

-- Local function to load the animation depending on whether the player is an R6 / R15 rig
local function onEquipped()
    local character = Player.Character
    
    local Humanoid = character:FindFirstChildOfClass('Humanoid')
    local Animator = Humanoid:FindFirstChildOfClass('Animator') or Humanoid:WaitForChild('Animator')
    
    local Animation = Instance.new('Animation')
    
    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
        Animation.AnimationId = r15AnimationId
    else
        Animation.AnimationId = r6AnimationId
    end
    
    swingTrack = Animator:LoadAnimation(Animation)
end

-- Local function to handle collision event
local function onHit(hit)
    if canDamage and hit.Parent:FindFirstChild('Humanoid') and hit.Parent:FindFirstChild('HumanoidRootPart') then
        canDamage = false
        local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
        if hitPlayer then
            GoldenHammerDamageEvent:FireServer(hitPlayer, Player)
        end
    end
end

-- Local function to play animation and handle hit event when tool is activated
local function onActivated()
    if not debounce then
        debounce = true
        canDamage = true
        
        -- play the swing track
        swingTrack:Play()
                
      -- connect the event and store the connection object
        local connection

        connection = goldenHammer.Handle.Touched:Connect(function(hit)
            onHit(hit)
            connection:Disconnect()  -- Disconnect the event after it's triggered once
        end)

        -- stop playing the swing track
        swingTrack.Stopped:Wait()
        
        canDamage = false
        task.wait(0.5)  -- add a short delay before allowing another swing
        debounce = false
    end
end

-- Event Bindings --
goldenHammer.Equipped:Connect(onEquipped)
goldenHammer.Activated:Connect(onActivated)
