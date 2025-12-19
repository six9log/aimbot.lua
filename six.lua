--====================================================
-- BLOX FRUITS HUB - BASE FUNCIONAL
--====================================================

-----------------------------
-- SERVICES
-----------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-----------------------------
-- PLAYER
-----------------------------
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end)

-----------------------------
-- GLOBAL STATE
-----------------------------
local STATE = {
    Farm = {
        AutoLevel = false,
        AutoNearest = false,
        AutoChest = false,
        AutoAttack = false,
        Height = 9,
        Target = nil,
        Chest = nil
    }
}

-----------------------------
-- CLEAN UI
-----------------------------
if player.PlayerGui:FindFirstChild("BF_HUB") then
    player.PlayerGui.BF_HUB:Destroy()
end

-----------------------------
-- UI
-----------------------------
local GUI = Instance.new("ScreenGui", player.PlayerGui)
GUI.Name = "BF_HUB"
GUI.ResetOnSpawn = false

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 700, 0, 420)
Main.Position = UDim2.new(0.2, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)

-----------------------------
-- SIDEBAR
-----------------------------
local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 160, 1, 0)
Side.BackgroundColor3 = Color3.fromRGB(20,20,25)

local FarmTab = Instance.new("TextButton", Side)
FarmTab.Size = UDim2.new(1,0,0,40)
FarmTab.Text = "Farm"
FarmTab.BackgroundColor3 = Color3.fromRGB(40,40,55)

-----------------------------
-- CONTENT
-----------------------------
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,160,0,0)
Content.Size = UDim2.new(1,-160,1,0)
Content.BackgroundColor3 = Color3.fromRGB(30,30,35)

local FarmPage = Instance.new("Frame", Content)
FarmPage.Size = UDim2.new(1,0,1,0)
FarmPage.Visible = true
FarmPage.BackgroundTransparency = 1

-----------------------------
-- UI COMPONENTS
-----------------------------
local function createToggle(text, y)
    local b = Instance.new("TextButton", FarmPage)
    b.Size = UDim2.new(0.9,0,0,40)
    b.Position = UDim2.new(0.05,0,y,0)
    b.Text = text .. " : OFF"
    b.BackgroundColor3 = Color3.fromRGB(150,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    return b
end

local autoLevelBtn   = createToggle("Auto Farm Level", 0.10)
local autoNearestBtn = createToggle("Auto Farm Nearest", 0.22)
local autoChestBtn   = createToggle("Auto Farm Chest", 0.34)
local autoAttackBtn  = createToggle("Auto Attack", 0.46)

local function bindToggle(button, key)
    button.MouseButton1Click:Connect(function()
        STATE.Farm[key] = not STATE.Farm[key]
        button.Text = key .. " : " .. (STATE.Farm[key] and "ON" or "OFF")
        button.BackgroundColor3 = STATE.Farm[key]
            and Color3.fromRGB(50,150,50)
            or Color3.fromRGB(150,50,50)
    end)
end

bindToggle(autoLevelBtn, "AutoLevel")
bindToggle(autoNearestBtn, "AutoNearest")
bindToggle(autoChestBtn, "AutoChest")
bindToggle(autoAttackBtn, "AutoAttack")

-----------------------------
-- ENEMIES
-----------------------------
local function getEnemies()
    local list = {}
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return list end

    for _,m in ipairs(folder:GetChildren()) do
        if m:IsA("Model")
        and m:FindFirstChild("Humanoid")
        and m:FindFirstChild("HumanoidRootPart")
        and m.Humanoid.Health > 0 then
            table.insert(list, m)
        end
    end
    return list
end

local function getNearestEnemy()
    local best, dist = nil, math.huge
    for _,e in ipairs(getEnemies()) do
        local d = (root.Position - e.HumanoidRootPart.Position).Magnitude
        if d < dist then
            dist = d
            best = e
        end
    end
    return best
end

-----------------------------
-- CHESTS
-----------------------------
local function getChests()
    local list = {}

    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("chest") then
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(list, part)
            end
        end
    end

    return list
end

local function getNearestChest()
    local best, dist = nil, math.huge
    for _,c in ipairs(getChests()) do
        local d = (root.Position - c.Position).Magnitude
        if d < dist then
            dist = d
            best = c
        end
    end
    return best
end

-----------------------------
-- MOVE FUNCTION
-----------------------------
local function moveTo(cf)
    root.CFrame = root.CFrame:Lerp(cf, 0.18)
end

-----------------------------
-- MAIN LOOP
-----------------------------
RunService.Heartbeat:Connect(function()
    -- PRIORIDADE: CHEST
    if STATE.Farm.AutoChest then
        STATE.Farm.Chest = getNearestChest()
        if STATE.Farm.Chest then
            moveTo(STATE.Farm.Chest.CFrame * CFrame.new(0, 3, 0))
            return
        end
    end

    -- FARM INIMIGO
    if STATE.Farm.AutoNearest or STATE.Farm.AutoLevel then
        STATE.Farm.Target = getNearestEnemy()
    end

    if STATE.Farm.Target then
        moveTo(
            STATE.Farm.Target.HumanoidRootPart.CFrame *
            CFrame.new(0, STATE.Farm.Height, 0)
        )
    end

    -- ATAQUE
    if STATE.Farm.AutoAttack then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
end)
