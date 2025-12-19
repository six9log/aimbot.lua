--====================================================
-- BLOX FRUITS | AUTO FARM POR LEVEL (ROBUSTO)
--====================================================

--====================
-- SERVIÇOS
--====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--====================
-- PLAYER
--====================
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end)

--====================
-- LEVEL
--====================
local levelValue = player:WaitForChild("Data"):WaitForChild("Level")

--====================
-- CONFIGURAÇÃO DE LEVEL FARM
-- (Exemplo – você pode expandir)
--====================
local LEVEL_FARM = {
    {min = 1,   max = 9,   mob = "Bandit"},
    {min = 10,  max = 14,  mob = "Monkey"},
    {min = 15,  max = 29,  mob = "Gorilla"},
    {min = 30,  max = 39,  mob = "Pirate"},
    {min = 40,  max = 59,  mob = "Brute"},
    {min = 60,  max = 74,  mob = "Desert Bandit"},
    {min = 75,  max = 89,  mob = "Desert Officer"},
    {min = 90,  max = 99,  mob = "Snow Bandit"},
    {min = 100, max = 119, mob = "Snowman"},
}

--====================
-- ESTADO
--====================
local STATE = {
    AutoFarm = false,
    AutoAttack = false,
    AutoLevel = false,
    Target = nil,
    Height = 9,
    AttackDelay = 0.25,
    LastAttack = 0
}

--====================
-- UI
--====================
if player.PlayerGui:FindFirstChild("BF_LevelFarm_UI") then
    player.PlayerGui.BF_LevelFarm_UI:Destroy()
end

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BF_LevelFarm_UI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 330, 0, 420)
main.Position = UDim2.new(0.02, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "BLOX FRUITS - LEVEL FARM"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(35,35,45)

local status = Instance.new("TextLabel", main)
status.Position = UDim2.new(0.05,0,0.12,0)
status.Size = UDim2.new(0.9,0,0,35)
status.Text = "ALVO: nenhum"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundColor3 = Color3.fromRGB(45,45,55)

local function button(text, y)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9,0,0,38)
    b.Position = UDim2.new(0.05,0,y,0)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(150,50,50)
    return b
end

local farmBtn  = button("AUTO FARM: OFF", 0.22)
local atkBtn   = button("AUTO ATTACK: OFF", 0.32)
local lvlBtn   = button("AUTO LEVEL FARM: OFF", 0.42)
local closeBtn = button("FECHAR SCRIPT", 0.9)
closeBtn.BackgroundColor3 = Color3.fromRGB(120,30,30)

--====================
-- FUNÇÕES
--====================
local function getMobForLevel(lv)
    for _,info in ipairs(LEVEL_FARM) do
        if lv >= info.min and lv <= info.max then
            return info.mob
        end
    end
end

local function getTargetByName(name)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    local closest, dist = nil, math.huge
    for _,mob in ipairs(enemies:GetChildren()) do
        if mob:IsA("Model")
        and mob.Name:find(name)
        and mob:FindFirstChild("Humanoid")
        and mob:FindFirstChild("HumanoidRootPart")
        and mob.Humanoid.Health > 0 then

            local d = (root.Position - mob.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = mob
            end
        end
    end
    return closest
end

--====================
-- BOTÕES
--====================
farmBtn.MouseButton1Click:Connect(function()
    STATE.AutoFarm = not STATE.AutoFarm
    farmBtn.Text = STATE.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = STATE.AutoFarm and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
end)

atkBtn.MouseButton1Click:Connect(function()
    STATE.AutoAttack = not STATE.AutoAttack
    atkBtn.Text = STATE.AutoAttack and "AUTO ATTACK: ON" or "AUTO ATTACK: OFF"
    atkBtn.BackgroundColor3 = STATE.AutoAttack and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
end)

lvlBtn.MouseButton1Click:Connect(function()
    STATE.AutoLevel = not STATE.AutoLevel
    lvlBtn.Text = STATE.AutoLevel and "AUTO LEVEL FARM: ON" or "AUTO LEVEL FARM: OFF"
    lvlBtn.BackgroundColor3 = STATE.AutoLevel and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--====================
-- LOOP PRINCIPAL
--====================
RunService.Heartbeat:Connect(function()
    if STATE.AutoLevel then
        local mobName = getMobForLevel(levelValue.Value)
        if mobName then
            STATE.Target = getTargetByName(mobName)
            if STATE.Target then
                status.Text = "FARM: "..mobName.." | LV "..levelValue.Value
            end
        end
    end

    if STATE.AutoFarm and STATE.Target and STATE.Target.Parent then
        local hrp = STATE.Target:FindFirstChild("HumanoidRootPart")
        local hum = STATE.Target:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            root.CFrame = root.CFrame:Lerp(hrp.CFrame * CFrame.new(0,9,0), 0.15)
        end
    end

    if STATE.AutoAttack and os.clock() - STATE.LastAttack >= STATE.AttackDelay then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            STATE.LastAttack = os.clock()
        end
    end
end)
