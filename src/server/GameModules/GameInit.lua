local GameInit = {}

-- Functions
function GameInit.init()
    -- Waiting until the game is loaded before doing anything (TODO: to be removed once loading screen is put in)
    repeat 
        task.wait() 
    until game.Loaded or game:IsLoaded()

end

return GameInit
