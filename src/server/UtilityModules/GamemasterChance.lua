local GamemasterChance = {}

-- Services --
local MarketplaceService = game:GetService('MarketplaceService')

-- Local Variables --
local passId = 12345 -- placeholder
-- local weights = {}
-- Local Functions --

-- Local function to check if the player has the gamemaster x2 pass
local function hasGamemasterPass(player)
    return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId) ~= nil -- returns true if the child was found and returns false if the child was not found
end

-- Module Functions --


--[[ function GamemasterChance.initWeights(activePlayers)
    for _, player in ipairs(activePlayers) do
        local weight = 1
        if hasGamemasterPass(player) then -- increase the weights by 2
            weight = weight * 2
        end
        table.insert(weights, {player = player, weight = weight})
    end
end ]]

-- Function to select the gamemaster
function GamemasterChance.selectGamemaster(activePlayers)
    local weights = {}
    local totalWeight = 0

    -- assign weights to each player
    for _, player in ipairs(activePlayers) do
        local weight = 1
        if hasGamemasterPass(player) then -- increase the weights by 2
            weight = weight * 2
        end
        table.insert(weights, {player = player, weight = weight})
        totalWeight = totalWeight + weight
    end

    -- generate a random number between 1 and the total weight
    local randomWeight = math.random() * totalWeight
    local cumulativeWeight = 0

    -- select the player based on the random weight
    for _, entry in ipairs(weights) do
        cumulativeWeight = cumulativeWeight + entry.weight
        if randomWeight <= cumulativeWeight then
            return entry.player
        end
    end
end

return GamemasterChance