local playlistClass = {}
playlistClass.__index = playlistClass 

local rulesData = _G.get "data/rulesData"

local rules = rulesData.rules
function playlistClass.new(playlistRules)
    local self = setmetatable(playlistRules, playlistClass)
    print(self.mode)
    self.playersInQueue = {}
    return self
end 

function playlistClass:PlayerAddedToQueue(playerObject)

end 


return playlistClass 