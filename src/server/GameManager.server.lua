-- Services
local ServerScriptService = game:GetService('ServerScriptService')

-- Module Folders
local GameModules = ServerScriptService.Server:WaitForChild('GameModules')

-- Module Scripts
local RoundManager = require(GameModules:WaitForChild('RoundManager'))

-- Initialization (adding required remote events)
RoundManager.init()
print('game has been initialized')

-- Main game loop
while task.wait() do
	RoundManager.waitForPlayers()
    RoundManager.runIntermission()
    RoundManager.prepareRound()
	RoundManager.runPlayerHeadstart()
	RoundManager.runRound()
	RoundManager.resetRound()
end
