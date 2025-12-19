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

-- 1. BOTÃO QUADRADO (ABRIR/FECHAR) - Mantido, pois é o toggle principal
local _tgui = Instance.new("ScreenGui", _u)
_tgui.Name = "DeltaToggle"

local _btnToggle = Instance.new("TextButton", _tgui)
_btnToggle.Size = UDim2.new(0, 50, 0, 50)
_btnToggle.Position = UDim2.new(0, 15, 0.5, -25)
_btnToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
_btnToggle.Text = "MENU"
_btnToggle.TextColor3 = Color3.new(1, 1, 1)

-- 2. INTERFACE PRINCIPAL (AGORA COM LISTA ROLÁVEL)
local _mgui = Instance.new("ScreenGui", _u)
_mgui.Name = "DeltaMain"
_mgui.Enabled = false
_mgui.ResetOnSpawn = false

local _f = Instance.new("Frame", _mgui)
_f.Size = UDim2.new(0, 240, 0, 420) -- Tamanho ajustado para caber a lista
_f.Position = UDim2.new(0.5, -120, 0.4, 0)
_f.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
_f.Active = true
_f.Draggable = true

_btnToggle.MouseButton1Click:Connect(function()
    _mgui.Enabled = not _mgui.Enabled
    -- Atualiza a lista sempre que o menu é aberto
    if _mgui.Enabled then _updateList() end 
end)

-- 3. ABA DE STATUS (TOPO DA UI)
local _stFrame = Instance.new("Frame", _f)
_stFrame.Size = UDim2.new(0.9, 0, 0, 60)
_stFrame.Position = UDim2.new(0.05, 0, 0.03, 0) -- Ajuste de posição
_stFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)

local _stText = Instance.new("TextLabel", _stFrame)
_stText.Size = UDim2.new(1, 0, 1, 0)
_stText.BackgroundTransparency = 1
_stText.TextColor3 = Color3.new(1, 1, 1)
_stText.TextSize = 14
local _lvl = _p:FindFirstChild("level") or _p:FindFirstChild("Level") or _p:FindFirstChild("leaderstats") and _p.leaderstats:FindFirstChildOfClass("IntValue") or {Value = "N/A"}
_stText.Text = "JOGADOR: " .. _p.Name .. "\nNÍVEL: " .. tostring(_lvl.Value)

-- 4. LISTA DE NPCS ROLÁVEL (NO LUGAR DO CLIQUE)
local _scroll = Instance.new("ScrollingFrame", _f)
_scroll.Size = UDim2.new(0.9, 0, 0, 200) -- Altura fixa para a lista
_scroll.Position = UDim2.new(0.05, 0, 0.18, 0)
_scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
_scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

local _layout = Instance.new("UIListLayout", _scroll)
_layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Função para listar NPCs (Ignora Jogadores)
local function _updateList()
    for _, v in pairs(_scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent:FindFirstChild("HumanoidRootPart") and obj.Parent ~= _p.Character then
            if not _s.P:GetPlayerFromCharacter(obj.Parent) then -- Filtro final de jogador
                count = count + 1
                local btn = Instance.new("TextButton", _scroll)
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
    end
    _scroll.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

-- 5. BOTÕES DE AÇÃO (MOVIDOS PARA BAIXO DA LISTA)
local function createBtn(text, pos, color, callback)
    local b = Instance.new("TextButton", _f)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- Posições ajustadas para caber abaixo da lista de 200px
createBtn("2. IR ATÉ (9 STUDS): OFF", UDim2.new(0.05, 0, 0.72, 0), Color3.fromRGB(50, 50, 60), function(b)
    _STATE.Farm = not _STATE.Farm
    b.Text = _STATE.Farm and "IR ATÉ: ATIVO" or "2. IR ATÉ (9 STUDS): OFF"
    b.BackgroundColor3 = _STATE.Farm and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 60)
end)

createBtn("3. AUTO ATTACK: OFF", UDim2.new(0.05, 0, 0.82, 0), Color3.fromRGB(50, 50, 60), function(b)
    _STATE.Atk = not _STATE.Atk
    b.Text = _STATE.Atk and "ATAQUE: ATIVO" or "3. AUTO ATTACK: OFF"
    b.BackgroundColor3 = _STATE.Atk and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 60)
end)

createBtn("FECHAR E LIMPAR TUDO", UDim2.new(0.05, 0, 0.92, 0), Color3.fromRGB(120, 30, 30), function()
    _STATE.Atk = false
    _STATE.Farm = false
    for _, c in pairs(_CONNECTIONS) do if c then c:Disconnect() end end
    _tgui:Destroy()
    _mgui:Destroy()
end)

-- 6. LOOP DE EXECUÇÃO (MANTIDO)
_CONNECTIONS["Loop"] = _s.R.Heartbeat:Connect(function()
    local char = _p.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if _STATE.Farm and _STATE.Target and _STATE.Target:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = _STATE.Target.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
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

-- Inicializa a lista no primeiro carregamento
_updateList()
