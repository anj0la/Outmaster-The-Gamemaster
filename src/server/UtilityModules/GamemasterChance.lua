local GamemasterChance = {}

-- Services
local ServerScriptService = game:GetService('ServerScriptService')
local MarketplaceService = game:GetService('MarketplaceService')

-- Module Folders
local GameModules = ServerScriptService.Server:WaitForChild('GameModules')

-- Module Scripts
local PlayerManager = require(GameModules:WaitForChild('PlayerManager'))

-- Developer Product Id
local passId = 12345 -- placeholder

-- Local Functions
local function hasGamemasterPass(player)
    return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId) ~= nil -- returns true if the child was found and returns false if the child was not found
end

-- Module Functions
function GamemasterChance.selectGamemaster()
    local activePlayers = PlayerManager.getActivePlayers()
    local weights = {}
    local totalWeight = 0

    -- Assign weights to each player
    for _, player in ipairs(activePlayers) do
        local weight = 1
        if hasGamemasterPass(player) then -- increase the weights by 2
            weight = weight * 2
        end
        table.insert(weights, {player = player, weight = weight})
        totalWeight = totalWeight + weight
    end

    -- Generate a random number between 1 and the total weight
    local randomWeight = math.random() * totalWeight
    local cumulativeWeight = 0

    -- Select the player based on the random weight
    for _, entry in ipairs(weights) do
        cumulativeWeight = cumulativeWeight + entry.weight
        if randomWeight <= cumulativeWeight then
            return entry.player
        end
    end
end

return GamemasterChance