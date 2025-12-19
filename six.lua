--====================================================
-- DELTA NPC FARM - VERSÃO MELHORADA
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- LIMPEZA
for _,n in pairs({"DeltaToggle","DeltaMain"}) do
    if guiParent:FindFirstChild(n) then
        guiParent[n]:Destroy()
    end
end

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
local currentHighlight

--====================================================
-- FUNÇÕES ÚTEIS
--====================================================
local function clearHighlight()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

local function highlightTarget(model)
    clearHighlight()
    if model then
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.OutlineColor = Color3.new(1,1,1)
        h.Adornee = model
        h.Parent = model
        currentHighlight = h
    end
end

local function getAttackableNPCs()
    local list = {}
    for _,obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model")
        and obj ~= player.Character
        and not Players:GetPlayerFromCharacter(obj) then

            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")

            if hum and root and hum.Health > 0 then
                table.insert(list, obj)
            end
        end
    end
    return list
end

local function getClosestNPC()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local root = char.HumanoidRootPart
    local closest, dist = nil, math.huge

    for _,npc in pairs(getAttackableNPCs()) do
        local d = (root.Position - npc.HumanoidRootPart.Position).Magnitude
        if d < dist then
            dist = d
            closest = npc
        end
    end
    return closest
end

--====================================================
-- GUI MENU
--====================================================
local toggleGui = Instance.new("ScreenGui", guiParent)
toggleGui.Name = "DeltaToggle"

local toggleBtn = Instance.new("TextButton", toggleGui)
toggleBtn.Size = UDim2.new(0,50,0,50)
toggleBtn.Position = UDim2.new(0,15,0.5,-25)
toggleBtn.Text = "MENU"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
toggleBtn.TextColor3 = Color3.new(1,1,1)

local mainGui = Instance.new("ScreenGui", guiParent)
mainGui.Name = "DeltaMain"
mainGui.Enabled = false

local frame = Instance.new("Frame", mainGui)
frame.Size = UDim2.new(0,260,0,480)
frame.Position = UDim2.new(0.5,-130,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.Active = true
frame.Draggable = true

--====================================================
-- STATUS
--====================================================
local statusFrame = Instance.new("Frame", frame)
statusFrame.Size = UDim2.new(0.9,0,0,55)
statusFrame.Position = UDim2.new(0.05,0,0.03,0)
statusFrame.BackgroundColor3 = Color3.fromRGB(35,35,45)

local statusText = Instance.new("TextLabel", statusFrame)
statusText.Size = UDim2.new(1,0,1,0)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.new(1,1,1)
statusText.Text = "ALVO: nenhum"

--====================================================
-- FUNÇÃO BOTÃO
--====================================================
local function createButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9,0,0,35)
    b.Position = UDim2.new(0.05,0,y,0)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(120,40,40)
    return b
end

local farmBtn = createButton("AUTO FARM: OFF", 0.17)
local atkBtn  = createButton("AUTO ATTACK: OFF", 0.25)
local npcBtn  = createButton("NPCs ATACÁVEIS ▶", 0.33)

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
-- ABA NPC
--====================================================
local npcTab = Instance.new("Frame", frame)
npcTab.Size = UDim2.new(0.9,0,0,170)
npcTab.Position = UDim2.new(0.05,0,0.40,0)
npcTab.BackgroundColor3 = Color3.fromRGB(25,25,30)
npcTab.Visible = false

local npcScroll = Instance.new("ScrollingFrame", npcTab)
npcScroll.Size = UDim2.new(1,-10,1,-10)
npcScroll.Position = UDim2.new(0,5,0,5)
npcScroll.CanvasSize = UDim2.new(0,0,0,0)
npcScroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", npcScroll)

local function updateNPCList()
    for _,v in pairs(npcScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local list = getAttackableNPCs()
    for _,npc in pairs(list) do
        local btn = Instance.new("TextButton", npcScroll)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Text = npc.Name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)

        btn.MouseButton1Click:Connect(function()
            STATE.Target = npc
            statusText.Text = "ALVO: "..npc.Name
            highlightTarget(npc)
        end)
    end

    npcScroll.CanvasSize = UDim2.new(0,0,0,#list*34)
end

npcBtn.MouseButton1Click:Connect(function()
    if not UI_STATE.Open then return end
    UI_STATE.NPCTab = not UI_STATE.NPCTab
    npcTab.Visible = UI_STATE.NPCTab
    npcBtn.Text = UI_STATE.NPCTab and "NPCs ATACÁVEIS ▼" or "NPCs ATACÁVEIS ▶"
    if UI_STATE.NPCTab then updateNPCList() end
end)

--====================================================
-- MENU TOGGLE
--====================================================
toggleBtn.MouseButton1Click:Connect(function()
    UI_STATE.Open = not UI_STATE.Open
    mainGui.Enabled = UI_STATE.Open
    if not UI_STATE.Open then
        UI_STATE.NPCTab = false
        npcTab.Visible = false
        npcBtn.Text = "NPCs ATACÁVEIS ▶"
    end
end)

--====================================================
-- LOOP PRINCIPAL
--====================================================
Connections.Main = RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    if STATE.Farm then
        if not STATE.Target then
            STATE.Target = getClosestNPC()
            if STATE.Target then
                statusText.Text = "ALVO: "..STATE.Target.Name
                highlightTarget(STATE.Target)
            end
        end

        if STATE.Target and STATE.Target:FindFirstChild("HumanoidRootPart") then
            root.CFrame = root.CFrame:Lerp(
                STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0,9,0),
                0.15
            )
        end
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
