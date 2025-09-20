local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HopMenu"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, -100, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local openCloseButton = Instance.new("TextButton")
openCloseButton.Size = UDim2.new(0, 50, 0, 30)
openCloseButton.Position = UDim2.new(0, 0, 0, -35)
openCloseButton.Text = "Menu"
openCloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
openCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openCloseButton.Parent = screenGui

local hopButton = Instance.new("TextButton")
hopButton.Size = UDim2.new(0, 180, 0, 40)
hopButton.Position = UDim2.new(0, 10, 0, 10)
hopButton.Text = "Hop Server"
hopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
hopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hopButton.Visible = false
hopButton.Parent = frame

local function getEmptyServers(placeId)
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and result.data then
        for _, server in ipairs(result.data) do
            if server.playing and server.playing <= 1 then
                table.insert(servers, server.id)
            end
        end
    end
    return servers
end

local function hopToEmptyServer()
    local placeId = game.PlaceId
    local emptyServers = getEmptyServers(placeId)
    if #emptyServers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, emptyServers[1])
    else
        TeleportService:Teleport(placeId)
    end
end

openCloseButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

hopButton.MouseButton1Click:Connect(function()
    hopToEmptyServer()
end)

if UserInputService.TouchEnabled then
    openCloseButton.Size = UDim2.new(0, 70, 0, 40)
    hopButton.Size = UDim2.new(0, 190, 0, 50)
end
