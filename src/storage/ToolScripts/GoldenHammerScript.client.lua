-- Services --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Player --
local Player = Players.LocalPlayer

-- Local Variables --
local goldenHammer = script.Parent
local hammerHead = goldenHammer:WaitForChild('Head')
local debounce = false
local canDamage = false
local swingTrack = nil

-- Remote Events --
local RemoteEvents = ReplicatedStorage.Shared:WaitForChild('RemoteEvents')
local GoldenHammerDamageEvent = RemoteEvents:WaitForChild('GoldenHammerDamageEvent')

-- Local Functions --

-- Local function to load the animation depending on whether the player is an R15 / R6 rig
local function onEquipped()
    local character = Player.Character
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local animator = humanoid:FindFirstChildOfClass('Animator') or humanoid:WaitForChild('Animator')
    local animation = Instance.new('Animation')
    
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        animation = goldenHammer:FindFirstChild('Swing')
    else
        animation = goldenHammer:FindFirstChild('SwingR6')
    end
    
    swingTrack = animator:LoadAnimation(animation)
end

-- Local function to check if we've hit a humanoid
local function didHitHumanoid(hit)
	-- we check to see if we've hit a body part (e.g., Head, LeftFoot), in which the parent is the Character model
	if hit.Parent:FindFirstChild('Humanoid') and hit.Parent:FindFirstChild('HumanoidRootPart') then
		return hit.Parent -- the parent is the Character model of the player that was hit

	-- otherwise, we have hit an accessory (e.g., a hat), and the Character model is the parent of the accessory
	elseif hit.Parent.Parent:FindFirstChild('Humanoid') and hit.Parent.Parent:FindFirstChild('HumanoidRootPart') then
		return hit.Parent.Parent -- the parent of the accessory (the parent of the part hit) is the Character model
	
    else
		return nil -- we did not hit another player, so return nil
	end
	
end

-- Local function to handle collision event
local function onHit(hit)
	local hitHumanoid = didHitHumanoid(hit)

	if canDamage and hitHumanoid then
		canDamage = false
		local hitPlayer = Players:GetPlayerFromCharacter(hitHumanoid)
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
		if not swingTrack.IsPlaying then
			swingTrack:Play()
		end

		-- connect the event and store the connection object
		local connection

		connection = hammerHead.Touched:Connect(function(hit)
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
