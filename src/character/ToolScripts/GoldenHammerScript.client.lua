-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Player / Backpack --
local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild('Backpack')

-- Local Variables --
local goldenHammer = Backpack:FindFirstChild('Golden Hammer')
local debounce = false
local canDamage = false
local swingTrack = nil
local r6AnimationId = 'rbxassetid://1719543171' 
local r15AnimationId = 'rbxassetid://1719543171'

-- Remote event for damage handling
local damageEvent = ReplicatedStorage:WaitForChild("DamageEvent")

local function onEquipped()
    local character = Player.Character
    
    local Humanoid = character:FindFirstChildOfClass('Humanoid')
    local Animator = Humanoid:FindFirstChildOfClass('Animator') or Humanoid:WaitForChild('Animator')
    
    local Animation = Instance.new("Animation")
    
    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
        Animation.AnimationId = r15AnimationId
    else
        Animation.AnimationId = r6AnimationId
    end
    
    swingTrack = Animator:LoadAnimation(Animation)
end

local function onHit(hit)
    if canDamage and hit.Parent:FindFirstChild('Humanoid') and hit.Parent:FindFirstChild('HumanoidRootPart') then
        canDamage = false
        local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
        if hitPlayer then
            damageEvent:FireServer(hitPlayer, Player)
        end
    end
end

local function onActivated()
    if not debounce then
        debounce = true
        canDamage = true
        
        swingTrack:Play()
                
      -- connect the event and store the connection object
        local connection

        connection = goldenHammer.Handle.Touched:Connect(function(hit)
            onHit(hit)
            connection:Disconnect()  -- Disconnect the event after it's triggered once
        end)

        
        swingTrack.Stopped:Wait()
        
        canDamage = false
        task.wait(0.5)  -- add a short delay before allowing another swing
        debounce = false
    end
end

-- Event Bindings --
goldenHammer.Equipped:Connect(onEquipped)
goldenHammer.Activated:Connect(onActivated)
