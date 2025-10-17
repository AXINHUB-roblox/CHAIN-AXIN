-- AXIN HUB X959 - CHAIN [ENRAGED] 自动格挡
local ChainAutoBlock = {
    Name = "AXIN HUB X959 - Auto Block",
    Version = "v1.0",
    Game = "CHAIN [ENRAGED]"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    BlockRange = 10,
    ReactionTime = 0.1,
    PerfectBlock = true,
    HumanLike = true
}

local State = {
    IsBlocking = false,
    LastBlock = 0,
    BlockCooldown = 0.5
}

print("=== AXIN HUB X959 自动格挡 ===")

-- 检测攻击威胁
function CheckAttackThreat()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local targetChar = player.Character
        if not targetChar then continue end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        
        if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
            continue
        end
        
        -- 距离检查
        local distance = (targetRoot.Position - rootPart.Position).Magnitude
        if distance > Config.BlockRange then continue end
        
        -- 面向检查
        local directionToPlayer = (rootPart.Position - targetRoot.Position).Unit
        local targetForward = targetRoot.CFrame.LookVector
        
        if directionToPlayer:Dot(targetForward) > 0.7 then
            -- 攻击检测
            if HasAttackIndicator(targetChar) then
                return true
            end
        end
    end
    
    return false
end

function HasAttackIndicator(character)
    -- 检测攻击动画/特效
    local indicators = {"Attack", "Swing", "Strike", "HitBox", "WeaponTrail"}
    
    for _, indicator in pairs(indicators) do
        for _, part in pairs(character:GetDescendants()) do
            if string.find(part.Name:lower(), indicator:lower()) then
                return true
            end
        end
    end
    
    return false
end

function ExecuteBlock()
    if State.IsBlocking then return end
    
    local currentTime = tick()
    if currentTime - State.LastBlock < State.BlockCooldown then return end
    
    State.IsBlocking = true
    print("🛡️ 自动格挡触发")
    
    -- 执行格挡
    if Config.HumanLike then
        -- 模拟按键
        SimulateKeyPress(Enum.KeyCode.Q, 0.3) -- 假设Q是格挡
    else
        -- 直接调用
        pcall(function()
            local combatEvent = ReplicatedStorage:FindFirstChild("BlockEvent")
            if combatEvent then
                combatEvent:FireServer(true)
                
                spawn(function()
                    wait(0.5)
                    combatEvent:FireServer(false)
                end)
            end
        end)
    end
    
    State.LastBlock = currentTime
    State.IsBlocking = false
end

-- 主循环
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end
    
    if CheckAttackThreat() then
        ExecuteBlock()
    end
end)

print("✅ 自动格挡系统就绪")
