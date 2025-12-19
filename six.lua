--====================================================
-- SISTEMA CONSOLIDADO COM LISTA DE NPCS - DELTA 2025
--====================================================
local _v = game
local _s = {
    P = _v:GetService("Players"),
    R = _v:GetService("RunService")
}

local _p = _s.P.LocalPlayer
local _u = _p:WaitForChild("PlayerGui")

-- Limpeza de instâncias anteriores
if _u:FindFirstChild("DeltaToggle") then _u.DeltaToggle:Destroy() end
if _u:FindFirstChild("DeltaMain") then _u.DeltaMain:Destroy() end

local _STATE = {
    Atk = false,
    Farm = false,
    Target = nil,
    LastAtk = 0,
    Cooldown = 0.4
}

local _CONNECTIONS = {}

--====================================================
-- BOTÃO QUADRADO (TOGGLE)
--====================================================
local _tgui = Instance.new("ScreenGui")
_tgui.Name = "DeltaToggle"
_tgui.Parent = _u

local _btnToggle = Instance.new("TextButton")
_btnToggle.Parent = _tgui
_btnToggle.Size = UDim2.new(0, 50, 0, 50)
_btnToggle.Position = UDim2.new(0, 15, 0.5, -25)
_btnToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
_btnToggle.Text = "MENU"
_btnToggle.TextColor3 = Color3.new(1, 1, 1)

--====================================================
-- INTERFACE PRINCIPAL
--====================================================
local _mgui = Instance.new("ScreenGui")
_mgui.Name = "DeltaMain"
_mgui.Enabled = false
_mgui.ResetOnSpawn = false
_mgui.Parent = _u

local _f = Instance.new("Frame")
_f.Parent = _mgui -- FIX (garantia explícita)
_f.Size = UDim2.new(0, 240, 0, 420)
_f.Position = UDim2.new(0.5, -120, 0.4, 0)
_f.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
_f.Active = true
_f.Draggable = true

--====================================================
-- STATUS
--====================================================
local _stFrame = Instance.new("Frame")
_stFrame.Parent = _f -- FIX
_stFrame.Size = UDim2.new(0.9, 0, 0, 60)
_stFrame.Position = UDim2.new(0.05, 0, 0.03, 0)
_stFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)

local _stText = Instance.new("TextLabel")
_stText.Parent = _stFrame -- FIX
_stText.Size = UDim2.new(1, 0, 1, 0)
_stText.BackgroundTransparency = 1
_stText.TextColor3 = Color3.new(1, 1, 1)
_stText.TextSize = 14

local _lvl = _p:FindFirstChild("level")
    or _p:FindFirstChild("Level")
    or (_p:FindFirstChild("leaderstats") and _p.leaderstats:FindFirstChildOfClass("IntValue"))
    or {Value = "N/A"}

_stText.Text = "JOGADOR: " .. _p.Name .. "\nNÍVEL: " .. tostring(_lvl.Value)

--====================================================
-- LISTA DE NPCS (SCROLL)
--====================================================
local _scroll = Instance.new("ScrollingFrame")
_scroll.Parent = _f -- FIX
_scroll.Size = UDim2.new(0.9, 0, 0, 200)
_scroll.Position = UDim2.new(0.05, 0, 0.18, 0)
_scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
_scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

local _layout = Instance.new("UIListLayout")
_layout.Parent = _scroll -- FIX
_layout.SortOrder = Enum.SortOrder.LayoutOrder

--====================================================
-- FUNÇÃO DE LISTA (INALTERADA)
--====================================================
local function _updateList()
    for _, v in pairs(_scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local count = 0

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid")
        and obj.Parent:FindFirstChild("HumanoidRootPart")
        and obj.Parent ~= _p.Character
        and not _s.P:GetPlayerFromCharacter(obj.Parent) then

            count += 1

            local btn = Instance.new("TextButton")
            btn.Parent = _scroll -- FIX
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = obj.Parent.Name
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

            btn.MouseButton1Click:Connect(function()
                _STATE.Target = obj.Parent
                _stText.Text = "ALVO: " .. obj.Parent.Name
                _stFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            end)
        end
    end

    _scroll.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

--====================================================
-- TOGGLE MENU
--====================================================
_btnToggle.MouseButton1Click:Connect(function()
    _mgui.Enabled = not _mgui.Enabled
    if _mgui.Enabled then
        task.defer(_updateList) -- FIX (garante render)
    end
end)

--====================================================
-- LOOP (INALTERADO)
--====================================================
_CONNECTIONS["Loop"] = _s.R.Heartbeat:Connect(function()
    local char = _p.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if _STATE.Farm and _STATE.Target and _STATE.Target:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame =
            _STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
    end

    if _STATE.Atk and os.clock() - _STATE.LastAtk >= _STATE.Cooldown then
        local tool = char:FindFirstChildOfClass("Tool") or _p.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            if tool.Parent ~= char then tool.Parent = char end
            tool:Activate()
            _STATE.LastAtk = os.clock()
        end
    end
end)

-- PRIMEIRA CARGA
_updateList()
