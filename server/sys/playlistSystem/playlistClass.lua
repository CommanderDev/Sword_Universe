local MessagingService = game:GetService("MessagingService")

---[[ Dependencies ]]---
local playerQueueClass = _G.get "sys/playlistSystem/playerQueueClass"

local playlistClass = {}
playlistClass.__index = playlistClass 

local rulesData = _G.get "data/rulesData"

local rules = rulesData.rules
function playlistClass.new(playlistRules, playlistManager)
    local self = setmetatable({}, playlistClass)
    coroutine.wrap(function()
        for index, rule in next, playlistRules do
            self[index] = rule
        end
        self.playersInQueue = {}
        self.playlistManager = playlistManager
    end)()
    self:HandleMessaging()
    return self
end 


function playlistClass:HandleMessaging()
    local success, errorMessage = pcall(function()
        --[[MessagingService:SubscribeAsync("Server Message",self.modeType.." "..self.mode.." Match Begun", function(playersInMatch)
            for index, value in next, playersInMatch do
                print(value)
            end
        end)
    end)]]
        self.playlistManager.topicFunctions[self.modeType.." "..self.mode.." Match Begun"] = function(playersInMatch)
            for index, value in next, playersInMatch do 
                print(value)
            end
        end
        self.playlistManager.topicFunctions[self.modeType.." "..self.mode.." Player Added to queue"] = function(data)
            print(data.playerObject.." added to the queue!")
            local newPlayerQueue = playerQueueClass.new(data.playerObject, self)
            self.playersInQueue[data.playerObject] = newPlayerQueue
        if(game.Players:FindFirstChild(data.playerObject)) then 
            data.playerObject = game.Players:FindFirstChild(data.playerObject)
            newPlayerQueue:HandlePlayerQueue()
            print("Publishing data received")
            end
        end
    end)
    if(not success) then 
        print(errorMessage)
    end
end 

function playlistClass:AddPlayerToQueue(playerObject)
    if(not self.playersInQueue[playerObject]) then 
     --   local newPlayerQueue = playerQueueClass.new(playerObject, self)
        local data =
        {
            Topic = self.modeType.." "..self.mode.." Player Added to queue";
            playerObject = playerObject.Name
        }
        print("Publishing data!")
        MessagingService:PublishAsync("Server Message", data)
        print("Data published!")
        --self.playersInQueue[playerObject] = newPlayerQueue 
        --newPlayerQueue:HandlePlayerQueue()
    end
end 


return playlistClass 