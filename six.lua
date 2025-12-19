--====================================================
-- DELTA NPC FARM - VERSÃO ESTÁVEL
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- Limpeza
if guiParent:FindFirstChild("DeltaToggle") then guiParent.DeltaToggle:Destroy() end
if guiParent:FindFirstChild("DeltaMain") then guiParent.DeltaMain:Destroy() end

--====================================================
-- ESTADO
--====================================================
local STATE = {
    Farm = false,
    Attack = false,
    Target = nil,
    Cooldown = 0.4,
    LastAttack = 0
}

local Connections = {}

--====================================================
-- BOTÃO MENU (FLUTUANTE)
--====================================================
local toggleGui = Instance.new("ScreenGui", guiParent)
toggleGui.Name = "DeltaToggle"

local toggleBtn = Instance.new("TextButton", toggleGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 15, 0.5, -25)
toggleBtn.Text = "MENU"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
toggleBtn.TextColor3 = Color3.new(1,1,1)

--====================================================
-- GUI PRINCIPAL
--====================================================
local mainGui = Instance.new("ScreenGui", guiParent)
mainGui.Name = "DeltaMain"
mainGui.Enabled = false
mainGui.ResetOnSpawn = false

local frame = Instance.new("Frame", mainGui)
frame.Size = UDim2.new(0, 260, 0, 460)
frame.Position = UDim2.new(0.5, -130, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.Active = true
frame.Draggable = true

--====================================================
-- STATUS
--====================================================
local statusFrame = Instance.new("Frame", frame)
statusFrame.Size = UDim2.new(0.9, 0, 0, 55)
statusFrame.Position = UDim2.new(0.05, 0, 0.03, 0)
statusFrame.BackgroundColor3 = Color3.fromRGB(35,35,45)

local statusText = Instance.new("TextLabel", statusFrame)
statusText.Size = UDim2.new(1,0,1,0)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.new(1,1,1)
statusText.Text = "ALVO: nenhum"

--====================================================
-- FUNÇÃO CRIAR BOTÃO
--====================================================
local function createButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, y, 0)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120,40,40)
    b.ZIndex = 3
    return b
end

--====================================================
-- BOTÕES DE FUNÇÃO
--====================================================
local farmBtn = createButton("AUTO FARM: OFF", 0.17)
local atkBtn  = createButton("AUTO ATTACK: OFF", 0.25)

farmBtn.MouseButton1Click:Connect(function()
    STATE.Farm = not STATE.Farm
    farmBtn.Text = STATE.Farm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = STATE.Farm and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

atkBtn.MouseButton1Click:Connect(function()
    STATE.Attack = not STATE.Attack
    atkBtn.Text = STATE.Attack and "AUTO ATTACK: ON" or "AUTO ATTACK: OFF"
    atkBtn.BackgroundColor3 = STATE.Attack and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

--====================================================
-- LISTA DE NPCs
--====================================================
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(0.9, 0, 0, 170)
scroll.Position = UDim2.new(0.05, 0, 0.35, 0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency = 0.2
scroll.BackgroundColor3 = Color3.fromRGB(30,30,35)
scroll.ZIndex = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,4)

local function updateNPCList()
    for _,v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local count = 0

    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid")
        and obj.Parent:FindFirstChild("HumanoidRootPart")
        and obj.Parent ~= player.Character
        and not Players:GetPlayerFromCharacter(obj.Parent) then

            count += 1
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,0,0,30)
            btn.Text = obj.Parent.Name
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.TextColor3 = Color3.new(1,1,1)

            btn.MouseButton1Click:Connect(function()
                STATE.Target = obj.Parent
                statusText.Text = "ALVO: "..obj.Parent.Name
                statusFrame.BackgroundColor3 = Color3.fromRGB(0,100,0)
            end)
        end
    end

    scroll.CanvasSize = UDim2.new(0,0,0,count*34)
end

--====================================================
-- FECHAR TUDO
--====================================================
local closeBtn = createButton("FECHAR SCRIPT", 0.88)
closeBtn.BackgroundColor3 = Color3.fromRGB(100,30,30)

closeBtn.MouseButton1Click:Connect(function()
    for _,c in pairs(Connections) do
        if c then c:Disconnect() end
    end
    toggleGui:Destroy()
    mainGui:Destroy()
end)

--====================================================
-- TOGGLE MENU
--====================================================
toggleBtn.MouseButton1Click:Connect(function()
    mainGui.Enabled = not mainGui.Enabled
    if mainGui.Enabled then
        task.defer(updateNPCList)
    end
end)

--====================================================
-- LOOP PRINCIPAL
--====================================================
Connections.Main = RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if STATE.Farm and STATE.Target and STATE.Target:FindFirstChild("HumanoidRootPart") then
        root.CFrame = STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0,9,0)
    end

    if STATE.Attack and os.clock() - STATE.LastAttack >= STATE.Cooldown then
        local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = char
            tool:Activate()
            STATE.LastAttack = os.clock()
        end
    end
end)

-- Primeira carga
updateNPCList()
