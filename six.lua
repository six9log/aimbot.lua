--====================================================
-- BLOX FRUITS HUB - KILL AURA + REMOTE ATTACK
--====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- EVENTO DE ATAQUE DO BLOX FRUITS (RIG CONTROLLER)
local RigEvent = ReplicatedStorage:FindFirstChild("RigControllerEvent")

local STATE = {
    Running = true,
    Weapon = "Combat",
    Farm = {
        AutoLevel = false,
        KillAura = false, -- Aura de Dano
        AuraRange = 50,   -- Distância da Aura
        Height = 15,
        Distance = 0
    }
}

------------------------
-- UI
------------------------
local GUI = Instance.new("ScreenGui", player.PlayerGui)
GUI.Name = "BF_HUB_AURA"

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 250, 0, 220)
Main.Position = UDim2.new(0.4, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Active = true
Main.Draggable = true

local function createToggle(text, y, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = text .. " : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    
    btn.MouseButton1Click:Connect(function()
        local s = callback()
        btn.Text = text .. " : " .. (s and "ON" or "OFF")
        btn.BackgroundColor3 = s and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)
end

createToggle("Auto Farm (TP)", 20, function() STATE.Farm.AutoLevel = not STATE.Farm.AutoLevel return STATE.Farm.AutoLevel end)
createToggle("Kill Aura (Dano)", 70, function() STATE.Farm.KillAura = not STATE.Farm.KillAura return STATE.Farm.KillAura end)

------------------------
-- FUNÇÕES DE COMBATE
------------------------

-- Ataca via Remote (Bypassa o clique do mouse)
local function attackRemote()
    if RigEvent then
        -- O Blox Fruits espera o nome "Attack" para registrar o dano da arma na mão
        RigEvent:FireServer("Attack")
    end
end

-- Equipa arma automaticamente
local function equipWeapon()
    if not character:FindFirstChildOfClass("Tool") then
        local tool = player.Backpack:FindFirstChild(STATE.Weapon) or player.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            player.Character.Humanoid:EquipTool(tool)
        end
    end
end

-- Pega todos os inimigos no alcance para a Kill Aura
local function getEnemiesInRange()
    local targets = {}
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, v in pairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - v.HumanoidRootPart.Position).Magnitude
                if dist <= STATE.Farm.AuraRange then
                    table.insert(targets, v)
                end
            end
        end
    end
    return targets
end

------------------------
-- LOOP PRINCIPAL
------------------------
task.spawn(function()
    while STATE.Running do
        -- 1. Lógica de Movimentação (Auto Farm)
        if STATE.Farm.AutoLevel then
            local enemies = getEnemiesInRange()
            if #enemies > 0 then
                -- Vai para o primeiro inimigo encontrado
                root.CFrame = enemies[1].HumanoidRootPart.CFrame * CFrame.new(0, STATE.Farm.Height, STATE.Farm.Distance)
            end
        end

        -- 2. Lógica de Kill Aura (Dano em Área)
        if STATE.Farm.KillAura then
            equipWeapon()
            local targets = getEnemiesInRange()
            if #targets > 0 then
                attackRemote() -- Manda o sinal de ataque pro servidor
                
                -- Opcional: Ativa a ferramenta visualmente
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
        
        task.wait(0.1) -- Velocidade do ataque (0.1 = 10 hits por segundo)
    end
end)
