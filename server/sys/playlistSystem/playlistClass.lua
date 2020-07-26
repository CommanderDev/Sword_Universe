
---[[ Dependencies ]]---
local playerQueueClass = _G.get "sys/playlistSystem/playerQueueClass"

local servermessagingManager = _G.get "sys/servermessagingSystem/servermessagingManager"

local DataStore2 = _G.get "DataStore2"

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
        
        ---[[ Topics ]]---
        self.matchBegunTopic = self.modeType.." "..self.mode.." Match Begun"
        self.addedToQueueTopic = self.modeType.." "..self.mode.." Player Added to queue"
    end)()
    self:HandleMessaging()
    return self
end 


function playlistClass:HandleMessaging()
   -- local success, errorMessage = pcall(function()
        servermessagingManager:SubscribeTopic(self.matchBegunTopic, function(data)
            local playersInMatch = data["Players In Match"]
            for index, value in next, playersInMatch do 
                print(value.." successfully joined the match!")
            end
        end)

        servermessagingManager:SubscribeTopic("Match Found", function(data) 
            local playerObject = game.Players.FindFirstChild(data.playerObject)
            print("Match found!")
            if(playerObject and self.playersInMatch[playerObject]) then 
                print(playerObject)
                self.playersInMatch[data.playerObject]:MatchFound()
                print(playerObject.Name.." Found a match")
            end
        end)

        servermessagingManager:SubscribeTopic(self.addedToQueueTopic, function(data)
            print(data.playerObject.." added to the queue!")
            local newPlayerQueue = playerQueueClass.new(data.playerObject, data.skillRating, self)
            self.playersInQueue[data.playerObject] = newPlayerQueue
            if(game.Players:FindFirstChild(data.playerObject)) then 
                data.playerObject = game.Players:FindFirstChild(data.playerObject)
                newPlayerQueue:HandlePlayerQueue()
                print("Publishing data received")
                end
            end)
        --end)
  --  if(not success) then 
     --   print(errorMessage)
  --  end
end 

function playlistClass:AddPlayerToQueue(playerObject)
    if(not self.playersInQueue[playerObject.Name]) then 
     --   local newPlayerQueue = playerQueueClass.new(playerObject, self)
        local playerStore = DataStore2("PlayerStore", playerObject)
        local playerSaves = playerStore:Get()
        local data =
        {
            Topic = self.addedToQueueTopic;
            playerObject = playerObject.Name;
            skillRating = playerSaves["Skill Rating"]
        }
        servermessagingManager:PublishData(data)
        --MessagingService:PublishAsync("Server Message", data)
        --self.playersInQueue[playerObject] = newPlayerQueue 
        --newPlayerQueue:HandlePlayerQueue()
    end
end 


return playlistClass 