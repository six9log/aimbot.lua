--====================================================
-- BLOX FRUITS HUB - STABLE EDUCATIONAL EDITION
--====================================================

------------------------
-- SERVICES
------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

------------------------
-- PLAYER
------------------------
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end)

------------------------
-- CLEAN UI
------------------------
if player.PlayerGui:FindFirstChild("BF_HUB") then
    player.PlayerGui.BF_HUB:Destroy()
end

------------------------
-- STATE
------------------------
local STATE = {
    Running = true,
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

------------------------
-- UI
------------------------
local GUI = Instance.new("ScreenGui", player.PlayerGui)
GUI.Name = "BF_HUB"
GUI.ResetOnSpawn = false

-- Toggle Button
local ToggleUI = Instance.new("TextButton", GUI)
ToggleUI.Size = UDim2.new(0,50,0,50)
ToggleUI.Position = UDim2.new(0,20,0.5,-25)
ToggleUI.Text = "☰"
ToggleUI.TextSize = 22
ToggleUI.BackgroundColor3 = Color3.fromRGB(40,40,50)

-- Main Window
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0,420,0,350)
Main.Position = UDim2.new(0.3,0,0.25,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.Active = true
Main.Draggable = true

ToggleUI.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "Blox Fruits Hub"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(30,30,40)

------------------------
-- BUTTON FACTORY
------------------------
local function createToggle(text, y, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9,0,0,35)
    btn.Position = UDim2.new(0.05,0,y,0)
    btn.Text = text.." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(150,50,50)

    btn.MouseButton1Click:Connect(function()
        local state = callback()
        btn.Text = text.." : "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50,150,50)
            or Color3.fromRGB(150,50,50)
    end)
end

------------------------
-- TOGGLES
------------------------
createToggle("Auto Farm Level", 0.15, function()
    STATE.Farm.AutoLevel = not STATE.Farm.AutoLevel
    return STATE.Farm.AutoLevel
end)

createToggle("Auto Farm Nearest", 0.27, function()
    STATE.Farm.AutoNearest = not STATE.Farm.AutoNearest
    return STATE.Farm.AutoNearest
end)

createToggle("Auto Farm Chest", 0.39, function()
    STATE.Farm.AutoChest = not STATE.Farm.AutoChest
    STATE.Farm.Chest = nil
    return STATE.Farm.AutoChest
end)

createToggle("Auto Attack", 0.51, function()
    STATE.Farm.AutoAttack = not STATE.Farm.AutoAttack
    return STATE.Farm.AutoAttack
end)

------------------------
-- CLOSE BUTTON
------------------------
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0.9,0,0,35)
Close.Position = UDim2.new(0.05,0,0.75,0)
Close.Text = "ENCERRAR SCRIPT"
Close.BackgroundColor3 = Color3.fromRGB(120,30,30)

Close.MouseButton1Click:Connect(function()
    STATE.Running = false
    GUI:Destroy()
end)

------------------------
-- ENEMIES
------------------------
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

------------------------
-- CHESTS
------------------------
local function getNearestChest()
    local best, dist = nil, math.huge
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("chest") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist = d
                best = v
            end
        end
    end
    return best
end

------------------------
-- MOVE
------------------------
local function moveTo(cf)
    root.CFrame = root.CFrame:Lerp(cf, 0.18)
end

------------------------
-- MAIN LOOP
------------------------
RunService.Heartbeat:Connect(function()
    if not STATE.Running then return end

    -- CHEST PRIORITY
    if STATE.Farm.AutoChest then
        if not STATE.Farm.Chest or not STATE.Farm.Chest.Parent then
            STATE.Farm.Chest = getNearestChest()
        end

        if STATE.Farm.Chest then
            moveTo(STATE.Farm.Chest.CFrame * CFrame.new(0,3,0))
            return
        end
    end

    -- ENEMY FARM
    if STATE.Farm.AutoLevel or STATE.Farm.AutoNearest then
        if not STATE.Farm.Target
        or STATE.Farm.Target.Humanoid.Health <= 0 then
            STATE.Farm.Target = getNearestEnemy()
        end
    end

    if STATE.Farm.Target then
        moveTo(
            STATE.Farm.Target.HumanoidRootPart.CFrame *
            CFrame.new(0, STATE.Farm.Height, 0)
        )
    end

    -- ATTACK
    if STATE.Farm.AutoAttack then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)
