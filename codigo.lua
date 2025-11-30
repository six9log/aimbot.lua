-- LocalScript (Coloque em StarterPlayerScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local AIM_ASSIST_RADIUS = 30 -- Raio de busca por alvos (em studs)
local AIM_ASSIST_STRENGTH = 0.05 -- Força da "grudada" (valor entre 0 e 1, quanto maior, mais rápido gruda)
local AIM_PART_NAME = "Torso" -- Parte do corpo do alvo (pode ser "HumanoidRootPart" ou "UpperTorso" dependendo do rig)

local targetHumanoid = nil

local function findTarget()
    local character = Player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end

    local bestTarget = nil
    local shortestDistance = AIM_ASSIST_RADIUS

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= Player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
            local targetChar = targetPlayer.Character
            local targetPart = targetChar:FindFirstChild(AIM_PART_NAME) or targetChar:FindFirstChild("HumanoidRootPart")

            if targetPart then
                local distance = (character[AIM_PART_NAME].Position - targetPart.Position).Magnitude

                -- Checa se está dentro do raio e na frente da câmera (para evitar grudar em alvos atrás de você)
                local screenPoint = Camera:WorldToScreenPoint(targetPart.Position)
                local isInView = screenPoint.X > 0 and screenPoint.X < Camera.ViewportSize.X and screenPoint.Y > 0 and screenPoint.Y < Camera.ViewportSize.Y

                if distance < shortestDistance and isInView then
                    shortestDistance = distance
                    bestTarget = targetPart
                end
            end
        end
    end
    return bestTarget
end

-- Loop principal que aplica a assistência de mira
RunService.RenderStepped:Connect(function(deltaTime)
    -- Só funciona se o botão esquerdo do mouse (ou o de atirar/R2) estiver pressionado
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonR2) then
        targetHumanoid = findTarget()

        if targetHumanoid then
            -- Calcula a direção do alvo
            local targetDirection = (targetHumanoid.Position - Camera.CFrame.Position).Unit
            
            -- Interpola suavemente a câmera atual para a direção do alvo
            local currentDirection = Camera.CFrame.LookVector
            local newDirection = currentDirection:Lerp(targetDirection, AIM_ASSIST_STRENGTH)
            
            -- Aplica a nova CFrame (rotação) à câmera
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newDirection)
        end
    end
end)
