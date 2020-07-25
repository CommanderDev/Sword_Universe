---[[ Dependencies ]]---
local playerQueueClass = _G.get "sys/playlistSystem/playerQueueClass"

local playlistClass = {}
playlistClass.__index = playlistClass 

local rulesData = _G.get "data/rulesData"

local rules = rulesData.rules
function playlistClass.new(playlistRules)
    local self = setmetatable({}, playlistClass)
    for index, rule in next, playlistRules do
        self[index] = rule
    end
    print(self.mode)
    self.playersInQueue = {}
    return self
end 

function playlistClass:AddPlayerToQueue(playerObject)
    self.playersInQueue[playerObject] = playerQueueClass.new(playerObject, self)
end 


return playlistClass 