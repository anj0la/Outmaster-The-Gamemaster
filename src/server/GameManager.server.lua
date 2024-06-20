-- Services
local ServerScriptService = game:GetService('ServerScriptService')

-- Module Folders
local GameModules = ServerScriptService.Server:WaitForChild('GameModules')

-- Module Scripts
local DisplayManager = require(GameModules:WaitForChild('DisplayManager'))
local GameInit = require(GameModules:WaitForChild('GameInit'))
local RoundManager = require(GameModules:WaitForChild('RoundManager'))

-- Initialization (adding required remote events)
print('game is initalizing')
GameInit.init()
DisplayManager.init()

-- Main game loop
while task.wait() do
	RoundManager.waitForPlayers()
    RoundManager.runIntermission()
    RoundManager.prepareRound()
	RoundManager.runRound()
	RoundManager.resetRound()
end
