---[[ Dependencies ]]---
local playerQueueClass = _G.get "sys/playlistSystem/playerQueueClass"

local playlistClass = {}
playlistClass.__index = playlistClass 

local rulesData = _G.get "data/rulesData"

local rules = rulesData.rules
function playlistClass.new(playlistRules)
    local self = setmetatable({}, playlistClass)
    coroutine.wrap(function()
        for index, rule in next, playlistRules do
            self[index] = rule
        end
        print(self.mode)
        self.playersInQueue = {}
    end)()
    return self
end 

function playlistClass:AddPlayerToQueue(playerObject)
    local newPlayerQueue = playerQueueClass.new(playerObject, self)
    self.playersInQueue[playerObject] = newPlayerQueue 
    newPlayerQueue:HandlePlayerQueue()
end 


return playlistClass 