---[[ Services ]]---
local MessagingService = game:GetService("MessagingService")

local servermessagingManager = {}

local signals = {}

function servermessagingManager:connect()
    MessagingService:SubscribeAsync("Server Message", function(dataPublished)
        local data = dataPublished.Data 
        local topic = data.Topic
        print(topic)
        --print(signals[topic])
        if(signals[topic]) then 
            local success, errorMessage = pcall(signals[topic], data)
            if(not success) then
                print(errorMessage)
            end
        end
    end)
end 

function servermessagingManager:PublishData(data)
    local success, errorMessage = pcall(function()
        MessagingService:PublishAsync("Server Message", data)
    end)
end 

function servermessagingManager:SubscribeTopic(topic, func)
    if(not signals[topic]) then
        signals[topic] = func
        print(topic)
    end
end 

function servermessagingManager:init()
    self:connect()
end 

return servermessagingManager