---[[ Services ]]----
local MessagingService = game:GetService("MessagingService")

---[[ Dependencies ]]---
local playlistClass = _G.get "sys/playlistSystem/playlistClass"

local servermessagingManager = _G.get "sys/servermessagingSystem/servermessagingManager"

local rulesData = _G.get "data/rulesData"

local playlistManager = {}

--[[type rules = 
    {
        mode: string;
        minumumPlayers: string;
        maxiumumPlayers: string;
        modeType: string;
    }
    
]]

function CreatePlaylistData()
    local data = 
    {
        ["Casual"] = {};
        ["Competitive"] = {};
        ["Extras"] = {}
    }
    return data 
end 

local playlistClasses = CreatePlaylistData()

playlistManager.topicFunctions = {}


function CreatePlaylistClasses()
    local casual = playlistClasses["Casual"]
    local competitive = playlistClasses["Competitive"]
    local extras = playlistClasses["Extras"]

    ---[[ Rules for each mode ]]---
    local oneRules: rulesData.rules = {mode = "1v1", minimumPlayers = 2, maximumPlayers = 2, modeType = "Casual"}
    local twoRules: rulesData.rules = {mode = "2v2", minimumPlayers = 4, maximumPlayers = 4, modeType = "Casual"}
    local threeRules: rulesData.rules = {mode = "3v3", minimumPlayers = 6, maximumPlayers = 6, modeType = "Casual"}
    local fourRules: rulesData.rules = {mode = "4v4", minimumPlayers = 8, maximumPlayers = 8, modeType = "Casual"}

    casual["1v1"] = playlistClass.new(oneRules, playlistManager)
    casual["2v2"] = playlistClass.new(twoRules,playlistManager)
    casual["3v3"] = playlistClass.new(threeRules,playlistManager)
    casual["4v4"] = playlistClass.new(fourRules,playlistManager)
    oneRules.modeType = "Competitive"
    competitive["1v1"] = oneRules
end 

function isDefaultData(): boolean
    for index, data in next, playlistClasses do 
        if(#data > 0) then
            return false 
        end
    end 
    return true
end 


---[[ Topic Functions]]---

function playlistManager:connect() 
    CreatePlaylistClasses()
    local success, errorMessage = pcall(function()
        servermessagingManager:SubscribeTopic("Get Playlist Data", function(playlistData)
            local data = --The data that'll be published to the servers
            {
                ["Job ID"] = playlistData.jobId; 
                ["Playlist Classes"] = nil;
                Topic = "Set Playlist Data"
            }
            if(not isDefaultData) then  --Makes sure the data isn't empty so the server can update to the data all the other servers have
                data["Playlist Classes"] = playlistClasses
            end 
            servermessagingManager:PublishData(data)
        end)
        servermessagingManager:SubscribeTopic("Set Playlist Data", function(playlistData) 
        print("Setting player data")
            if(game.JobId == playlistData["Job ID"]) then --Makes sure the server is the one that required the data in the first place.
                if(not playlistData["Playlist Classes"]) then 
                    CreatePlaylistClasses() 
                else
                    playlistClasses = playlistData["Playlist Classes"]
                end 
            end 
        end)
        local dataToPublish =
        {
            jobId = game.jobId;
            Topic = "Get Playlist Data"
        }
        servermessagingManager:PublishData(dataToPublish)
    end)

    if(not success) then 
        print(errorMessage)
    end 


    ---[[ Events ]]---
    _G.network:createEventListener("Queue Player", function(playerObject, modeType, playlistsToQueue)
        for index, value in next, playlistsToQueue do
            local class = playlistClasses[modeType][index]
            class:AddPlayerToQueue(playerObject)
        end
    end)
    ---[[ Functions ]]---
    _G.network:setCallback("Get Playlist Data", function()
        return playlistClasses
    end)
end 

function playlistManager:init()
    self:connect()
end

return playlistManager