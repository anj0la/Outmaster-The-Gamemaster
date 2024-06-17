local GameInit = {}

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

-- Functions
function GameInit.init()
    -- Creating the Remote Events folder inside ReplicatedStorage
    local RemoteEvents = ReplicatedStorage.Shared:FindFirstChild('RemoteEvents')
    if not RemoteEvents then
        RemoteEvents = Instance.new('Folder')
        RemoteEvents.Name = 'RemoteEvents'
        RemoteEvents.Parent = ReplicatedStorage
    end

    -- Creating the Bindable Events folder inside ServerStorage
    local BindableEvents = ServerStorage:FindFirstChild('BindableEvents')
    if not BindableEvents then
        BindableEvents = Instance.new('Folder')
        BindableEvents.Name = 'BindableEvents'
        BindableEvents.Parent = ServerStorage
    end
    
    -- Waiting until the game is loaded before doing anything (TODO: to be removed once loading screen is put in)
    repeat 
        task.wait() 
    until game.Loaded or game:IsLoaded()

end

return GameInit
