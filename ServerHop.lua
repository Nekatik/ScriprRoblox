local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HopMenu"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local openCloseButton = Instance.new("TextButton")
openCloseButton.Size = isMobile and UDim2.new(0, 80, 0, 45) or UDim2.new(0, 60, 0, 35)
openCloseButton.Position = UDim2.new(0, 10, 0, 10)
openCloseButton.Text = "Меню"
openCloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
openCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openCloseButton.BorderSizePixel = 0
openCloseButton.ZIndex = 2
openCloseButton.Parent = screenGui

local frame = Instance.new("Frame")
frame.Size = isMobile and UDim2.new(0, 220, 0, 170) or UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 10, 0, isMobile and 60 or 50)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Visible = false
frame.ZIndex = 1
frame.Parent = screenGui

local hopButton = Instance.new("TextButton")
hopButton.Size = UDim2.new(0, isMobile and 200 or 180, 0, isMobile and 50 or 40)
hopButton.Position = UDim2.new(0, 10, 0, 10)
hopButton.Text = "Hop Server One"
hopButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hopButton.BorderSizePixel = 0
hopButton.ZIndex = 2
hopButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, isMobile and 200 or 180, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, isMobile and 70 or 60)
statusLabel.Text = "Готово"
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.ZIndex = 2
statusLabel.Parent = frame

local function tweenButton(button)
    local tween = TweenService:Create(
        button,
        TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}
    )
    tween:Play()
    tween.Completed:Connect(function()
        local tweenBack = TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
        )
        tweenBack:Play()
    end)
end

local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

local function getBestServer(placeId)
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if not success then
        updateStatus("Помилка API", Color3.fromRGB(255, 100, 100))
        return nil
    end
    
    if result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing and server.playing <= 1 then
                table.insert(servers, {
                    id = server.id,
                    ping = math.random(30, 100)
                })
            end
        end
    end
    
    if #servers == 0 then
        updateStatus("Немає серверів", Color3.fromRGB(255, 150, 100))
        return nil
    end
    
    table.sort(servers, function(a, b) return a.ping < b.ping end)
    return servers[1].id
end

local function hopToEmptyServer()
    updateStatus("Пошук...", Color3.fromRGB(255, 200, 100))
    
    local placeId = game.PlaceId
    local bestServer = getBestServer(placeId)
    
    if not bestServer then
        updateStatus("Помилка", Color3.fromRGB(255, 100, 100))
        return
    end
    
    updateStatus("Перехід...", Color3.fromRGB(100, 255, 100))
    
    local success, errorMsg = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, bestServer)
    end)
    
    if not success then
        updateStatus("Помилка телепорту", Color3.fromRGB(255, 100, 100))
        warn("Помилка телепорту: " .. tostring(errorMsg))
    end
end

openCloseButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    openCloseButton.Text = frame.Visible and "Закрити" or "Меню"
end)

hopButton.MouseButton1Click:Connect(function()
    tweenButton(hopButton)
    hopToEmptyServer()
end)

if isMobile then
    local touchGui = Instance.new("ScreenGui")
    touchGui.Name = "TouchControl"
    touchGui.Parent = CoreGui
    touchGui.ResetOnSpawn = false
    
    local touchFrame = Instance.new("Frame")
    touchFrame.Size = UDim2.new(0, 100, 0, 100)
    touchFrame.Position = UDim2.new(1, -110, 1, -110)
    touchFrame.BackgroundTransparency = 1
    touchFrame.Parent = touchGui
    
    local touchButton = Instance.new("TextButton")
    touchButton.Size = UDim2.new(0, 80, 0, 80)
    touchButton.Position = UDim2.new(0, 10, 0, 10)
    touchButton.Text = ""
    touchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    touchButton.BackgroundTransparency = 0.8
    touchButton.BorderSizePixel = 0
    touchButton.Parent = touchFrame
    
    touchButton.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        openCloseButton.Text = frame.Visible and "Закрити" or "Меню"
    end)
end
