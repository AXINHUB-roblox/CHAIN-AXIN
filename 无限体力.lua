-- AXIN HUB X959 - CHAIN [ENRAGED] 无限体力
local ChainInfiniteStamina = {
    Name = "AXIN HUB X959 - Infinite Stamina",
    Version = "v1.0",
    Game = "CHAIN [ENRAGED]"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    MaxStamina = 100,
    AutoDetect = true
}

local State = {
    StaminaObjects = {},
    LastUpdate = 0
}

print("=== AXIN HUB X959 无限体力 ===")

function FindStaminaSystems()
    local character = LocalPlayer.Character
    if not character then return end
    
    -- 查找体力相关属性
    local staminaNames = {
        "Stamina", "Energy", "Endurance", "StaminaValue",
        "PlayerStamina", "CombatStamina"
    }
    
    for _, name in pairs(staminaNames) do
        -- 在Humanoid中查找
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid[name] then
            State.StaminaObjects[#State.StaminaObjects + 1] = {
                Object = humanoid,
                Property = name,
                Type = "HumanoidProperty"
            }
            print("🎯 找到体力属性: " .. name)
        end
        
        -- 在角色中查找NumberValue
        local staminaValue = character:FindFirstChild(name)
        if staminaValue and staminaValue:IsA("NumberValue") then
            State.StaminaObjects[#State.StaminaObjects + 1] = {
                Object = staminaValue,
                Property = "Value",
                Type = "NumberValue"
            }
            print("🎯 找到体力值: " .. name)
        end
        
        -- 在Player中查找
        local playerStamina = LocalPlayer:FindFirstChild(name)
        if playerStamina and playerStamina:IsA("NumberValue") then
            State.StaminaObjects[#State.StaminaObjects + 1] = {
                Object = playerStamina,
                Property = "Value", 
                Type = "NumberValue"
            }
            print("🎯 找到玩家体力: " .. name)
        end
    end
    
    -- 在ReplicatedStorage中查找
    if Config.AutoDetect then
        ScanReplicatedStorage()
    end
end

function ScanReplicatedStorage()
    local staminaModules = {
        "StaminaSystem", "EnergyManager", "ResourceSystem",
        "PlayerStats", "CombatResources"
    }
    
    for _, moduleName in pairs(staminaModules) do
        local module = ReplicatedStorage:FindFirstChild(moduleName)
        if module and module:IsA("ModuleScript") then
            print("🔍 找到可能的相关模块: " .. moduleName)
        end
    end
end

function MaintainStamina()
    for _, staminaObj in pairs(State.StaminaObjects) do
        pcall(function()
            if staminaObj.Type == "HumanoidProperty" then
                staminaObj.Object[staminaObj.Property] = Config.MaxStamina
            elseif staminaObj.Type == "NumberValue" then
                staminaObj.Object.Value = Config.MaxStamina
            end
        end)
    end
end

-- 初始检测
FindStaminaSystems()

-- 角色变化监听
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    FindStaminaSystems()
end)

-- 主循环
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end
    if #State.StaminaObjects == 0 then return end
    
    MaintainStamina()
end)

print("✅ 无限体力系统就绪")
print("📊 找到 " .. #State.StaminaObjects .. " 个体力系统")
