-- Services
local ServerScriptService = game:GetService('ServerScriptService')

-- Module Scripts
local GameModules = ServerScriptService.Server:WaitForChild('GameModules')
local GameInit = require(GameModules:WaitForChild('GameInit'))

-- Initialization (adding remote events and bindable events folder to required services)
GameInit.init()

-- Main game loop
while task.wait() do
	task.wait()
end
