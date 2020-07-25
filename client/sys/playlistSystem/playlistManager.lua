local playlistManager = {}

---[[ Player Object ]]---
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---[[ UI Components ]]---
local mainUI = playerGui:WaitForChild("mainUI")
local playscreenFrame = mainUI:WaitForChild("playscreenFrame")

---[[ Lower Tabs Frame ]]---
local lowerTabsFrame = playscreenFrame:WaitForChild("lowerTabsFrame")
local findmatchButton = lowerTabsFrame:WaitForChild("findmatchButton")

local uiComponents = game.ReplicatedStorage:WaitForChild("uiComponents")
local listTemplate = uiComponents:WaitForChild("listTemplate")
local playlistTemplate = uiComponents:WaitForChild("playlistTemplate")
---[[ Declarations ]]---
local playlistsData

local selectedModeType = "Casual" --Determines which frame is shown.
---[[ Types ]]---
type playlistType = string

local playlistSelections = {} --Holds data for which playlists in each tab are selected.

function CreatePlaylists(typeOfPlaylist: playlistType)
    local newList = listTemplate:Clone()
    newList.Parent = playscreenFrame 
    newList.Name = typeOfPlaylist
    if(typeOfPlaylist == selectedModeType) then 
        newList.Visible = true 
    else
        newList.Visible = false
    end 
   playlistSelections[typeOfPlaylist] = {} --Adds a table to the type of playlist desired.
   for index, playlist in next, playlistsData[typeOfPlaylist] do
        local newPlaylist = playlistTemplate:Clone()
        local modeLabel = newPlaylist:WaitForChild("modeLabel")
        modeLabel.Text = playlist.mode
        newPlaylist.Name = playlist.mode
        newPlaylist.Parent = newList 
        local checkmark = newPlaylist:WaitForChild("checkmarkLabel")
        playlistSelections[typeOfPlaylist][playlist.mode] = false
        newPlaylist.MouseButton1Click:Connect(function()
            if(not playlistSelections[typeOfPlaylist][playlist.mode]) then 
                playlistSelections[typeOfPlaylist][playlist.mode] = true
                checkmark.Visible = true
            else
                playlistSelections[typeOfPlaylist][playlist.mode] = false
                checkmark.Visible = false
            end
        end)
    end
end 

function playlistManager:connect()
    playlistsData = _G.network:invokeServer("Get Playlist Data")
    CreatePlaylists("Casual")
    CreatePlaylists("Competitive")

    findmatchButton.MouseButton1Click:Connect(function()
        local selectedPlaylistSelections = playlistSelections[selectedModeType]
        local selectedPlaylists = {}
        local inAPlaylist = false --Determines if a player is in a playlist or not.
        for index, playlistSelected in next, selectedPlaylistSelections do 
            if(playlistSelected) then 
                selectedPlaylists[index] = true 
                inAPlaylist = true 
            end
        end
        if(inAPlaylist) then  
            _G.network:fireServer("Queue Player", selectedModeType,selectedPlaylists)
        else 
            print("No playlists selected")
        end
    end)
end 

function playlistManager:init()
    self:connect()
end

return playlistManager 