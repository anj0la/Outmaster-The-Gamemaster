local GameManager = {}

-- Services --
local ServerScriptService = game:GetService('ServerScriptService')

-- Module Folders --
local Configurations = ServerScriptService.Server:WaitForChild('Configurations')
local GameModules = ServerScriptService.Server:WaitForChild('GameModules')
local UtilityModules = ServerScriptService.Server:WaitForChild('UtilityModules')

-- Module Scripts --
local CloneTool = require(UtilityModules:WaitForChild('CloneTool'))
local DisplayManager = require(GameModules:WaitForChild('DisplayManager'))
local GameInit = require(GameModules:WaitForChild('GameInit'))
local GameSettings = require(Configurations:WaitForChild('GameSettings'))
local MapManager = require(GameModules:WaitForChild('MapManager'))
local KeyboxManager = require(GameModules:WaitForChild('KeyboxManager'))
local PlayerManager = require(GameModules:WaitForChild('PlayerManager'))
local TeamManager = require(GameModules:WaitForChild('TeamManager'))
local Timer = require(UtilityModules:WaitForChild('Timer'))

-- Objects --
local intermissionTimer = Timer.new()
local playerHeadstartTimer = Timer.new()
local roundTimer = Timer.new()

-- Local Functions --

-- Local function to start a timer for the specified duration, running the callback function at the end
local function startTimer(timer, duration, callback)
    -- if a connection exists, then we skip this step, done to avoid creating multiple connections to a timer object
	if not timer._connection then
		timer._connection = timer.finished:Connect(callback)
	end
	timer:start(duration)
    
    -- updating the display status with the time left
	while timer:isRunning() do
		local _timeLeft = (math.floor(timer:getTimeLeft() + 1))
		DisplayManager.updateTimer(_timeLeft, nil)
		task.wait()
	end
end

local function runRoundLoop()

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
	-- removing the gui from the gamemaster
	DisplayManager.displayGamemasterRoleInfo(TeamManager.getGamemaster(), false)
	task.wait(GameSettings.TRANSITION_DURATION)
end

local function endRound()
	PlayerManager.removePlayersFromActive()
	print("Ending the round...")
	-- will be a boolean value check, sets some stopping variable to true or false i think
	-- displays winner or something 
end

-- Module Functions --

-- Function to initialize all events needed for multiple rounds (only needs to be called once)
function GameManager.init()
    GameInit.init()
    DisplayManager.init()
	KeyboxManager.init()
	--PlayerManager.init()
	TeamManager.init()
end

-- Function to wait for the required amount of players
function GameManager.waitForPlayers()
	if PlayerManager.getPlayerCount() < GameSettings.MINIMUM_PLAYERS then
        DisplayManager.updateTimer(nil, 'WAITING...')
    end
	while PlayerManager.getPlayerCount() < GameSettings.MINIMUM_PLAYERS do
        task.wait(GameSettings.TRANSITION_DURATION)
    end
end

-- Function to run intermission
function GameManager.runIntermission()
	print("Running intermission code")
    print('queued players: ', PlayerManager.getQueuedPlayers())
	DisplayManager.updatePlayersLeft(0, false)
	DisplayManager.updateTimer(nil, 'INTERMISSION')
	MapManager.startMapVoting()
	startTimer(intermissionTimer, GameSettings.INTERMISSION_DURATION, endVoting)
	task.wait(GameSettings.TRANSITION_DURATION)
end

-- Function to prepare the round after ending map voting and sending players into the game
function GameManager.prepareRound()
	print("Preparing the round...")
	PlayerManager.addPlayersToActive()
	MapManager.loadMap(PlayerManager.getActivePlayers())
    print('queued players: ', PlayerManager.getQueuedPlayers())
    print('active players: ', PlayerManager.getActivePlayers())

	-- initalizing the team manager (sets the gamemaster and players)
	TeamManager.initTeams(PlayerManager.getActivePlayers())
	DisplayManager.updateGamemaster(TeamManager.getGamemaster(), true) -- this is where we select the gamemaster and get the player

	-- spawning the players and gamemaster into the chosen maps
	TeamManager.spawnPlayersInGame()
	TeamManager.spawnGamemasterInGame()
	-- CHANGE FROM GETACTICEPLAYERS TO GETPLAYERS (because get active players includes the gamemaster, getplayers doesn't include it)
	-- only keeping it rn for testing purposes
	KeyboxManager.run(PlayerManager.getActivePlayers())
end

function GameManager.runPlayerHeadstart()
-- start timer for player headstart timer
	print("Starting timer for player head start...")
	DisplayManager.updateTimer(nil, 'ROUND STARTS IN')
	DisplayManager.updatePlayersLeft(PlayerManager.getPlayerCount(), true)
	DisplayManager.displayGamemasterRoleInfo(TeamManager.getGamemaster(), true)
	DisplayManager.displayActivateGui(TeamManager.getGamemaster(), true)

	startTimer(playerHeadstartTimer, GameSettings.PLAYER_HEAD_START_DURATION, startRound)
	-- displaying information to the gamemaster
	
	task.wait(GameSettings.TRANSITION_DURATION) 
end

function GameManager.runRound()
	print("Starting round timer...")
	DisplayManager.updateTimer(nil, 'TIME LEFT')
	startTimer(roundTimer, GameSettings.ROUND_DURATION, endRound)
	-- PUT GAME LOGIC HERE
	-- THIS IS WHERE WE WOULD PROBABLY PUT FPS STUFF
	-- when team manager thing ends, we need to fire an event that makes the timer go to 0, to fire the endRound
	-- so we'll need to use a bindable event called EndRound that fires once the Gamemaster has been killed or all the players have been
	-- killed
	-- so here, we need to have checks every minute or so to see if EndRound has been fired. If not, then we wait for a second before checking again.
	-- or maybe we check every second? not sure
	-- while roundTimer:IsRunning() do
	--   stuff = EndRound:Wait() -- waiting until the end is over (and getting the players / gamemaster winner)
	-- 	 break
	-- winner = stuff
	--  stopTimer(roundTimer)
	--  startTimer(roundTimer, 0, nil) -- already have a connection, done to fire the endRound event
	task.wait(GameSettings.TRANSITION_DURATION) 
end

function GameManager.resetRound()
	print("Resetting the round...")
	-- winner = nil
	DisplayManager.updateTimer(0, 'ENDING GAME')
	DisplayManager.displayActivateGui(TeamManager.getGamemaster(), false)
    print('active players: ', PlayerManager.getActivePlayers())
    print('queued players: ', PlayerManager.getQueuedPlayers())
	task.wait(GameSettings.TRANSITION_DURATION)
	TeamManager.resetGamemasterView()
	TeamManager.spawnPlayersInLobby(PlayerManager.getQueuedPlayers())
	-- PlayerManager.spawnPlayersInLobby()
	MapManager.removeMap()
	DisplayManager.updatePlayersLeft(0, false)
	DisplayManager.updateGamemaster(nil, false)

end
return GameManager