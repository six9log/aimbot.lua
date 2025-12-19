--====================================================
-- AUTO FARM + AUTO ATTACK + NPC SELECTOR (EDUCACIONAL)
--====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

--========================
-- ESTADO
--========================
local STATE = {
    AutoFarm = false,
    AutoAttack = false,
    Target = nil,
    Height = 9,
    Cooldown = 0.35,
    LastHit = 0,
    MenuOpen = true,
    NPCListOpen = false
}

--========================
-- UI BASE
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "FarmUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 420)
frame.Position = UDim2.new(0.5, -130, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

--========================
-- TÍTULO / ALVO
--========================
local targetLabel = Instance.new("TextLabel", frame)
targetLabel.Size = UDim2.new(1, -10, 0, 40)
targetLabel.Position = UDim2.new(0, 5, 0, 5)
targetLabel.BackgroundColor3 = Color3.fromRGB(40,40,45)
targetLabel.TextColor3 = Color3.new(1,1,1)
targetLabel.Text = "ALVO: nenhum"
targetLabel.BorderSizePixel = 0

--========================
-- BOTÕES
--========================
local function makeButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -10, 0, 40)
    b.Position = UDim2.new(0, 5, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(120,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    return b
end

local farmBtn   = makeButton("AUTO FARM: OFF", 55)
local atkBtn    = makeButton("AUTO ATTACK: OFF", 100)
local npcBtn    = makeButton("NPCs ATACÁVEIS ▼", 145)

--========================
-- LISTA DE NPCs
--========================
local npcFrame = Instance.new("ScrollingFrame", frame)
npcFrame.Size = UDim2.new(1, -10, 0, 160)
npcFrame.Position = UDim2.new(0, 5, 0, 190)
npcFrame.CanvasSize = UDim2.new(0,0,0,0)
npcFrame.ScrollBarImageTransparency = 0.2
npcFrame.Visible = false
npcFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
npcFrame.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", npcFrame)
layout.Padding = UDim.new(0,5)

--========================
-- FECHAR SCRIPT (FIXADO)
--========================
local closeBtn = makeButton("FECHAR SCRIPT", 360)
closeBtn.BackgroundColor3 = Color3.fromRGB(120,30,30)

closeBtn.MouseButton1Click:Connect(function()
    STATE.AutoFarm = false
    STATE.AutoAttack = false
    gui:Destroy()
end)

--========================
-- NPC DETECTION
--========================
local function getNPCs()
    local list = {}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
        and obj ~= character
        and not Players:GetPlayerFromCharacter(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                table.insert(list, obj)
            end
        end
    end
    return list
end

local function refreshNPCs()
    npcFrame:ClearAllChildren()
    layout.Parent = npcFrame

    local npcs = getNPCs()
    for _,npc in ipairs(npcs) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -5, 0, 35)
        b.Text = npc.Name
        b.BackgroundColor3 = Color3.fromRGB(50,50,55)
        b.TextColor3 = Color3.new(1,1,1)
        b.BorderSizePixel = 0
        b.Parent = npcFrame

        b.MouseButton1Click:Connect(function()
            STATE.Target = npc
            targetLabel.Text = "ALVO: "..npc.Name
        end)
    end

    npcFrame.CanvasSize = UDim2.new(0,0,0,#npcs * 40)
end

--========================
-- BOTÕES FUNCIONAIS
--========================
farmBtn.MouseButton1Click:Connect(function()
    STATE.AutoFarm = not STATE.AutoFarm
    farmBtn.Text = STATE.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = STATE.AutoFarm and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

atkBtn.MouseButton1Click:Connect(function()
    STATE.AutoAttack = not STATE.AutoAttack
    atkBtn.Text = STATE.AutoAttack and "AUTO ATTACK: ON" or "AUTO ATTACK: OFF"
    atkBtn.BackgroundColor3 = STATE.AutoAttack and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

npcBtn.MouseButton1Click:Connect(function()
    STATE.NPCListOpen = not STATE.NPCListOpen
    npcFrame.Visible = STATE.NPCListOpen
    npcBtn.Text = STATE.NPCListOpen and "NPCs ATACÁVEIS ▲" or "NPCs ATACÁVEIS ▼"
    if STATE.NPCListOpen then
        refreshNPCs()
    end
end)

--========================
-- LOOP PRINCIPAL
--========================
RunService.Heartbeat:Connect(function()
    if not STATE.AutoFarm or not STATE.Target then return end
    if not STATE.Target:FindFirstChild("HumanoidRootPart") then return end

    local targetPos = STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0, STATE.Height, 0)
    root.CFrame = root.CFrame:Lerp(targetPos, 0.15)

    if STATE.AutoAttack then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and os.clock() - STATE.LastHit >= STATE.Cooldown then
            tool:Activate()
            STATE.LastHit = os.clock()
        end
    end
end)
