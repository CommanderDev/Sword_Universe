local playlistManager = {}

---[[ Player Object ]]---
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---[[ UI Components ]]---
local mainUI = playerGui:WaitForChild("mainUI")
local playscreenFrame = mainUI:WaitForChild("playscreenFrame")

local uiComponents = game.ReplicatedStorage:WaitForChild("uiComponents")
local listTemplate = uiComponents:WaitForChild("listTemplate")
local playlistTemplate = uiComponents:WaitForChild("playlistTemplate")
---[[ Declarations ]]---
local playlistsData

---[[ Types ]]---
type playlistType = string

function CreatePlaylists(typeOfPlaylist: playlistType)
    print(playlistsData)
    local newList = listTemplate:Clone()
    newList.Parent = playscreenFrame 
    newList.Name = typeOfPlaylist

   for index, playlist in next, playlistsData[typeOfPlaylist] do
        local newPlaylist = playlistTemplate:Clone()
        local modeLabel = newPlaylist:WaitForChild("modeLabel")
        modeLabel.Text = playlist.mode
        newPlaylist.Name = playlist.mode
        newPlaylist.Parent = newList 
    end 
end 

function playlistManager:connect()
    playlistsData = _G.network:invokeServer("Get Playlist Data")
    CreatePlaylists("Casual")
end 

function playlistManager:init()
    self:connect()
end

return playlistManager 