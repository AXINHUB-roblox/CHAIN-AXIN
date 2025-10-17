-- AXIN HUB X959 - CHAIN [ENRAGED] 自动躲避
local ChainAutoDodge = {
    Name = "AXIN HUB X959 - Auto Dodge",
    Version = "v1.0", 
    Game = "CHAIN [ENRAGED]"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    DodgeRange = 8,
    ReactionTime = 0.15,
    DodgeCooldown = 1.0,
    SmartDodging = true
}

local State = {
    LastDodge = 0,
    IsDodging = false
}

print("=== AXIN HUB X959 自动躲避 ===")

function CheckDanger()
    local character = LocalPlayer.Character
    if not character then return false, nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false, nil end
    
    local mostDangerous = nil
    local highestThreat = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local targetChar = player.Character
        if not targetChar then continue end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local humanoid = targetChar:FindFirstChild("Humanoid")
        
        if not targetRoot or not humanoid or humanoid.Health <= 0 then
            continue
        end
        
        local distance = (targetRoot.Position - rootPart.Position).Magnitude
        if distance > Config.DodgeRange then continue end
        
        -- 威胁计算
        local threat = CalculateThreat(targetChar, distance)
        
        if threat > highestThreat then
            highestThreat = threat
            mostDangerous = player
        end
    end
    
    return highestThreat > 0.7, mostDangerous
end

function CalculateThreat(targetChar, distance)
    local threat = 0
    
    -- 距离威胁
    threat = threat + (1 - (distance / Config.DodgeRange))
    
    -- 攻击动作威胁
    if HasAttackAnimation(targetChar) then
        threat = threat + 0.5
    end
    
    -- 特效威胁
    if HasDangerousEffect(targetChar) then
        threat = threat + 0.3
    end
    
    return threat
end

function HasAttackAnimation(targetChar)
    local humanoid = targetChar:FindFirstChild("Humanoid")
    if humanoid then
        local track = humanoid:GetPlayingAnimationTracks()
        for _, animTrack in pairs(track) do
            local animName = animTrack.Name:lower()
            if string.find(animName, "attack") or string.find(animName, "strike") then
                return true
            end
        end
    end
    return false
end

function HasDangerousEffect(targetChar)
    local dangerousEffects = {"Explosion", "AOE", "Area", "Blast", "Wave"}
    
    for _, effect in pairs(dangerousEffects) do
        for _, part in pairs(targetChar:GetDescendants()) do
            if string.find(part.Name:lower(), effect:lower()) then
                return true
            end
        end
    end
    return false
end

function ExecuteDodge(dangerSource)
    if State.IsDodging then return end
    
    local currentTime = tick()
    if currentTime - State.LastDodge < Config.DodgeCooldown then return end
    
    State.IsDodging = true
    print("🎯 自动躲避触发")
    
    local dodgeDirection = CalculateDodgeDirection(dangerSource)
    
    -- 执行躲避
    pcall(function()
        local dodgeEvent = ReplicatedStorage:FindFirstChild("DodgeEvent")
        if dodgeEvent then
            dodgeEvent:FireServer(dodgeDirection)
        else
            -- 模拟按键躲避
            SimulateDodgeKeys(dodgeDirection)
        end
    end)
    
    State.LastDodge = currentTime
    State.IsDodging = false
end

function CalculateDodgeDirection(dangerSource)
    if not dangerSource or not dangerSource.Character then
        return "Backward"
    end
    
    local character = LocalPlayer.Character
    local dangerRoot = dangerSource.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = character and character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot or not dangerRoot then
        return "Backward"
    end
    
    local dangerDir = (dangerRoot.Position - localRoot.Position).Unit
    local localRight = localRoot.CFrame.RightVector
    
    if math.abs(dangerDir:Dot(localRight)) > 0.5 then
        return dangerDir:Dot(localRight) > 0 and "Left" or "Right"
    else
        return "Backward"
    end
end

function SimulateDodgeKeys(direction)
    local key = Enum.KeyCode.Space -- 假设空格是躲避
    
    if direction == "Left" then
        key = Enum.KeyCode.A
    elseif direction == "Right" then
        key = Enum.KeyCode.D
    elseif direction == "Backward" then
        key = Enum.KeyCode.S
    end
    
    -- 这里需要根据游戏实际按键实现
    print("⌨️ 躲避方向: " .. direction)
end

-- 主循环
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end
    
    local inDanger, dangerSource = CheckDanger()
    if inDanger then
        ExecuteDodge(dangerSource)
    end
end)

print("✅ 自动躲避系统就绪")
