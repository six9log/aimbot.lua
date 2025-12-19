local _v = game
local _s = {
    ["P"] = _v:GetService("Players"),
    ["R"] = _v:GetService("RunService")
}

local _p = _s.P.LocalPlayer
local _u = _p:WaitForChild("PlayerGui")

local _STATE = {
    A = false, -- Auto Attack
    F = false, -- Auto Farm (Ir até o boneco)
    T = nil,   -- Ferramenta
    Target = nil,
    Cooldown = 0.4,
    LastAtk = 0
}

-- 1. BOTÃO QUADRADO (ABRIR/FECHAR)
if _u:FindFirstChild("DeltaToggle") then _u.DeltaToggle:Destroy() end
local _tgui = Instance.new("ScreenGui", _u)
_tgui.Name = "DeltaToggle"

local _btnOpen = Instance.new("TextButton", _tgui)
_btnOpen.Size = UDim2.new(0, 50, 0, 50) -- O quadrado solicitado
_btnOpen.Position = UDim2.new(0, 10, 0.5, -25)
_btnOpen.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
_btnOpen.Text = "MENU"
_btnOpen.TextColor3 = Color3.new(1,1,1)

-- 2. MENU PRINCIPAL (INVISÍVEL POR PADRÃO)
local _gui = Instance.new("ScreenGui", _u)
_gui.Name = "DeltaAudit_V2"
_gui.Enabled = false

local _f = Instance.new("Frame", _gui)
_f.Size = UDim2.new(0, 220, 0, 200)
_f.Position = UDim2.new(0.5, -110, 0.4, 0)
_f.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
_f.Active = true
_f.Draggable = true

_btnOpen.MouseButton1Click:Connect(function()
    _gui.Enabled = not _gui.Enabled
end)

-- 3. FUNÇÕES INTERNAS
local function _findTool()
    local char = _p.Character
    _STATE.T = (char and char:FindFirstChildOfClass("Tool")) or _p.Backpack:FindFirstChildOfClass("Tool")
end

-- Botão Selecionar Alvo (Clique no NPC)
local _btnTarget = Instance.new("TextButton", _f)
_btnTarget.Size = UDim2.new(0.9, 0, 0, 40)
_btnTarget.Position = UDim2.new(0.05, 0, 0.1, 0)
_btnTarget.Text = "1. CLIQUE NO NPC"

_btnTarget.MouseButton1Click:Connect(function()
    _btnTarget.Text = "CLIQUE AGORA..."
    local conn; conn = _p:GetMouse().Button1Down:Connect(function()
        local t = _p:GetMouse().Target
        if t and t.Parent:FindFirstChild("Humanoid") then
            _STATE.Target = t.Parent
            _btnTarget.Text = "ALVO: " .. _STATE.Target.Name
            conn:Disconnect()
        end
    end)
end)

-- Botão Auto Farm (Ir até o boneco - 9 studs acima)
local _btnFarm = Instance.new("TextButton", _f)
_btnFarm.Size = UDim2.new(0.9, 0, 0, 40)
_btnFarm.Position = UDim2.new(0.05, 0, 0.35, 0)
_btnFarm.Text = "IR ATÉ BONECO: OFF"

_btnFarm.MouseButton1Click:Connect(function()
    _STATE.F = not _STATE.F
    _btnFarm.Text = _STATE.F and "FARM: ATIVO" or "FARM: OFF"
end)

-- Botão Auto Attack
local _btnAtk = Instance.new("TextButton", _f)
_btnAtk.Size = UDim2.new(0.9, 0, 0, 40)
_btnAtk.Position = UDim2.new(0.05, 0, 0.6, 0)
_btnAtk.Text = "AUTO ATTACK: OFF"

_btnAtk.MouseButton1Click:Connect(function()
    _STATE.A = not _STATE.A
    _btnAtk.Text = _STATE.A and "ATAQUE: ON" or "ATAQUE: OFF"
end)

-- 4. LOOP DE EXECUÇÃO
_s.R.Heartbeat:Connect(function()
    if _STATE.F and _STATE.Target and _STATE.Target:FindFirstChild("HumanoidRootPart") then
        -- POSICIONA 9 STUDS ACIMA (Como solicitado)
        _p.Character.HumanoidRootPart.CFrame = _STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
    end
    
    if _STATE.A then
        _findTool()
        if _STATE.T and os.clock() - _STATE.LastAtk >= _STATE.Cooldown then
            _STATE.T:Activate()
            _STATE.LastAtk = os.clock()
        end
    end
end)
