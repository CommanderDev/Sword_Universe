---[[ Dependencies ]]---
local playerClass = _G.get "sys/playerSystem/playerClass"

local playerManager = {}

function playerManager:connect()
    game.Players.PlayerAdded:Connect(function(playerObject)
        playerClass.new(playerObject)
    end)
end 

function playerManager:init()
    self:connect()
end 

return playerManager