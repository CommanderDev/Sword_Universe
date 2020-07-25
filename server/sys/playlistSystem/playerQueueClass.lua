---Note: This handles every player that joins the queue and the search for a game as well. This is meant to mainly communicate through playlistClass
---[[ Dependencies ]]---
local DataStore2 = _G.get "DataStore2"

local playerQueueClass = {}
playerQueueClass.__index = playerQueueClass 

function playerQueueClass.new(playerObject, playlistClass)
    local self = setmetatable({}, playerQueueClass)
    coroutine.wrap(function()
        self.playerObject = playerObject
        self.playlistClass = playlistClass
        self.playerStore = DataStore2("PlayerStore", playerObject)
        self.playerSaves = self.playerStore:Get()
        self.skillRating = self.playerSaves["Skill Rating"]
        self.maxSkillGap = 50
        self.eligiblePlayers = {self} --The players eligible to queue
        self.foundMatch = false
    end)()
    return self
end 

function playerQueueClass:SearchForPlayers()
    self.eligiblePlayers = {[1] = self}
    print("Searching for a match")
    for index, playerClass in next, self.playlistClass.playersInQueue do 
        if(playerClass) then 
            if(self.skillRating-playerClass.skillRating <= self.maxSkillGap or playerClass.skillRating-self.skillRating+self.maxSkillGap <= 0) then 
                if(self.playerObject ~= playerClass.playerObject) then 
                    table.insert(self.eligiblePlayers, playerClass)
                    if(#self.eligiblePlayers >= self.playlistClass.minimumPlayers) then --Check so the amount of eligible players has the amount required to have a full match.  
                        for index = 1, self.playlistClass.maximumPlayers do --Loops from the first index found eligible to the maximumPlayers.
                            print(index)
                            local desiredClass = self.eligiblePlayers[index] --Gets the current indexed player's class
                            print(desiredClass.playerObject)
                            if(desiredClass) then 
                                desiredClass:MatchFound()
                            end
                        end
                    end
                end
            end 
        end 
    end
    return false
end

function playerQueueClass:MatchFound()
    print(self.playerObject.Name.." Found a match")
    self.foundMatch = true
    self.playlistClass.playersInQueue[self.playerObject] = nil
    self = nil 
end

function playerQueueClass:HandlePlayerQueue()
    coroutine.wrap(function()
        local foundMatch = self:SearchForPlayers()
        if(self.foundMatch) then 
            return
        end
        while wait(1) do --Cooldown for each check.
            local foundMatch = self:SearchForPlayers()
            if(self.foundMatch) then 
                break
            end
        end
    end)()
end


return playerQueueClass 