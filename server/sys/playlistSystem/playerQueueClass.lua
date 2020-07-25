---Note: This handles every player that joins the queue and the search for a game as well. This is meant to mainly communicate through playlistClass

local playerQueueClass = {}
playerQueueClass.__index = playerQueueClass 

function playerQueueClass.new(playerObject, playlistClass)
    local self = setmetatable({}, playerQueueClass)
    self.playerObject = playerObject
    self.playlistClass = playlistClass
    self:HandlePlayerQueue()
    return self
end 

function playerQueueClass:HandlePlayerQueue()
    print(self.playerObject.Name.."'s queue is being handled")
end


return playerQueueClass 