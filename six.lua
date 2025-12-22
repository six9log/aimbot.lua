--====================================================
-- BLOX FRUITS HUB - STABLE + FIXED ATTACK & KILL AURA
--====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- Evento de ataque oficial do Blox Fruits
local RigEvent = ReplicatedStorage:FindFirstChild("RigControllerEvent")

player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end)

if player.PlayerGui:FindFirstChild("BF_HUB") then
    player.PlayerGui.BF_HUB:Destroy()
end

local STATE = {
    Running = true,
    Farm = {
        AutoLevel = false,
        AutoNearest = false,
        AutoChest = false,
        AutoAttack = false,
        KillAura = false, -- NOVA OPÇÃO

        Height = 14,
        BackDistance = -10,
        AuraRange = 45, -- Alcance da Kill Aura

        Target = nil,
        Chest = nil,
        ChestStartTime = 0
    }
}

------------------------
-- UI (ESTILO ORIGINAL)
------------------------
local GUI = Instance.new("ScreenGui", player.PlayerGui)
GUI.Name = "BF_HUB"
GUI.ResetOnSpawn = false

local ToggleUI = Instance.new("TextButton", GUI)
ToggleUI.Size = UDim2.new(0,50,0,50)
ToggleUI.Position = UDim2.new(0,20,0.5,-25)
ToggleUI.Text = "☰"
ToggleUI.TextSize = 22
ToggleUI.BackgroundColor3 = Color3.fromRGB(40,40,50)

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0,420,0,420) -- Aumentado para caber o novo botão
Main.Position = UDim2.new(0.3,0,0.25,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.Active = true
Main.Draggable = true

ToggleUI.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local function createToggle(text, y, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9,0,0,35)
    btn.Position = UDim2.new(0.05,0,y,0)
    btn.Text = text.." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(150,50,50)

    btn.MouseButton1Click:Connect(function()
        local state = callback()
        btn.Text = text.." : "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
    end)
end

createToggle("Auto Farm Level", 0.12, function() STATE.Farm.AutoLevel = not STATE.Farm.AutoLevel return STATE.Farm.AutoLevel end)
createToggle("Auto Farm Nearest", 0.22, function() STATE.Farm.AutoNearest = not STATE.Farm.AutoNearest return STATE.Farm.AutoNearest end)
createToggle("Auto Farm Chest", 0.32, function() STATE.Farm.AutoChest = not STATE.Farm.AutoChest STATE.Farm.Chest = nil return STATE.Farm.AutoChest end)
createToggle("Auto Attack", 0.42, function() STATE.Farm.AutoAttack = not STATE.Farm.AutoAttack return STATE.Farm.AutoAttack end)
createToggle("KILL AURA (Dano Total)", 0.52, function() STATE.Farm.KillAura = not STATE.Farm.KillAura return STATE.Farm.KillAura end)

------------------------
-- FUNÇÕES AUXILIARES
------------------------

local function getEnemies()
    local list = {}
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return list end
    for _,m in ipairs(folder:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and m.Humanoid.Health > 0 then
            table.insert(list, m)
        end
    end
    return list
end

local function equipWeapon()
    if not character:FindFirstChildOfClass("Tool") then
        local tool = player.Backpack:FindFirstChildOfClass("Tool")
        if tool then character.Humanoid:EquipTool(tool) end
    end
end

------------------------
-- MAIN LOOP (CORRIGIDO)
------------------------
RunService.Heartbeat:Connect(function()
    if not STATE.Running then return end

    -- KILL AURA (Dano ao redor)
    if STATE.Farm.KillAura then
        for _, enemy in ipairs(getEnemies()) do
            local d = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
            if d <= STATE.Farm.AuraRange then
                equipWeapon()
                if RigEvent then RigEvent:FireServer("Attack") end
            end
        end
    end

    -- AUTO CHEST
    if STATE.Farm.AutoChest then
        if not STATE.Farm.Chest or not STATE.Farm.Chest.Parent then
            STATE.Farm.Chest = nil
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("chest") then
                    STATE.Farm.Chest = v
                    STATE.Farm.ChestStartTime = os.clock()
                    break
                end
            end
        end
        if STATE.Farm.Chest then
            root.CFrame = root.CFrame:Lerp(STATE.Farm.Chest.CFrame * CFrame.new(0, 3, 0), 0.18)
            return
        end
    end

    -- AUTO FARM NPC
    if STATE.Farm.AutoLevel or STATE.Farm.AutoNearest then
        if not STATE.Farm.Target or STATE.Farm.Target.Humanoid.Health <= 0 then
            local best, dist = nil, math.huge
            for _,e in ipairs(getEnemies()) do
                local d = (root.Position - e.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d best = e end
            end
            STATE.Farm.Target = best
        end

        if STATE.Farm.Target then
            root.CFrame = root.CFrame:Lerp(STATE.Farm.Target.HumanoidRootPart.CFrame * CFrame.new(0, STATE.Farm.Height, STATE.Farm.BackDistance), 0.18)
            
            -- ATAQUE FIXADO
            if STATE.Farm.AutoAttack then
                equipWeapon()
                if RigEvent then RigEvent:FireServer("Attack") end
                local t = character:FindFirstChildOfClass("Tool")
                if t then t:Activate() end
            end
        end
    end
end)
