---Note: This handles every player that joins the queue and the search for a game as well. This is meant to mainly communicate through playlistClass
---[[ Dependencies ]]---

local matchmakingData = _G.get "data/matchmakingData"

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
        print(self.skillRating.." is the amount of SR "..playerObject.Name.." has!")
        self.skillgapRadius = matchmakingData["minimumSkillGap"]
        self.eligiblePlayers = {self} --The players eligible to queue
        self.foundMatch = false
    end)()
    return self
end 

function playerQueueClass:SearchForPlayers()
    self.eligiblePlayers = {[1] = self}
    print("Searching for a match The skill gap radius is "..self.skillgapRadius)
    for index, playerClass in next, self.playlistClass.playersInQueue do 
        if(playerClass) then 
            if(self.playerObject ~= playerClass.playerObject) then 
                print(self.skillRating-playerClass.skillRating)
                print(0-self.skillRating+playerClass.skillRating)
                if(self.skillRating-playerClass.skillRating <= self.skillgapRadius and 0-self.skillRating+playerClass.skillRating <= 0-self.skillgapRadius) then 
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
end

function playerQueueClass:MatchFound()
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

    coroutine.wrap(function()
        while wait(5) do 
            if(self.foundMatch or self.skillgapRadius + matchmakingData["GapPerLoop"] >= matchmakingData["maximumSkillGap"]) then break end 
            self.skillgapRadius += matchmakingData["GapPerLoop"]
        end
    end)()
end


return playerQueueClass 