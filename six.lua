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

-- Limpeza
if _u:FindFirstChild("DeltaToggle") then _u.DeltaToggle:Destroy() end
if _u:FindFirstChild("DeltaMain") then _u.DeltaMain:Destroy() end

-- Estado
local _STATE = {
    Atk = false,
    Farm = false,
    Target = nil,
    LastAtk = 0,
    Cooldown = 0.4
}

local _CONNECTIONS = {}

--====================================================
-- BOTÃO MENU (FLUTUANTE)
--====================================================
local _tgui = Instance.new("ScreenGui", _u)
_tgui.Name = "DeltaToggle"

local _btnToggle = Instance.new("TextButton", _tgui)
_btnToggle.Size = UDim2.new(0, 50, 0, 50)
_btnToggle.Position = UDim2.new(0, 15, 0.5, -25)
_btnToggle.Text = "MENU"
_btnToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
_btnToggle.TextColor3 = Color3.new(1,1,1)

--====================================================
-- INTERFACE PRINCIPAL
--====================================================
local _mgui = Instance.new("ScreenGui", _u)
_mgui.Name = "DeltaMain"
_mgui.Enabled = false
_mgui.ResetOnSpawn = false

local _f = Instance.new("Frame", _mgui)
_f.Size = UDim2.new(0, 240, 0, 480)
_f.Position = UDim2.new(0.5, -120, 0.35, 0)
_f.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
_f.Active = true
_f.Draggable = true

--====================================================
-- STATUS
--====================================================
local _stFrame = Instance.new("Frame", _f)
_stFrame.Size = UDim2.new(0.9, 0, 0, 60)
_stFrame.Position = UDim2.new(0.05, 0, 0.03, 0)
_stFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)

local _stText = Instance.new("TextLabel", _stFrame)
_stText.Size = UDim2.new(1, 0, 1, 0)
_stText.BackgroundTransparency = 1
_stText.TextColor3 = Color3.new(1,1,1)
_stText.Text = "ALVO: nenhum"

--====================================================
-- BOTÕES FARM / ATTACK
--====================================================
local function createButton(text, y)
    local b = Instance.new("TextButton", _f)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, y, 0)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local _btnFarm = createButton("AUTO FARM: OFF", 0.18)
local _btnAtk  = createButton("AUTO ATTACK: OFF", 0.26)

_btnFarm.MouseButton1Click:Connect(function()
    _STATE.Farm = not _STATE.Farm
    _btnFarm.Text = _STATE.Farm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    _btnFarm.BackgroundColor3 = _STATE.Farm and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

_btnAtk.MouseButton1Click:Connect(function()
    _STATE.Atk = not _STATE.Atk
    _btnAtk.Text = _STATE.Atk and "AUTO ATTACK: ON" or "AUTO ATTACK: OFF"
    _btnAtk.BackgroundColor3 = _STATE.Atk and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

--====================================================
-- LISTA DE NPCs
--====================================================
local _scroll = Instance.new("ScrollingFrame", _f)
_scroll.Size = UDim2.new(0.9, 0, 0, 200)
_scroll.Position = UDim2.new(0.05, 0, 0.35, 0)
_scroll.CanvasSize = UDim2.new(0,0,0,0)
_scroll.BackgroundColor3 = Color3.fromRGB(30,30,35)

local _layout = Instance.new("UIListLayout", _scroll)

local function _updateList()
    for _,v in pairs(_scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local count = 0

    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid")
        and obj.Parent:FindFirstChild("HumanoidRootPart")
        and obj.Parent ~= _p.Character
        and not _s.P:GetPlayerFromCharacter(obj.Parent) then

            count += 1
            local btn = Instance.new("TextButton", _scroll)
            btn.Size = UDim2.new(1,0,0,30)
            btn.Text = obj.Parent.Name
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)

            btn.MouseButton1Click:Connect(function()
                _STATE.Target = obj.Parent
                _stText.Text = "ALVO: " .. obj.Parent.Name
                _stFrame.BackgroundColor3 = Color3.fromRGB(0,100,0)
            end)
        end
    end

    _scroll.CanvasSize = UDim2.new(0,0,0,count*32)
end

--====================================================
-- FECHAR TUDO
--====================================================
local _btnClose = createButton("FECHAR SCRIPT", 0.88)
_btnClose.MouseButton1Click:Connect(function()
    for _,c in pairs(_CONNECTIONS) do
        if c then c:Disconnect() end
    end
    _tgui:Destroy()
    _mgui:Destroy()
end)

--====================================================
-- TOGGLE MENU
--====================================================
_btnToggle.MouseButton1Click:Connect(function()
    _mgui.Enabled = not _mgui.Enabled
    if _mgui.Enabled then task.defer(_updateList) end
end)

--====================================================
-- LOOP PRINCIPAL
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
            tool.Parent = char
            tool:Activate()
            _STATE.LastAtk = os.clock()
        end
    end
end)

_updateList()
