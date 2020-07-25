---Note: This handles every player that joins the queue and the search for a game as well. This is meant to mainly communicate through playlistClass

local playerQueueClass = {}
playerQueueClass.__index = playerQueueClass 

function playerQueueClass.new(playerObject, playlistClass)
    local self = setmetatable({}, playerQueueClass)
    coroutine.wrap(function()
        self.playerObject = playerObject
        self.playlistClass = playlistClass
        self.eligiblePlayers = {self} --The players eligible to queue
    end)()
    return self
end 

function playerQueueClass:SearchForPlayers()
    self.eligiblePlayers = {}
    for index, playerClass in next, self.playlistClass.playersInQueue do 
        if(playerClass) then 
            table.insert(self.eligiblePlayers, playerClass)
            if(#self.eligiblePlayers >= self.playlistClass.minimumPlayers) then 
                for index = 1, self.playlistClass.maximumPlayers do --Loops from the first index found eligible to the maximumPlayers.
                    local desiredClass = self.eligiblePlayers[index] --Gets player's class
                    print(playerClass.playerObject.Name)
                    if(desiredClass) then 
                        desiredClass:MatchFound()
                    end
                end
            end
        end
    end 
end 

function playerQueueClass:MatchFound()
    print(self.playerObject.Name.." Found a match")
end

function playerQueueClass:HandlePlayerQueue()
    self:SearchForPlayers()
end


return playerQueueClass 