-- Services
local ServerScriptService = game:GetService('ServerScriptService')

-- Module Folders
local GameModules = ServerScriptService.Server:WaitForChild('GameModules')

-- Module Scripts
local GameManager = require(GameModules:WaitForChild('GameManager'))

-- Initialization (adding required remote events)
GameManager.init()
print('game has been initialized')

-- Main game loop
while task.wait() do
	GameManager.waitForPlayers()
    GameManager.runIntermission()
    GameManager.prepareRound()
	GameManager.runPlayerHeadstart()
	GameManager.runRound()
	GameManager.resetRound()
end
