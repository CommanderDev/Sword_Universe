---[[ Dependencies ]]---
local DataStore2 = _G.get "DataStore2"

local playerClass = {}
playerClass.__index = playerClass 

---[[ Data Store Combine ]]---
DataStore2.Combine("DATA", "PlayerStore")

function CreatePlayerData() --Creates the default player data 
    local data = 
    {
        ["Skill Rating"] = 0;
    }
    return data
end 

function playerClass.new(playerObject) 
    local self = setmetatable({}, playerClass)
    local defaultPlayerData = CreatePlayerData()
    self.playerObject = playerObject
    self.playerStore = DataStore2("PlayerStore", playerObject)
    self.playerSaves = self.playerStore:Get(defaultPlayerData)
    self:HandlePlayerEvents()
    return self
end 

function playerClass:HandlePlayerEvents()
    self.playerStore:OnUpdate(function()
        self.playerSaves = self.playerStore:Get()
    end)
end

return playerClass