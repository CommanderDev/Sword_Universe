---[[ Services ]]----
local MessagingService = game:GetService("MessagingService")

---[[ Dependencies ]]---
local playlistClass = _G.get "sys/playlistSystem/playlistClass"

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


function CreatePlaylistClasses()
    local casual = playlistClasses["Casual"]
    local competitive = playlistClasses["Competitive"]
    local extras = playlistClasses["Extras"]

    ---[[ Rules for each mode ]]---
    local oneRules: rulesData.rules = {mode = "1v1", minimumPlayers = 2, maximumPlayers = 2, modeType = "Casual"}
    local twoRules: rulesData.rules = {mode = "2v2", minimumPlayers = 4, maximumPlayers = 4, modeType = "Casual"}
    local threeRules: rulesData.rules = {mode = "3v3", minimumPlayers = 6, maximumPlayers = 6, modeType = "Casual"}
    local fourRules: rulesData.rules = {mode = "4v4", minimumPlayers = 8, maximumPlayers = 8, modeType = "Casual"}

    casual["1v1"] = playlistClass.new(oneRules)
    casual["2v2"] = playlistClass.new(twoRules)
    casual["3v3"] = playlistClass.new(threeRules)
    casual["4v4"] = playlistClass.new(fourRules)
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

function playlistManager:connect() 
    local success, errorMessage = pcall(function()
    MessagingService:SubscribeAsync("Set Playlist Data", function(playlistData) --Setting the playlist data.
        local playlistData = playlistData.Data
        if(game.JobId == playlistData["Job ID"]) then --Makes sure the server is the one that required the data in the first place.
            if(not playlistData["Playlist Classes"]) then 
                print("Creating new classes")
                CreatePlaylistClasses() 
            else
                print("Setting playlist classes to published array")
                playlistClasses = playlistData["Playlist Classes"]
            end 
        end 
    end)

    MessagingService:SubscribeAsync("Get Playlist Data", function(jobId) --Get the playlist data
        local data = --The data that'll be published to the servers
        {
            ["Job ID"] = jobId.Data; 
            ["Playlist Classes"] = nil 
        }

        if(not isDefaultData) then  --Makes sure the data isn't empty so the server can update to the data all the other servers have
            data["Playlist Classes"] = playlistClasses
        end 
        MessagingService:PublishAsync("Set Playlist Data", data)
    end) 
        MessagingService:PublishAsync("Get Playlist Data", game.JobId)
    end)
    if(not success) then 
        print(errorMessage)
        CreatePlaylistClasses()
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