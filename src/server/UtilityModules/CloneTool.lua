local CloneTool = {}

-- Services --
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')

-- Module Folders --
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts --
local InstanceFactory = require(UtilityModules:WaitForChild('InstanceFactory'))

-- Remote Functions --
local RemoteFunctions = ReplicatedStorage.Shared:WaitForChild('RemoteFunctions')
local CloneGoldenHammer = RemoteFunctions:FindFirstChild('CloneGoldenHammer')
local CloneHammer = RemoteFunctions:FindFirstChild('CloneGamemasterHammer')

-- Local Functions --

-- Local function to clone a tool to a player
local function cloneToolToPlayer(player, toolName, toolScriptName)
    -- check if the tool exists in ServerStorage
    local tool = ServerStorage:WaitForChild('Tools'):WaitForChild(toolName)
    local toolScript = ServerStorage:WaitForChild('ToolScripts'):WaitForChild(toolScriptName)
    if tool then
        -- clone the tool and script
        local clonedTool = tool:Clone()
        local clonedToolScript = toolScript:Clone()
        -- parent the cloned script to the cloned tool and the cloned tool to the player's backpack
        clonedToolScript.Parent = clonedTool
        clonedTool.Parent = player:WaitForChild('Backpack')
        return true
    else
        warn('Tool not found in ServerStorage.')
        return false
    end
end 

-- Module Functions --

-- Function to initialize the remote functions needed for cloning the hammer and golden hammer
function CloneTool.init()
    if not CloneGoldenHammer then
        CloneGoldenHammer = InstanceFactory.createInstance('RemoteFunction', 'CloneToolFunction', RemoteFunctions)
        CloneGoldenHammer.OnServerInvoke = function(player)
            return cloneToolToPlayer(player, 'Golden Hammer', 'GoldenHammerScript')
        end
    end
    if not CloneHammer then
        CloneHammer = InstanceFactory.createInstance('RemoteFunction', 'CloneGamemasterHammer', RemoteFunctions)
        CloneHammer.OnServerInvoke = function(player)
            return cloneToolToPlayer(player, 'Hammer', 'HammerScript')
        end
    end
end

return CloneTool