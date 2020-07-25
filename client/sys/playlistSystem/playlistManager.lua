---[[ Services ]]---
local ContentProvider = game:GetService("ContentProvider")

local playlistManager = {}

---[[ Player Object ]]---
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---[[ UI Components ]]---
local mainUI = playerGui:WaitForChild("mainUI")
local playscreenFrame = mainUI:WaitForChild("playscreenFrame")

local modeLabel = playscreenFrame:WaitForChild("modeLabel")

local findmatchButton = playscreenFrame:WaitForChild("findmatchButton")
local tabsFolder = playscreenFrame:WaitForChild("tabsFolder")

local uiComponents = game.ReplicatedStorage:WaitForChild("uiComponents")
local listTemplate = uiComponents:WaitForChild("listTemplate")
local playlistTemplates = uiComponents:WaitForChild("playlistTemplates")

---[[ Declarations ]]---
local playlistsData

local selectedModeType = "Casual" --Determines which frame is shown.
---[[ Types ]]---
type playlistType = string

local playlistSelections = {} --Holds data for which playlists in each tab are selected.

local tabSelectionImages = --The images for showing what state each tab is in.
{
    ["Hovered"] = 5429722513;
    ["Selected"] = 5429719007;
    ["Unselected"] = 5429437645
}
---[[ Tweens ]]---
local normalTabSize = tabsFolder:GetChildren()[1].Size 
local normalTabPosition = tabsFolder:GetChildren()[1].Position 

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
        local desiredPlaylist = playlistTemplates:FindFirstChild(index.."Playlist")
        if(desiredPlaylist) then 
            desiredPlaylist = desiredPlaylist:Clone()
        end

       -- local newPlaylist = playlistTemplate:Clone()
        --local modeLabel = desiredPlaylist:WaitForChild("modeLabel")
       -- modeLabel.Text = playlist.mode
        desiredPlaylist.Name = playlist.mode
        desiredPlaylist.Parent = newList 
        local checkmark = desiredPlaylist:WaitForChild("checkmarkLabel")
        playlistSelections[typeOfPlaylist][playlist.mode] = false
        desiredPlaylist.MouseButton1Click:Connect(function()
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

local currentTab = nil --This is so all the functions know which tab to change. Mainly for image changing.

function setImage(contentId, status)
    currentTab.Image = Enum.AssetFetchStatus.Success == status and contentId or ""
end 

function tabSelected(tabObject)
    tabObject:TweenSize(UDim2.new(normalTabSize.X.Scale+0.025, 0, tabObject.Size.Y.Scale, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.01, false)
    local waitingImage = "http://www.roblox.com/asset/?id=5429718965"
    ContentProvider:PreloadAsync({waitingImage}, setImage)
    tabObject.ZIndex = 2
end 

function tabUnselected(tabObject) 
    tabObject:TweenSize(normalTabSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.01, false)
    local waitingImage = "http://www.roblox.com/asset/?id=5429437615" --Unselected
    ContentProvider:PreloadAsync({waitingImage}, setImage)
    tabObject.ZIndex = 1
end 

function hoverTab(tabObject)
    local waitingImage = "http://www.roblox.com/asset/?id=5429722480"
    tabObject.ZIndex = 3
    ContentProvider:PreloadAsync({waitingImage}, setImage)
end 

function unhoverTab(tabObject, modeType)
    print(modeType)
    if(modeType == selectedModeType) then 
       tabSelected(tabObject)
       
    else
        tabUnselected(tabObject)
    end
end 

function HandleTabSelections()
    modeLabel.Text = selectedModeType.." Play"
    for index, tabButton in next, tabsFolder:GetChildren() do 
        local start, finish = string.find(tabButton.Name, "Tab") --Finds the tab so the client can find the playlist type assigned to the button.
        local modeType = string.sub(tabButton.Name, 1, start-1)
        local desiredFrame = playscreenFrame:FindFirstChild(modeType)
        if(desiredFrame) then 
            if(modeType == selectedModeType) then 
                tabSelected(tabButton)
                desiredFrame.Visible = true
            else 
                tabUnselected(tabButton)
                desiredFrame.Visible = false
            end
        end
    end 
end 

function HandleTabs() --Handles the tabs for playlists.
    for index, tabButton in next, tabsFolder:GetChildren() do 
        currentTab = tabButton
        local start, finish = string.find(tabButton.Name, "Tab") --Finds the tab so the client can find the playlist type assigned to the button.
        local modeType = string.sub(tabButton.Name, 1, start-1)
        if(start) then 
            if(modeType == selectedModeType) then 
                tabSelected(tabButton)
            else 
                tabUnselected(tabButton)
            end
        end
        tabButton.MouseEnter:Connect(function()
            currentTab = tabButton
            hoverTab(tabButton)
        end)
        tabButton.MouseLeave:Connect(function()
            currentTab = tabButton
            unhoverTab(tabButton, modeType)
        end)

        tabButton.MouseButton1Click:Connect(function()
            selectedModeType = modeType 
            HandleTabSelections()
        end)
    end 
end 

function playlistManager:connect()
    playlistsData = _G.network:invokeServer("Get Playlist Data")
    CreatePlaylists("Casual")
    CreatePlaylists("Competitive")
    HandleTabs()
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