---Note: This handles every player that joins the queue and the search for a game as well. This is meant to mainly communicate through playlistClass

---[[ Services ]]---
local servermessagingManager = _G.get "sys/servermessagingSystem/servermessagingManager"

---[[ Dependencies ]]---
local matchmakingData = _G.get "data/matchmakingData"

local DataStore2 = _G.get "DataStore2"

local playerQueueClass = {}
playerQueueClass.__index = playerQueueClass 

function playerQueueClass.new(playerObject, skillRating,playlistClass)
    local self = setmetatable({}, playerQueueClass)
    coroutine.wrap(function()
        self.playerObject = playerObject
        self.playlistClass = playlistClass
        self.skillgapRadius = matchmakingData["minimumSkillGap"]
        self.skillRating = skillRating
        self.eligiblePlayers = {self} --The players eligible to queue
        self.foundMatch = false
    end)()
    return self
end 

function playerQueueClass:SearchForPlayers()
    self.eligiblePlayers = {[1] = self}
    print("Searching for a match The skill gap radius is "..self.skillgapRadius)
    local playersInMatch = {} --Only used if a match is found. Makes it so all the players are added to the match array accordingly.
    for index, playerClass in next, self.playlistClass.playersInQueue do
        if(typeof(playerClass) == "table" and playerClass.playerObject) then 
            print(playerClass.skillRating)
            if(self.playerObject ~= playerClass.playerObject and playerClass.skillRating) then 
                if(self.skillgapRadius < self.skillRating - playerClass.skillRating and self.skillgapRadius < self.skillRating+playerClass.skillRating) then return end
                    table.insert(self.eligiblePlayers, playerClass)
                    local actualPlayers = 0 --Check so it knows they are actual players.
                    if(#self.eligiblePlayers >= self.playlistClass.minimumPlayers) then --Check so the amount of eligible players has the amount required to have a full match.  
                        --for index = 1, self.playlistClass.maximumPlayers do --Loops from the first index found eligible to the maximumPlayers.
                        print("More or equal to enough players for a match!")
                          table.foreach(self.eligiblePlayers, function(index, desiredClass)
                            print(index)
                            local desiredClass = self.eligiblePlayers[index] --Gets the current indexed player's class
                            if(desiredClass and desiredClass.playerObject) then 
                                desiredClass:MatchFound()
                                table.insert(playersInMatch, self.playerObject.Name)
                                actualPlayers += 1
                            end
                        end)
                        if(actualPlayers >= self.playlistClass.minimumPlayers) then 
                            local data = 
                            {
                                ["Topic"] = self.playlistClass.modeType.." "..self.playlistClass.mode.." Match Begun";
                                ["Players In Match"] = playersInMatch
                            }
                            servermessagingManager:PublishData(self.playlistClass.matchBegunTopic, data)
                           -- MessagingService:PublishAsync("Server Message",data)
                        end
                    end
               -- end
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
    self.playerObject = game.Players:FindFirstChild(self.playerObject)
    self.playerStore = DataStore2("PlayerStore", self.playerObject)
    self.playerSaves = self.playerStore:Get()
    coroutine.wrap(function()
        print("About to search for match")
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