--====================================================
-- VERSÃO FINAL: LISTA DE NPCs + AUTO ATTACK (2025)
--====================================================
local _v = game
local _s = {
    ["P"] = _v:GetService("Players"),
    ["R"] = _v:GetService("RunService")
}

local _p = _s.P.LocalPlayer
local _u = _p:WaitForChild("PlayerGui")

math.randomseed(os.clock() * 1e6)

local _STATE = {
    A = false, -- isRunning
    B = 0.4,   -- Cooldown
    C = 0,     -- LastAttack
    T = nil,   -- Tool Cache
    Target = nil -- Alvo selecionado
}

local _CONNECTIONS = {}

-- 1. GERENCIADOR DE FERRAMENTA (Busca na Mochila e na Mão)
local function _findTool()
    local char = _p.Character
    local tool = (char and char:FindFirstChildOfClass("Tool")) or _p.Backpack:FindFirstChildOfClass("Tool")
    _STATE.T = tool
    return tool
end

-- 2. INTERFACE (Estrutura UI Robusta)
if _u:FindFirstChild("DeltaAudit_Final") then _u.DeltaAudit_Final:Destroy() end

local _g = Instance.new("ScreenGui")
_g.Name = "DeltaAudit_Final"
_g.ResetOnSpawn = false
_g.Parent = _u

local _f = Instance.new("Frame")
_f.Size = UDim2.new(0, 280, 0, 380)
_f.Position = UDim2.new(0.5, -140, 0.4, 0)
_f.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
_f.Active = true
_f.Draggable = true
_f.Parent = _g

local _title = Instance.new("TextLabel")
_title.Size = UDim2.new(1, 0, 0, 40)
_title.Text = "SISTEMA DE FARM 2025"
_title.TextColor3 = Color3.new(1, 1, 1)
_title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
_title.Parent = _f

-- Lista de NPCs (ScrollingFrame)
local _scroll = Instance.new("ScrollingFrame")
_scroll.Size = UDim2.new(0.9, 0, 0.5, 0)
_scroll.Position = UDim2.new(0.05, 0, 0.12, 0)
_scroll.CanvasSize = UDim2.new(0, 0, 5, 0)
_scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
_scroll.Parent = _f

local _layout = Instance.new("UIListLayout")
_layout.Parent = _scroll

-- Função para listar NPCs (Ignora Jogadores)
local function _updateList()
    for _, v in pairs(_scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent:FindFirstChild("HumanoidRootPart") then
            if not _s.P:GetPlayerFromCharacter(obj.Parent) and obj.Parent ~= _p.Character then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.Text = obj.Parent.Name
                btn.Parent = _scroll
                btn.MouseButton1Click:Connect(function()
                    _STATE.Target = obj.Parent
                    _title.Text = "ALVO: " .. obj.Parent.Name
                end)
            end
        end
    end
end

-- 3. BOTÕES DE AÇÃO
local _btnAtk = Instance.new("TextButton")
_btnAtk.Size = UDim2.new(0.9, 0, 0, 45)
_btnAtk.Position = UDim2.new(0.05, 0, 0.65, 0)
_btnAtk.Text = "INICIAR AUTO FARM"
_btnAtk.Parent = _f

_btnAtk.MouseButton1Click:Connect(function()
    _STATE.A = not _STATE.A
end)

local _btnRefresh = Instance.new("TextButton")
_btnRefresh.Size = UDim2.new(0.43, 0, 0, 35)
_btnRefresh.Position = UDim2.new(0.05, 0, 0.8, 0)
_btnRefresh.Text = "ATUALIZAR"
_btnRefresh.Parent = _f
_btnRefresh.MouseButton1Click:Connect(_updateList)

local _btnExit = Instance.new("TextButton")
_btnExit.Size = UDim2.new(0.43, 0, 0, 35)
_btnExit.Position = UDim2.new(0.52, 0, 0.8, 0)
_btnExit.Text = "FECHAR"
_btnExit.Parent = _f
_btnExit.MouseButton1Click:Connect(function() _STATE.A = false _g:Destroy() end)

-- 4. LOOP PRINCIPAL (Heartbeat)
_CONNECTIONS["Main"] = _s.R.Heartbeat:Connect(function()
    _findTool() -- Atualiza cache da ferramenta a cada ciclo

    if not _STATE.T then
        _btnAtk.Text = "SEM FERRAMENTA"
        _btnAtk.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    elseif not _STATE.A then
        _btnAtk.Text = "FARM: OFF"
        _btnAtk.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    else
        _btnAtk.Text = "FARM: ON (ATACANDO)"
        _btnAtk.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        -- Lógica de Movimentação e Ataque
        if _STATE.Target and _STATE.Target:FindFirstChild("HumanoidRootPart") then
            _p.Character.HumanoidRootPart.CFrame = _STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            
            if os.clock() - _STATE.C >= _STATE.B then
                _STATE.T:Activate()
                _STATE.C = os.clock()
            end
        end
    end
end)

_updateList()
