local playlistManager = {}

---[[ Player Object ]]---
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---[[ UI Components ]]---
local mainUI = playerGui:WaitForChild("mainUI")
local playscreenFrame = mainUI:WaitForChild("playscreenFrame")

local uiComponents = game.ReplicatedStorage:WaitForChild("uiComponents")
local listTemplate = uiComponents:WaitForChild("listTemplate")

---[[ Declarations ]]---
local playlistsData

---[[ Types ]]---
type playlistType = string

function CreatePlaylists(typeOfPlaylist: playlistType)
    print(playlistsData)
   for index, playlist in next, playlistsData[typeOfPlaylist] do
        print(playlist.mode)
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