--====================================================
-- BLOX FRUITS HUB - VERSÃO ESTUDO (FIXED AUTO-ATTACK)
--====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager") -- Para simular cliques reais

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Atualiza referências quando o player morre
player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

------------------------
-- ESTADO E CONFIGURAÇÃO
------------------------
local STATE = {
    Running = true,
    Weapon = "Combat", -- Mude para o nome da sua arma (ex: "Ice Fruit", "Katana")
    Farm = {
        AutoLevel = false,
        AutoAttack = false,
        Height = 12,
        Distance = -8,
        Target = nil
    }
}

------------------------
-- UI SIMPLES
------------------------
local GUI = Instance.new("ScreenGui", player.PlayerGui)
GUI.Name = "BF_HUB_FIXED"

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 250, 0, 200)
Main.Position = UDim2.new(0.4, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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

createToggle("Auto Farm", 20, function() 
    STATE.Farm.AutoLevel = not STATE.Farm.AutoLevel 
    return STATE.Farm.AutoLevel 
end)

createToggle("Auto Attack", 70, function() 
    STATE.Farm.AutoAttack = not STATE.Farm.AutoAttack 
    return STATE.Farm.AutoAttack 
end)

------------------------
-- LÓGICA DE COMBATE
------------------------

-- Função para equipar a arma automaticamente
local function equipWeapon()
    if character:FindFirstChildOfClass("Tool") then return end -- Já está com arma na mão
    
    local tool = player.Backpack:FindFirstChild(STATE.Weapon) or player.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        humanoid:EquipTool(tool)
    end
end

-- Função para atacar (Simulando clique e enviando sinal ao servidor)
local function doAttack()
    -- 1. Tenta equipar
    equipWeapon()
    
    -- 2. Ativa a ferramenta (Lógica Local)
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        -- 3. Simula clique do mouse para o Anti-Cheat do jogo entender como input humano
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

-- Busca inimigo mais próximo
local function getEnemy()
    local target = nil
    local dist = 1000
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                target = v
            end
        end
    end
    return target
end

------------------------
-- LOOP PRINCIPAL
------------------------
task.spawn(function()
    while STATE.Running do
        if STATE.Farm.AutoLevel then
            STATE.Farm.Target = getEnemy()
            
            if STATE.Farm.Target then
                -- Movimentação suave
                root.CFrame = STATE.Farm.Target.HumanoidRootPart.CFrame * CFrame.new(0, STATE.Farm.Height, STATE.Farm.Distance)
                
                -- Ataque condicional
                if STATE.Farm.AutoAttack then
                    doAttack()
                end
            end
        end
        task.wait(0.1) -- Delay para não crashar e simular velocidade de clique humana
    end
end)
