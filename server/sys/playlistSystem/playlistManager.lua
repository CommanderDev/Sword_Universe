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
        ["Competitve"] = {};
        ["Extras"] = {}
    }
    return data 
end 

local playlistClasses = CreatePlaylistData()

function CreatePlaylistClasses()
    local casual = playlistClasses["Casual"]
    local competitve = playlistClasses["Competitve"]
    local extras = playlistClasses["Extras"]

    ---[[ Rules for each mode ]]---
    local oneRules: rulesData.rules = {mode = "1v1", minimumPlayers = 1, maximumPlayers = 1, modeType = "Casual"}
    local twoRules: rulesData.rules = {mode = "2v2", minimumPlayers = 2, maximumPlayers = 2, modeType = "Casual"}
    local threeRules: rulesData.rules = {mode = "3v3", minimumPlayers = 3, maximumPlayers = 3, modeType = "Casual"}
    local fourRules: rulesData.rules = {mode = "4v4", minimumPlayers = 4, maximumPlayers = 4, modeType = "Casual"}

    casual["1v1"] = playlistClass.new(oneRules)
    casual["2v2"] = playlistClass.new(twoRules)
    casual["3v3"] = playlistClass.new(threeRules)
    casual["4v4"] = playlistClass.new(fourRules)

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
        print("Setting playlist data")
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
        print(jobId.Data)
        print("Getting playlist data")
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

    _G.network:setCallback("Get Playlist Data", function()
        return playlistClasses
    end)
end 

function playlistManager:init()
    self:connect()
end

return playlistManager