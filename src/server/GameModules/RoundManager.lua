local RoundManager = {}

-- Services
local ServerScriptService = game:GetService('ServerScriptService')

-- Module Folders
local Configurations = ServerScriptService.Server:WaitForChild('Configurations')
local GameModules = ServerScriptService.Server:WaitForChild('GameModules')
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts
local DisplayManager = require(GameModules:WaitForChild('DisplayManager'))
local GameInit = require(GameModules:WaitForChild('GameInit'))
local GameSettings = require(Configurations:WaitForChild('GameSettings'))
local MapManager = require(GameModules:WaitForChild('MapManager'))
local PlayerManager = require(GameModules:WaitForChild('PlayerManager'))
local Timer = require(UtilityModules:WaitForChild('Timer'))

-- Objects
local intermissionTimer = Timer.new()
local playerHeadstartTimer = Timer.new()
local roundTimer = Timer.new()

-- Local Functions
local function startTimer(timer, duration, callback)
    -- If a connection exists, then we skip this step
    -- This is done to avoid creating multiple connections to a timer object
	if not timer._connection then
		timer._connection = timer.finished:Connect(callback)
	end
	timer:start(duration)
    
    -- Updating the display status with the time left
	while timer:isRunning() do
		local _timeLeft = (math.floor(timer:getTimeLeft() + 1))
		DisplayManager.updateTimer(_timeLeft, nil)
		task.wait()
	end
end

local function stopTimer(timer)
	timer:stop()
end

local function endVoting()
	print('Ending map voting...')
    DisplayManager.updateTimer(0, nil)
	MapManager.endMapVoting()
	MapManager.selectChosenMap()
end

local function startRound()
	-- spawn the Gamemaster into the game
	print("Starting the round...")
	DisplayManager.updateTimer(0, nil)
	PlayerManager.spawnGamemasterInGame()
	task.wait(GameSettings.TRANSITION_DURATION)
end

local function endRound()
	PlayerManager.removePlayersFromActive()
	print("Ending the round...")
	-- will be a boolean value check, sets some stopping variable to true or false i think
	-- displays winner or something 
end

-- Module Functions
function RoundManager.init()
    GameInit.init()
    DisplayManager.init()
end

function RoundManager.initRound()
	DisplayManager.updatePlayersLeft(0, false)
	DisplayManager.updateGamemaster(nil, false)
end

function RoundManager.waitForPlayers()
	if PlayerManager.getPlayerCount() < GameSettings.MINIMUM_PLAYERS then
        DisplayManager.updateTimer(nil, 'WAITING...')
    end
	while PlayerManager.getPlayerCount() < GameSettings.MINIMUM_PLAYERS do
        task.wait(GameSettings.TRANSITION_DURATION)
    end
end

function RoundManager.runIntermission()
	print("Running intermission code")
    print('queued players: ', PlayerManager.getQueuedPlayers())
	DisplayManager.updatePlayersLeft(0, false)
	DisplayManager.updateTimer(nil, 'INTERMISSION')

	-- DELETE LATER, CAUSE WE NEEDA FIX THIS
	MapManager.startMapVoting()
	startTimer(intermissionTimer, GameSettings.INTERMISSION_DURATION, endVoting)
	task.wait(GameSettings.TRANSITION_DURATION)
end

function RoundManager.prepareRound()
	print("Preparing the round...")
	PlayerManager.addPlayersToActive()
    print('queued players: ', PlayerManager.getQueuedPlayers())
    print('active players: ', PlayerManager.getActivePlayers())
	-- getting the gamemaster
	PlayerManager.assignGamemaster()
	DisplayManager.updateGamemaster(PlayerManager.getGamemaster(), true) -- this is where we select the gamemaster and get the player

	-- spawning the players into the chosen map
	PlayerManager.spawnPlayersInGame()
end

function RoundManager.runRound()
	-- start timer for player headstart timer
	print("Starting timer for player head start...")
	DisplayManager.updateTimer(nil, 'ROUND STARTS IN')
	DisplayManager.updatePlayersLeft(PlayerManager.getPlayerCount(), true)
	startTimer(playerHeadstartTimer, GameSettings.PLAYER_HEAD_START_DURATION, startRound)
	task.wait(GameSettings.TRANSITION_DURATION) -- used to ensure that startRound is called before starting the timer
	print("Starting round timer...")
	DisplayManager.updateTimer(nil, 'TIME LEFT')
	startTimer(roundTimer, GameSettings.INTERMISSION_DURATION, endRound) -- change from intermission to round duration [there for testing purposes]
	task.wait(GameSettings.TRANSITION_DURATION) -- so that we don't run resetRound before endRound
end

function RoundManager.resetRound()
	print("Resetting the round...")
	DisplayManager.updateTimer(0, 'ENDING GAME')
    print('active players: ', PlayerManager.getActivePlayers())
    print('queued players: ', PlayerManager.getQueuedPlayers())
	task.wait(GameSettings.TRANSITION_DURATION)
	PlayerManager.spawnPlayersInLobby()
	MapManager.removeMap()
	DisplayManager.updatePlayersLeft(0, false)
	DisplayManager.updateGamemaster(nil, false)
end
return RoundManager