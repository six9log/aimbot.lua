--====================================================
-- DELTA NPC FARM - MENU CONTROLADO
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- LIMPEZA
if guiParent:FindFirstChild("DeltaToggle") then guiParent.DeltaToggle:Destroy() end
if guiParent:FindFirstChild("DeltaMain") then guiParent.DeltaMain:Destroy() end

--====================================================
-- ESTADOS
--====================================================
local STATE = {
    Farm = false,
    Attack = false,
    Target = nil,
    Cooldown = 0.4,
    LastAttack = 0
}

local UI_STATE = {
    Open = false,
    NPCTab = false
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
frame.Size = UDim2.new(0, 260, 0, 480)
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
-- BOTÕES FARM / ATTACK
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
-- ABA NPCs ATACÁVEIS
--====================================================
local npcTabBtn = createButton("NPCs ATACÁVEIS ▶", 0.33)

local npcTab = Instance.new("Frame", frame)
npcTab.Size = UDim2.new(0.9, 0, 0, 170)
npcTab.Position = UDim2.new(0.05, 0, 0.40, 0)
npcTab.BackgroundColor3 = Color3.fromRGB(25,25,30)
npcTab.Visible = false
npcTab.ZIndex = 4

local npcScroll = Instance.new("ScrollingFrame", npcTab)
npcScroll.Size = UDim2.new(1, -10, 1, -10)
npcScroll.Position = UDim2.new(0, 5, 0, 5)
npcScroll.CanvasSize = UDim2.new(0,0,0,0)
npcScroll.ScrollBarImageTransparency = 0.2
npcScroll.BackgroundTransparency = 1

local npcLayout = Instance.new("UIListLayout", npcScroll)
npcLayout.Padding = UDim.new(0,4)

local function updateAttackableNPCs()
    for _,v in pairs(npcScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local count = 0

    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid")
        and obj.Health > 0
        and obj.Parent
        and obj.Parent:FindFirstChild("HumanoidRootPart")
        and obj.Parent ~= player.Character
        and not Players:GetPlayerFromCharacter(obj.Parent) then

            count += 1
            local btn = Instance.new("TextButton", npcScroll)
            btn.Size = UDim2.new(1,0,0,28)
            btn.Text = obj.Parent.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,45)

            btn.MouseButton1Click:Connect(function()
                STATE.Target = obj.Parent
                statusText.Text = "ALVO: "..obj.Parent.Name
                statusFrame.BackgroundColor3 = Color3.fromRGB(0,120,0)
            end)
        end
    end

    npcScroll.CanvasSize = UDim2.new(0,0,0,count*32)
end

npcTabBtn.MouseButton1Click:Connect(function()
    if not UI_STATE.Open then return end

    UI_STATE.NPCTab = not UI_STATE.NPCTab
    npcTab.Visible = UI_STATE.NPCTab
    npcTabBtn.Text = UI_STATE.NPCTab and "NPCs ATACÁVEIS ▼" or "NPCs ATACÁVEIS ▶"

    if UI_STATE.NPCTab then
        task.defer(updateAttackableNPCs)
    end
end)

--====================================================
-- FECHAR SCRIPT
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
-- MENU TOGGLE (CONTROLA TUDO)
--====================================================
toggleBtn.MouseButton1Click:Connect(function()
    UI_STATE.Open = not UI_STATE.Open
    mainGui.Enabled = UI_STATE.Open

    if not UI_STATE.Open then
        UI_STATE.NPCTab = false
        npcTab.Visible = false
        npcTabBtn.Text = "NPCs ATACÁVEIS ▶"
    else
        task.defer(updateAttackableNPCs)
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
