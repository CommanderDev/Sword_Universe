---Note: This handles every player that joins the queue and the search for a game as well. This is meant to mainly communicate through playlistClass

local playerQueueClass = {}
playerQueueClass.__index = playerQueueClass 

function playerQueueClass.new(playerObject, playlistClass)
    local self = setmetatable({}, playerQueueClass)
    coroutine.wrap(function()
        self.playerObject = playerObject
        self.playlistClass = playlistClass
        self:HandlePlayerQueue()
    end)()
    return self
end 

function playerQueueClass:SearchForPlayers()
    print(self.playlistClass.playersInQueue)
    for index, playerClass in next, self.playlistClass.playersInQueue do 
        print(playerClass.playerObject.Name)
    end 
end 

function playerQueueClass:HandlePlayerQueue()
    print(self.playerObject.Name.."'s queue is being handled")
    self:SearchForPlayers()
end


return playerQueueClass 