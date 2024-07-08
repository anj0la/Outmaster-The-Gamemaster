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

-- Local Functions --

-- Local function to clone a tool to a player
local function cloneHammerToPlayer(player, toolName, toolScriptName)
    -- check if the tool exists in ServerStorage
    local tool = ServerStorage:WaitForChild('Tools'):WaitForChild(toolName)
    local toolScript = ServerStorage:WaitForChild('ToolScripts'):WaitForChild(toolScriptName)
    if tool then
        -- clone the tool and script
        local clonedTool = tool:Clone()
        local clonedToolScript = toolScript:Clone()
        -- parent the cloned script to the cloned tool and the cloned tool to the player's backpack
        clonedToolScript.Parent = clonedTool
        print('we reached here')
        print('clonedTool', clonedTool)
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
        CloneGoldenHammer = InstanceFactory.createInstance('RemoteFunction', 'CloneGoldenHammer', RemoteFunctions)
        CloneGoldenHammer.OnServerInvoke = function(player)
            return cloneHammerToPlayer(player, 'Golden Hammer', 'HammerScript')
        end
    end
end

-- Function to clone a hammer to the gamemaster player (used ONLY on the server)
function CloneTool.cloneHammerToPlayer(gamemaster)
    -- check if the tool exists in ServerStorage
    local hammer = ServerStorage:WaitForChild('Tools'):WaitForChild('Hammer')
    local hammerScript = ServerStorage:WaitForChild('ToolScripts'):WaitForChild('HammerScript')
    if hammer then
        -- clone the tool and script
        local clonedHammer = hammer:Clone()
        local clonedHammerScript = hammerScript:Clone()
        -- parent the cloned script to the cloned tool and the cloned tool to the player's backpack
        clonedHammerScript.Parent = clonedHammer
        clonedHammer.Parent = gamemaster:WaitForChild('Backpack')
    else
        warn('Tool not found in ServerStorage.')
    end
end

return CloneTool