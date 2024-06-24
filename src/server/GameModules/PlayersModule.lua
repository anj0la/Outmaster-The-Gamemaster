local PlayersModule = {}

-- Services
local ServerScriptService = game:GetService('ServerScriptService')
local Teams = game:GetService('Teams')

-- Local Variables

-- Local Functions

-- Module Functions

--[[ Spawn a number of key boxes that are dependent on the amount of players that are in the game:
3-4 players - X keys
5-6 players - X + 1 keys
7 players - X + 2 keys
 X will be determined after testing the game, but for now, we assume X = 3.
 ]]


return PlayersModule