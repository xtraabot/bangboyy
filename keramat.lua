-- ambil FishingConfig
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishingSystemFolder = ReplicatedStorage:WaitForChild("FishingSystem")
local FishingConfigModule = FishingSystemFolder:WaitForChild("FishingConfig")
local FishingConfig = require(FishingConfigModule)
local MiniGameSystem = require(FishingSystemFolder.FishingModules.MinigameSystem)

-- simpan backup selectFish sekali
if not getgenv().OriginalSelectFish then
    local env = getsenv(player.PlayerScripts:FindFirstChild("FishingSystem"))
    getgenv().OriginalSelectFish = env.selectFish_upvr
end

-- Fungsi reload paksa yang lengkap
local function forceReloadConfig()
    package.loaded[FishingConfigModule] = nil
    FishingConfig = require(FishingConfigModule)

    -- update referensi di FishingSystem
    local env = getsenv(player.PlayerScripts:FindFirstChild("FishingSystem"))
    env.module_upvr_11 = FishingConfig

    -- rebuild DefaultProbabilities agar sinkron
    DefaultProbabilities = {}
    for _, fish in pairs(FishingConfig.FishTable) do
        DefaultProbabilities[fish.name] = fish.probability
    end
end

-- Backup default sekali
if not getgenv().OriginalTapCounts then
    getgenv().OriginalTapCounts = {}
    for rodName, taps in pairs(FishingConfig.MinigameSettings.rodTapCount) do
        getgenv().OriginalTapCounts[rodName] = taps
    end
    getgenv().OriginalDefaultTap = FishingConfig.MinigameSettings.rodTapCount.default
    getgenv().OriginalFishingTime = FishingConfig.MinigameSettings.fishingTime
    getgenv().OriginalApplyZoom = debug.getupvalue(MiniGameSystem.Start, 6)
    getgenv().OriginalRestoreCamera = debug.getupvalue(MiniGameSystem.SetCallbacks, 2)
    -- Backup kamera manual
    local cam = workspace.CurrentCamera
    getgenv().OriginalFOV = cam.FieldOfView
    getgenv().OriginalCamType = cam.CameraType
end

-- Backup probability default dari FishingConfig langsung
local DefaultProbabilities = {}
for _, fish in pairs(FishingConfig.FishTable) do
    DefaultProbabilities[fish.name] = fish.probability
end
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "LimitedEditionMenu"
screenGui.ResetOnSpawn = false

local padding, titleHeight, btnHeight, spacing, rows, cols = 4, 20, 20, 4, 4, 2
local menuWidth = 200
local titleCount = 3 -- jumlah judul (LIMITED, Nama Game, Username)
local menuHeight = padding*2 + titleCount*titleHeight + rows*btnHeight + rows*spacing

local menu = Instance.new("Frame", screenGui)
menu.Size = UDim2.new(0, menuWidth, 0, menuHeight)
menu.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
menu.BackgroundColor3 = Color3.fromRGB(0,0,0)
menu.BackgroundTransparency = 0.3
menu.Active = true
menu.Draggable = true

local pad = Instance.new("UIPadding", menu)
pad.PaddingTop = UDim.new(0, padding)
pad.PaddingBottom = UDim.new(0, padding)
pad.PaddingLeft = UDim.new(0, padding)
pad.PaddingRight = UDim.new(0, padding)

-- Judul 1 : LIMITED EDITION
local title1 = Instance.new("TextLabel", menu)
title1.Size = UDim2.new(1, 0, 0, titleHeight)
title1.Position = UDim2.new(0,0,0,0)
title1.Text = "LIMITED EDITION"
title1.TextSize = 10
title1.BackgroundColor3 = Color3.fromRGB(0,80,0)
title1.TextColor3 = Color3.fromRGB(255,255,255)

-- Judul 2 : Nama Game
local title2 = Instance.new("TextLabel", menu)
title2.Size = UDim2.new(1, 0, 0, titleHeight)
title2.Position = UDim2.new(0,0,0,titleHeight)
title2.Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
title2.TextSize = 8
title2.BackgroundColor3 = Color3.fromRGB(0,60,0)
title2.TextColor3 = Color3.fromRGB(255,255,255)

-- Judul 3 : Username saja
local title3 = Instance.new("TextLabel", menu)
title3.Size = UDim2.new(1, 0, 0, titleHeight)
title3.Position = UDim2.new(0,0,0,titleHeight*2)
title3.Text = player.Name
title3.TextSize = 8
title3.BackgroundColor3 = Color3.fromRGB(0,40,0)
title3.TextColor3 = Color3.fromRGB(255,255,255)

local function createButton(name, xIndex, yIndex)
    local innerWidth = menuWidth - padding*2
    local btnWidth = (innerWidth - spacing) / cols
    local btn = Instance.new("TextButton", menu)
    btn.Size = UDim2.new(0, btnWidth, 0, btnHeight)
    local posX = (xIndex-1) * (btnWidth + spacing)
local posY = titleCount * titleHeight + spacing + (yIndex-1) * (btnHeight + spacing)
btn.Position = UDim2.new(0, posX, 0, posY)
    btn.Text = name
    btn.TextSize = 8
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    return btn
end

local btn1 = createButton("Secret ON",1,1)
local btn2 = createButton("Secret OFF",2,1)
local btn3 = createButton("Special Menu",1,2)
local btn4 = createButton("Special OFF",2,2)
local btn5 = createButton("FastRod ON",1,3)
local btn6 = createButton("FastRod OFF",2,3)
local btnMinimal = createButton("Minimal",1,4)
local btnClose = createButton("Close",2,4)

-- override warna background jadi hitam, teks tetap putih (default)
btnMinimal.BackgroundColor3 = Color3.fromRGB(0,0,0)
btnClose.BackgroundColor3   = Color3.fromRGB(0,0,0)


local icon = Instance.new("TextButton", screenGui)
icon.Size = UDim2.new(0,30,0,30)
icon.Position = UDim2.new(0,50,0,50)
icon.Text = "🇵🇸"
icon.TextSize = 14
icon.BackgroundColor3 = Color3.fromRGB(0,80,0)
icon.TextColor3 = Color3.fromRGB(255,255,255)
icon.Active = true
icon.Draggable = true

btnMinimal.MouseButton1Click:Connect(function() menu.Visible = false end)
btnClose.MouseButton1Click:Connect(function() screenGui:Destroy() end)
icon.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)

local function setOn(btn) btn.BackgroundColor3 = Color3.fromRGB(0,200,0) end
local function setOff(btn) btn.BackgroundColor3 = Color3.fromRGB(170,0,0) end

-- FRAME SUBMENU UNTUK PILIHAN IKAN
local fishMenu = Instance.new("Frame", menu) -- parent langsung ke menu
fishMenu.Size = UDim2.new(0,150,0,220)
fishMenu.Position = UDim2.new(1, 10, 0, 0) -- selalu di kanan menu utama
fishMenu.BackgroundColor3 = Color3.fromRGB(40,40,40)
fishMenu.Visible = false
fishMenu.Active = true
fishMenu.Draggable = true

-- judul di atas submenu
local fishTitle = Instance.new("TextLabel", fishMenu)
fishTitle.Size = UDim2.new(1,0,0,20)
fishTitle.Text = "Pilih Salah Satu SECRET"
fishTitle.TextSize = 8
fishTitle.BackgroundColor3 = Color3.fromRGB(0,0,0)
fishTitle.TextColor3 = Color3.fromRGB(255,255,255)

-- tombol Hide List
local hideBtn = Instance.new("TextButton", fishMenu)
hideBtn.Size = UDim2.new(1,0,0,20)
hideBtn.Position = UDim2.new(0,0,0,20) -- tepat di bawah judul
hideBtn.Text = "CANCEL"
hideBtn.TextSize = 8
hideBtn.BackgroundColor3 = Color3.fromRGB(100,50,50)
hideBtn.TextColor3 = Color3.fromRGB(255,255,255)

hideBtn.MouseButton1Click:Connect(function()
    fishMenu.Visible = false
end)

-- scrolling area untuk daftar ikan
local scroll = Instance.new("ScrollingFrame", fishMenu)
scroll.Size = UDim2.new(1,0,1,-40) -- sisakan ruang untuk judul + tombol hide
scroll.Position = UDim2.new(0,0,0,40)
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,2)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- daftar nama ikan secret (sinkron dengan FishingConfig.FishTable)
local targetNames = {
    "Leviathan Core","Joar Cusyu","While Bloodmon","While BloodShack",
    "Nagasa Putra","Cype Darcogreen","Cype Darcopink","Cype Darcoyellow",
    "Doplin Pink","Doplin Blue",
    "Whale Shark","Paus Corda","King Monster","Hammer Shark","Jellyfish core",
    "Voyage","Amber","Megalodon Core","Ciyup Carber","Cindera Fish","Kuzjuy Shark",
    "Moster Kelelawar","Suytu Care"
}

-- alias untuk tampil di tombol list
local FishAliases = {
    ["Leviathan Core"]   = "Leviathan",
    ["Joar Cusyu"]       = "Joar Cusyu",
    ["While Bloodmon"]   = "Bloodmon",
    ["While BloodShack"] = "BloodShack",
    ["Nagasa Putra"]     = "Nagasa",
    ["Cype Darcogreen"]  = "Darcogreen",
    ["Cype Darcopink"]   = "Darcopink",
    ["Cype Darcoyellow"] = "Darcoyellow",
    ["Doplin Pink"]      = "Doplin Pink",
    ["Doplin Blue"]      = "Doplin Blue",
    ["Whale Shark"]      = "Whale Shark",
    ["Paus Corda"]       = "Paus Corda",
    ["King Monster"]     = "King Monster",
    ["Hammer Shark"]     = "Hammer Shark",
    ["Jellyfish core"]   = "Jellyfish Core",
    ["Voyage"]           = "Voyage",
    ["Amber"]            = "Amber",
    ["Megalodon Core"]   = "Megalodon Core",
    ["Ciyup Carber"]     = "Ciyup Carber",
    ["Cindera Fish"]     = "Cindera Fish",
    ["Kuzjuy Shark"]     = "Kuzjuy Shark",
    ["Moster Kelelawar"] = "Moster Kelelawar",
    ["Suytu Care"]       = "Suytu Care"
}

-- Special Menu (pilih ikan)
local selectedFish = nil
local function chooseFish(fishName)
    selectedFish = fishName
    btn3.Text = FishAliases[fishName] or fishName

    -- reset semua probability ke default
    for _, fish in pairs(FishingConfig.FishTable) do
        if DefaultProbabilities[fish.name] then
            fish.probability = DefaultProbabilities[fish.name]
        end
    end

    -- set probability ikan pilihan
    for _, fish in pairs(FishingConfig.FishTable) do
        if fish.name == fishName then
            fish.probability = 9999999
            if fish.rarity == "Secret" then
                FishingConfig.Pity.Secret.maxPity = 0.00002
                FishingConfig.Pity.Secret.baseBoost = 9000000.0
                FishingConfig.Pity.Secret.maxMultiplier = 9000000.0
                FishingConfig.RarityWeights.Secret = 9000000
            elseif fish.rarity == "Limited" then
                FishingConfig.Pity.Limited.maxPity = 0.00002
                FishingConfig.Pity.Limited.baseBoost = 9000000.5
                FishingConfig.Pity.Limited.maxMultiplier = 9000000.0
                FishingConfig.RarityWeights.Limited = 9000000
            end
        end
    end

    setOn(btn3)
    fishMenu.Visible = false
    forceReloadConfig()

    -- update FishingSystem state
    local env = getsenv(player.PlayerScripts:FindFirstChild("FishingSystem"))
    env.module_upvr_11 = FishingConfig
    local state = env.tbl_28_upvr
    state.casted = false
    state.fishingInProgress = false
    state.activeFishingTask = nil
    env.any_CreatePityTracker_result1_upvr = FishingConfig.CreatePityTracker()

    -- Override selectFish agar ikan pilihan selalu keluar
    env.selectFish_upvr = function(...)
        if selectedFish then
            return {name = selectedFish, rarity = "Secret", probability = 9999999}
        else
            return getgenv().OriginalSelectFish(...)
        end
    end
end

for i,name in ipairs(targetNames) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-10,0,20)
    btn.Position = UDim2.new(0,5,0,(i-1)*22)
    btn.Text = FishAliases[name] or name
    btn.TextSize = 8
    btn.BackgroundColor3 = Color3.fromRGB(0,80,0)
    btn.TextColor3 = Color3.fromRGB(255,255,255)

    btn.MouseButton1Click:Connect(function()
        chooseFish(name)
    end)
end

-- Secret ON
btn1.MouseButton1Click:Connect(function()
    setOn(btn1)

    -- ubah semua ikan Secret/Limited jadi probability tinggi
    for _, fish in pairs(FishingConfig.FishTable) do
        if fish.rarity == "Secret" or fish.rarity == "Limited" then
            fish.probability = 9999999
        end
    end

    -- ubah pengaturan pity & rarity weights
    FishingConfig.Pity.Secret.maxPity = 0.00002
    FishingConfig.Pity.Secret.baseBoost = 12000000.0
    FishingConfig.Pity.Secret.maxMultiplier = 5000000.0
    FishingConfig.Pity.Limited.maxPity = 0.00002
    FishingConfig.Pity.Limited.baseBoost = 120000000.5
    FishingConfig.Pity.Limited.maxMultiplier = 60000000.0
    FishingConfig.RarityWeights.Secret = 9000
    FishingConfig.RarityWeights.Limited = 9000

    -- reload config
    forceReloadConfig()

    -- update FishingSystem state
    local env = getsenv(player.PlayerScripts:FindFirstChild("FishingSystem"))
    env.module_upvr_11 = FishingConfig
    local state = env.tbl_28_upvr
    state.casted = false
    state.fishingInProgress = false
    state.activeFishingTask = nil
    env.any_CreatePityTracker_result1_upvr = FishingConfig.CreatePityTracker()

    -- paksa rarity selalu Secret
    env.module_upvr_11.GetRarityWithPity = function(...)
        return "Secret"
    end
end)

-- Secret OFF
btn2.MouseButton1Click:Connect(function()
    setOff(btn1)

    -- kembalikan probability ke default
    for _, fish in pairs(FishingConfig.FishTable) do
        if DefaultProbabilities[fish.name] then
            fish.probability = DefaultProbabilities[fish.name]
        end
    end

    -- restore pengaturan pity & rarity weights
    FishingConfig.Pity.Secret.maxPity = 2000
    FishingConfig.Pity.Secret.baseBoost = 0.3
    FishingConfig.Pity.Secret.maxMultiplier = 1.6
    FishingConfig.Pity.Limited.maxPity = 3000
    FishingConfig.Pity.Limited.baseBoost = 0.4
    FishingConfig.Pity.Limited.maxMultiplier = 1.9
    FishingConfig.RarityWeights.Secret = 0.2
    FishingConfig.RarityWeights.Limited = 0.001

    forceReloadConfig()

    -- update FishingSystem state
    local env = getsenv(player.PlayerScripts:FindFirstChild("FishingSystem"))
    env.module_upvr_11 = FishingConfig
    local state = env.tbl_28_upvr
    state.casted = false
    state.fishingInProgress = false
    state.activeFishingTask = nil
    env.any_CreatePityTracker_result1_upvr = FishingConfig.CreatePityTracker()
end)

-- Special Menu (open submenu)
btn3.MouseButton1Click:Connect(function()
    fishMenu.Position = UDim2.new(1, 10, 0, 0)
    fishMenu.Visible = true
end)
-- Special OFF
btn4.MouseButton1Click:Connect(function()
    setOff(btn3)

    -- restore pengaturan pity & rarity weights
    FishingConfig.Pity.Secret.maxPity = 2000
    FishingConfig.Pity.Secret.baseBoost = 0.3
    FishingConfig.Pity.Secret.maxMultiplier = 1.6
    FishingConfig.Pity.Limited.maxPity = 3000
    FishingConfig.Pity.Limited.baseBoost = 0.4
    FishingConfig.Pity.Limited.maxMultiplier = 1.9
    FishingConfig.RarityWeights.Secret = 0.2
    FishingConfig.RarityWeights.Limited = 0.001

    -- kembalikan probability ke default
    for _, fish in pairs(FishingConfig.FishTable) do
        if DefaultProbabilities[fish.name] then
            fish.probability = DefaultProbabilities[fish.name]
        end
    end

    btn3.Text = "Special Menu"
    selectedFish = nil
    forceReloadConfig()

    -- update FishingSystem state
    local env = getsenv(player.PlayerScripts:FindFirstChild("FishingSystem"))
    env.module_upvr_11 = FishingConfig
    local state = env.tbl_28_upvr
    state.casted = false
    state.fishingInProgress = false
    state.activeFishingTask = nil
    env.any_CreatePityTracker_result1_upvr = FishingConfig.CreatePityTracker()
end)

-- FAST FISHING ON
btn5.MouseButton1Click:Connect(function()
    setOn(btn5)

    -- Override jadi super cepat
    for rodName, _ in pairs(FishingConfig.MinigameSettings.rodTapCount) do
        FishingConfig.MinigameSettings.rodTapCount[rodName] = 1
    end
    FishingConfig.MinigameSettings.rodTapCount.default = 1
    -- FishingConfig.MinigameSettings.fishingTime = 25

    -- Matikan efek zoom kamera (applyZoom saja)
    debug.setupvalue(MiniGameSystem.Start, 6, function() end)

    -- Set kamera manual langsung
    local cam = workspace.CurrentCamera
    cam.FieldOfView = 70
    cam.CameraType = Enum.CameraType.Custom
end)

-- FAST FISHING OFF
btn6.MouseButton1Click:Connect(function()
    setOff(btn5)

    -- Restore tap count & fishing time
    if getgenv().OriginalTapCounts then
        for rodName, taps in pairs(getgenv().OriginalTapCounts) do
            FishingConfig.MinigameSettings.rodTapCount[rodName] = taps
        end
        FishingConfig.MinigameSettings.rodTapCount.default = getgenv().OriginalDefaultTap
        FishingConfig.MinigameSettings.fishingTime = getgenv().OriginalFishingTime
    end

    -- Restore fungsi kamera
    if getgenv().OriginalApplyZoom then
        debug.setupvalue(MiniGameSystem.Start, 6, getgenv().OriginalApplyZoom)
    end
    if getgenv().OriginalRestoreCamera then
        debug.setupvalue(MiniGameSystem.SetCallbacks, 2, getgenv().OriginalRestoreCamera)
    end

    -- Restore kamera manual
    local cam = workspace.CurrentCamera
    if getgenv().OriginalFOV then cam.FieldOfView = getgenv().OriginalFOV end
    if getgenv().OriginalCamType then cam.CameraType = getgenv().OriginalCamType
    end
end)

