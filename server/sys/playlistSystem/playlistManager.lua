---[[ Services ]]----
local MessagingService = game:GetService("MessagingService")

---[[ Dependencies ]]---
local playlistClass = _G.get "sys/playlistSystem/playlistClass"

local playlistManager = {}

type rules = 
    {
        mode: string;
        minumumPlayers: string;
        maxiumumPlayers: string;
        modeType: string;
    }
    

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
    casual["1v1"] = playlistClass.new()
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
    MessagingService:SubscribeAsync("Set Playlist Data", function(playlistData)
        print("Setting playlist data")
        local playlistData = playlistData.Data
        if(game.JobId == playlistData["Job ID"]) then 
            if(not playlistData["Playlist Classes"]) then 
                print("Creating new classes")
                CreatePlaylistClasses() 
            else
                print("Setting playlist classes to published array")
                playlistClasses = playlistData["Playlist Classes"]
            end 
        end 
    end)
    MessagingService:SubscribeAsync("Get Playlist Data", function(jobId)
        print(jobId.Data)
        for index, value in next, jobId do 
            print(index)
            print(value)
        end 
        print(game.JobId)
        print("Getting playlist data")
        local data = 
        {
            ["Job ID"] = jobId.Data; 
            ["Playlist Classes"] = nil 
        }

        if(not isDefaultData) then 
            data["Playlist Classes"] = playlistClasses
        end 
        MessagingService:PublishAsync("Set Playlist Data", data)
    end) 

    MessagingService:PublishAsync("Get Playlist Data", game.JobId)
end 

function playlistManager:init()
    self:connect()
end

return playlistManager