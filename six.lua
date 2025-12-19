--====================================================
-- BLOX FRUITS - AUTO FARM + AUTO ATTACK (ROBUSTO)
-- Criado para APRENDIZADO
--====================================================

--====================
-- SERVIÇOS
--====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
-- ESTADO GLOBAL
--====================
local STATE = {
    AutoFarm = false,
    AutoAttack = false,
    Target = nil,
    Height = 9,
    Cooldown = 0.25,
    LastAttack = 0,
    MenuOpen = true,
    NPCListOpen = false
}

--====================
-- LIMPAR UI ANTIGA
--====================
if player.PlayerGui:FindFirstChild("BF_Robust_UI") then
    player.PlayerGui.BF_Robust_UI:Destroy()
end

--====================
-- UI BASE
--====================
local gui = Instance.new("ScreenGui")
gui.Name = "BF_Robust_UI"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(0.02, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.BorderSizePixel = 0

--====================
-- TÍTULO
--====================
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "BLOX FRUITS FARM"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(35,35,45)
title.BorderSizePixel = 0

--====================
-- STATUS ALVO
--====================
local status = Instance.new("TextLabel", main)
status.Position = UDim2.new(0.05,0,0.12,0)
status.Size = UDim2.new(0.9,0,0,40)
status.Text = "ALVO: nenhum"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundColor3 = Color3.fromRGB(45,45,55)
status.BorderSizePixel = 0

--====================
-- BOTÃO AUTO FARM
--====================
local farmBtn = Instance.new("TextButton", main)
farmBtn.Position = UDim2.new(0.05,0,0.25,0)
farmBtn.Size = UDim2.new(0.9,0,0,40)
farmBtn.Text = "AUTO FARM: OFF"
farmBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)

farmBtn.MouseButton1Click:Connect(function()
    STATE.AutoFarm = not STATE.AutoFarm
    farmBtn.Text = STATE.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = STATE.AutoFarm and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
end)

--====================
-- BOTÃO AUTO ATTACK
--====================
local atkBtn = Instance.new("TextButton", main)
atkBtn.Position = UDim2.new(0.05,0,0.36,0)
atkBtn.Size = UDim2.new(0.9,0,0,40)
atkBtn.Text = "AUTO ATTACK: OFF"
atkBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)

atkBtn.MouseButton1Click:Connect(function()
    STATE.AutoAttack = not STATE.AutoAttack
    atkBtn.Text = STATE.AutoAttack and "AUTO ATTACK: ON" or "AUTO ATTACK: OFF"
    atkBtn.BackgroundColor3 = STATE.AutoAttack and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
end)

--====================
-- BOTÃO NPCs
--====================
local npcBtn = Instance.new("TextButton", main)
npcBtn.Position = UDim2.new(0.05,0,0.47,0)
npcBtn.Size = UDim2.new(0.9,0,0,40)
npcBtn.Text = "NPCs ATACÁVEIS ▼"
npcBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)

--====================
-- ABA NPCs
--====================
local npcFrame = Instance.new("Frame", main)
npcFrame.Position = UDim2.new(0.05,0,0.58,0)
npcFrame.Size = UDim2.new(0.9,0,0,200)
npcFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
npcFrame.Visible = false
npcFrame.BorderSizePixel = 0

local npcScroll = Instance.new("ScrollingFrame", npcFrame)
npcScroll.Size = UDim2.new(1,0,1,0)
npcScroll.CanvasSize = UDim2.new(0,0,0,0)
npcScroll.ScrollBarThickness = 6

--====================
-- DETECÇÃO DE NPCs (BLOX FRUITS)
--====================
local function getNPCs()
    local list = {}
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return list end

    for _,npc in ipairs(enemies:GetChildren()) do
        if npc:IsA("Model")
        and npc:FindFirstChild("Humanoid")
        and npc:FindFirstChild("HumanoidRootPart")
        and npc.Humanoid.Health > 0 then
            table.insert(list, npc)
        end
    end
    return list
end

--====================
-- ATUALIZAR LISTA
--====================
local function updateNPCList()
    for _,v in pairs(npcScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local npcs = getNPCs()
    local y = 0

    for _,npc in ipairs(npcs) do
        local btn = Instance.new("TextButton", npcScroll)
        btn.Size = UDim2.new(1,-5,0,30)
        btn.Position = UDim2.new(0,0,0,y)
        btn.Text = npc.Name
        btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
        btn.TextColor3 = Color3.new(1,1,1)

        btn.MouseButton1Click:Connect(function()
            STATE.Target = npc
            status.Text = "ALVO: "..npc.Name
            status.BackgroundColor3 = Color3.fromRGB(0,120,0)
        end)

        y += 32
    end

    npcScroll.CanvasSize = UDim2.new(0,0,0,y)
end

npcBtn.MouseButton1Click:Connect(function()
    STATE.NPCListOpen = not STATE.NPCListOpen
    npcFrame.Visible = STATE.NPCListOpen
    npcBtn.Text = STATE.NPCListOpen and "NPCs ATACÁVEIS ▲" or "NPCs ATACÁVEIS ▼"
    if STATE.NPCListOpen then
        updateNPCList()
    end
end)

--====================
-- BOTÃO FECHAR
--====================
local closeBtn = Instance.new("TextButton", main)
closeBtn.Position = UDim2.new(0.05,0,0.9,0)
closeBtn.Size = UDim2.new(0.9,0,0,35)
closeBtn.Text = "FECHAR SCRIPT"
closeBtn.BackgroundColor3 = Color3.fromRGB(120,30,30)

closeBtn.MouseButton1Click:Connect(function()
    STATE.AutoFarm = false
    STATE.AutoAttack = false
    gui:Destroy()
end)

--====================
-- LOOP PRINCIPAL
--====================
RunService.Heartbeat:Connect(function()
    if STATE.AutoFarm and STATE.Target and root then
        if STATE.Target.Parent == nil or STATE.Target.Humanoid.Health <= 0 then
            STATE.Target = nil
            status.Text = "ALVO: nenhum"
            status.BackgroundColor3 = Color3.fromRGB(45,45,55)
            return
        end

        local targetCF = STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0, STATE.Height, 0)
        root.CFrame = root.CFrame:Lerp(targetCF, 0.15)
    end

    if STATE.AutoAttack and os.clock() - STATE.LastAttack >= STATE.Cooldown then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            STATE.LastAttack = os.clock()
        end
    end
end)
