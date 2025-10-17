-- AXIN HUB X959 - CHAIN [ENRAGED] 自动攻击
local ChainAutoAttack = {
    Name = "AXIN HUB X959 - Auto Attack", 
    Version = "v1.0",
    Game = "CHAIN [ENRAGED]"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    AttackRange = 12,
    AttackSpeed = 0.8,
    ComboEnabled = true,
    TargetPriority = "Closest"
}

local State = {
    CurrentTarget = nil,
    LastAttack = 0,
    ComboCount = 0
}

print("=== AXIN HUB X959 自动攻击 ===")

function FindBestTarget()
    local bestTarget = nil
    local closestDistance = Config.AttackRange
    local character = LocalPlayer.Character
    
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
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
        
        if distance < closestDistance then
            closestDistance = distance
            bestTarget = player
        end
    end
    
    return bestTarget
end

function ExecuteAttack()
    local currentTime = tick()
    if currentTime - State.LastAttack < Config.AttackSpeed then return end
    
    if Config.ComboEnabled then
        State.ComboCount = (State.ComboCount % 3) + 1
    end
    
    print("⚔️ 自动攻击 | 连击: " .. State.ComboCount)
    
    -- 执行攻击
    if Config.ComboEnabled then
        PerformComboAttack(State.ComboCount)
    else
        PerformBasicAttack()
    end
    
    State.LastAttack = currentTime
end

function PerformComboAttack(comboStep)
    if comboStep == 1 then
        SimulateMouseClick(0.1) -- 快速点击
    elseif comboStep == 2 then
        SimulateMouseClick(0.2) -- 中等点击
    else
        -- 连击终结
        SimulateMouseClick(0.3)
        wait(0.1)
        SimulateMouseClick(0.2)
    end
end

function PerformBasicAttack()
    SimulateMouseClick(0.15)
end

function SimulateMouseClick(duration)
    -- 鼠标点击模拟
    pcall(function()
        -- 尝试调用攻击函数
        local attackEvent = ReplicatedStorage:FindFirstChild("AttackEvent")
        if attackEvent then
            attackEvent:FireServer("BasicAttack")
        else
            -- 备用方法
            local character = LocalPlayer.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool:Activate()
                        break
                    end
                end
            end
        end
    end)
end

-- 主循环
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end
    
    State.CurrentTarget = FindBestTarget()
    
    if State.CurrentTarget then
        ExecuteAttack()
    else
        State.ComboCount = 0
    end
end)

print("✅ 自动攻击系统就绪")
