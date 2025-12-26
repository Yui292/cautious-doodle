-- ===================================================
-- 🎯 AUTO RESPAWN AT DEATH - rip_script843
-- Version: 3.0 | GitHub Hosted
-- Repository: yul292/cautious-doodle
-- ===================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- 🔧 CẤU HÌNH
local CONFIG = {
    PlayerName = "rip_script843",
    Enabled = true,
    Debug = true,
    RespawnDelay = 0.3,
    GodModeTime = 1.5,
    VoidHeight = -100
}

-- 📊 BIẾN
local player = Players.LocalPlayer
local character, humanoid, hrp
local deathCFrame = nil
local deathCount = 0
local isRespawning = false

-- 🎨 UI
local screenGui, statusLabel, counterLabel

-- 📝 LOG
local function log(msg)
    if CONFIG.Debug then
        print("[🔁] " .. msg)
    end
end

-- 🚨 KIỂM TRA PLAYER
if player.Name ~= CONFIG.PlayerName then
    warn("⚠️ Script chỉ dành cho: " .. CONFIG.PlayerName)
    return
end

print("\n╔════════════════════════════════════════╗")
print("║        🎯 AUTO RESPAWN SYSTEM         ║")
print("║        👤 " .. player.Name .. string.rep(" ", 19 - #player.Name) .. "║")
print("║        🌐 GitHub Hosted              ║")
print("╚════════════════════════════════════════╝\n")

-- 🎨 TẠO UI
local function createUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RespawnUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 100)
    frame.Position = UDim2.new(0.02, 0, 0.02, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 136)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(0, 255, 136)
    title.Text = "⚡ AUTO RESPAWN"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    -- Status
    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 35)
    statusLabel.Position = UDim2.new(0, 0, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
    statusLabel.Text = "🟢 HOẠT ĐỘNG"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.Parent = frame
    
    -- Counter
    counterLabel = Instance.new("TextLabel")
    counterLabel.Size = UDim2.new(1, 0, 0, 35)
    counterLabel.Position = UDim2.new(0, 0, 0, 65)
    counterLabel.BackgroundTransparency = 1
    counterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    counterLabel.Text = "💀 Deaths: 0"
    counterLabel.Font = Enum.Font.Gotham
    counterLabel.TextSize = 13
    counterLabel.Parent = frame
    
    -- RGB Effect
    spawn(function()
        while screenGui and screenGui.Parent do
            for i = 0, 1, 0.01 do
                if stroke then
                    stroke.Color = Color3.fromHSV(i, 1, 1)
                end
                task.wait(0.05)
            end
        end
    end)
    
    log("UI created")
    return frame
end

-- 🔄 CẬP NHẬT UI
local function updateUI()
    if statusLabel then
        statusLabel.Text = "🟢 HOẠT ĐỘNG"
    end
    if counterLabel then
        counterLabel.Text = "💀 Deaths: " .. deathCount
    end
end

-- 💀 LƯU VỊ TRÍ CHẾT
local function saveDeathPosition()
    if character and hrp then
        deathCFrame = hrp.CFrame
        log("Saved death position: " .. tostring(deathCFrame.Position))
        return true
    end
    return false
end

-- 🛡️ GOD MODE
local function enableGodMode()
    if not humanoid then return end
    
    local originalWalk = humanoid.WalkSpeed
    local originalJump = humanoid.JumpPower
    
    humanoid.WalkSpeed = 24
    humanoid.JumpPower = 55
    
    -- Hiệu ứng
    if hrp then
        local part = Instance.new("Part")
        part.Size = Vector3.new(4, 4, 4)
        part.CFrame = hrp.CFrame
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.6
        part.Color = Color3.fromRGB(0, 255, 136)
        part.Material = Enum.Material.Neon
        part.Parent = workspace
        
        local tween = TweenService:Create(part, TweenInfo.new(0.8), {
            Size = Vector3.new(12, 12, 12),
            Transparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            part:Destroy()
        end)
    end
    
    -- Tắt sau thời gian
    task.delay(CONFIG.GodModeTime, function()
        if humanoid then
            humanoid.WalkSpeed = originalWalk
            humanoid.JumpPower = originalJump
        end
        log("God mode ended")
    end)
    
    log("God mode activated for " .. CONFIG.GodModeTime .. "s")
end

-- 🔄 RESPAWN
local function respawnAtLocation()
    if isRespawning or not deathCFrame then return end
    
    isRespawning = true
    log("Respawning...")
    
    -- Chờ character mới
    repeat
        character = player.Character
        task.wait(0.1)
    until character
    
    -- Chờ humanoid
    repeat
        humanoid = character:FindFirstChildOfClass("Humanoid")
        task.wait(0.1)
    until humanoid
    
    -- Tìm HRP/Torso
    repeat
        hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        task.wait(0.1)
    until hrp
    
    -- Delay
    task.wait(CONFIG.RespawnDelay)
    
    -- TELEPORT
    hrp.CFrame = deathCFrame
    humanoid.Health = humanoid.MaxHealth
    
    -- God mode
    enableGodMode()
    
    -- Cập nhật
    deathCount = deathCount + 1
    updateUI()
    
    -- Âm thanh
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://18476374264"
    sound.Volume = 0.4
    sound.Parent = hrp
    sound:Play()
    task.delay(3, function() sound:Destroy() end)
    
    log("Respawn complete! Total deaths: " .. deathCount)
    isRespawning = false
end

-- 👻 XỬ LÝ CHẾT
local function setupDeathHandler()
    if not character then return end
    
    humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not hrp then return end
    
    -- Health Changed Event
    humanoid.HealthChanged:Connect(function(health)
        if not CONFIG.Enabled then return end
        
        if health <= 0 then
            log("💀 Phát hiện chết!")
            saveDeathPosition()
            
            -- Tự động respawn sau 0.5s
            task.delay(0.5, function()
                respawnAtLocation()
            end)
        end
    end)
    
    -- Died Event
    humanoid.Died:Connect(function()
        if not CONFIG.Enabled then return end
        
        log("💀 Kích hoạt từ Died event")
        saveDeathPosition()
        
        task.delay(0.5, function()
            respawnAtLocation()
        end)
    end)
    
    log("Death handler setup complete")
end

-- 🕳️ CHỐNG VOID
local function antiVoidSystem()
    while CONFIG.Enabled do
        task.wait(0.5)
        
        if character and hrp then
            -- Kiểm tra rơi xuống void
            if hrp.Position.Y < CONFIG.VoidHeight then
                log("⚠️ Phát hiện rơi xuống void!")
                
                if deathCFrame then
                    hrp.CFrame = deathCFrame
                    if humanoid then
                        humanoid.Health = humanoid.MaxHealth
                    end
                    log("Đã teleport khỏi void")
                end
            end
        end
    end
end

-- 🚀 KHỞI ĐỘNG HỆ THỐNG
local function initialize()
    -- Tạo UI
    createUI()
    
    -- Thiết lập character
    if player.Character then
        character = player.Character
        setupDeathHandler()
    end
    
    -- Theo dõi character mới
    player.CharacterAdded:Connect(function(char)
        character = char
        task.wait(0.5)  -- Chờ character load
        setupDeathHandler()
    end)
    
    -- Chạy hệ thống chống void
    spawn(antiVoidSystem)
    
    -- Hotkeys
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F9 then
            -- Lưu vị trí thủ công
            if hrp then
                deathCFrame = hrp.CFrame
                log("📌 Đã lưu vị trí thủ công (F9)")
            end
        elseif input.KeyCode == Enum.KeyCode.F10 then
            -- Toggle hệ thống
            CONFIG.Enabled = not CONFIG.Enabled
            if statusLabel then
                if CONFIG.Enabled then
                    statusLabel.Text = "🟢 HOẠT ĐỘNG"
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
                else
                    statusLabel.Text = "🔴 ĐÃ TẮT"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            end
            log("Hệ thống: " .. (CONFIG.Enabled and "BẬT" or "TẮT"))
        end
    end)
    
    updateUI()
    log("✅ Hệ thống đã sẵn sàng!")
end

-- ⏳ CHỜ VÀ BẮT ĐẦU
task.wait(2)  -- Chờ game load
initialize()

print("\n🔥 Script loaded from: GitHub Pages")
print("🌐 Repository: yul292/cautious-doodle")
print("🎮 Chơi game vui vẻ! - rip_script843")
