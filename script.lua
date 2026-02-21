-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Remover GUI antiga, se houver
if CoreGui:FindFirstChild("Dimension23GUI") then
    CoreGui:FindFirstChild("Dimension23GUI"):Destroy()
end

-- Estado dos dois recursos
local ativadoCharacters = false
local backpackSafeZone = false

-- Função para pegar os 4 bools específicos
local function getBools()
    local pastaJogador = ReplicatedStorage:WaitForChild("Suit_Data")
        :WaitForChild("Be Yourself")
        :WaitForChild(player.Name)

    return {
        pastaJogador:WaitForChild("SecretSaturdays"),
        pastaJogador:WaitForChild("Haywire"),
        pastaJogador:WaitForChild("GeneratorRex"),
        pastaJogador:WaitForChild("FusionFall")
    }
end

-- Função para aplicar Unlock Characters
local function aplicarCharacters(valor)
    ativadoCharacters = valor
    for _, v in pairs(getBools()) do
        if v and v:IsA("BoolValue") then
            v.Value = valor
        end
    end
end

-- Função para ativar/desativar backpack na Safe Zone
local function aplicarBackpack(valor)
    backpackSafeZone = valor
    if valor then
        -- Ativar backpack na Safe Zone
        pcall(function()
            ReplicatedStorage.RemoteEvents.SafezoneCoreBackpack:FireServer(true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
            if player.PlayerGui:FindFirstChild("KillFreeZoneGUI") then
                player.PlayerGui.KillFreeZoneGUI.Enabled = true
            end
        end)
    else
        -- Desativar backpack na Safe Zone
        pcall(function()
            ReplicatedStorage.RemoteEvents.SafezoneCoreBackpack:FireServer(false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
            if player.PlayerGui:FindFirstChild("KillFreeZoneGUI") then
                player.PlayerGui.KillFreeZoneGUI.Enabled = false
            end
        end)
    end
end

-- Criar GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Dimension23GUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- TÍTULO: Dimension 23 GUI
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleLabel.Text = "Dimension 23 GUI"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.Parent = frame

local titleCorner = Instance.new("UICorner", titleLabel)
titleCorner.CornerRadius = UDim.new(0, 12)

-- Botão 1: Unlock All Characters
local button1 = Instance.new("TextButton")
button1.Size = UDim2.new(1, -20, 0, 60)
button1.Position = UDim2.new(0, 10, 0, 70)
button1.TextScaled = true
button1.TextColor3 = Color3.new(1,1,1)
button1.Font = Enum.Font.GothamBold
button1.Parent = frame
Instance.new("UICorner", button1)

local function atualizarBotao1()
    if ativadoCharacters then
        button1.Text = "Unlock All Character: ON"
        button1.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        button1.Text = "Unlock All Character: OFF"
        button1.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end

button1.MouseButton1Click:Connect(function()
    aplicarCharacters(not ativadoCharacters)
    atualizarBotao1()
end)

atualizarBotao1()

-- Botão 2: Enable Backpack in Safe Zone
local button2 = Instance.new("TextButton")
button2.Size = UDim2.new(1, -20, 0, 60)
button2.Position = UDim2.new(0, 10, 0, 150)
button2.TextScaled = true
button2.TextColor3 = Color3.new(1,1,1)
button2.Font = Enum.Font.GothamBold
button2.Parent = frame
Instance.new("UICorner", button2)

local function atualizarBotao2()
    if backpackSafeZone then
        button2.Text = "Enable Backpack in Safe Zone: ON"
        button2.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        button2.Text = "Enable Backpack in Safe Zone: OFF"
        button2.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end

button2.MouseButton1Click:Connect(function()
    aplicarBackpack(not backpackSafeZone)
    atualizarBotao2()
end)

atualizarBotao2()

-- Loop constante para manter funcionalidades ativas (A CADA 2 SEGUNDOS)
task.spawn(function()
    while task.wait(2) do
        -- Se Characters está ativado, mantém ativo
        if ativadoCharacters then
            pcall(function()
                for _, v in pairs(getBools()) do
                    if v and v:IsA("BoolValue") then
                        v.Value = true
                    end
                end
            end)
        end
        
        -- Se Backpack está ativado, FORÇA REATIVAR SEMPRE
        if backpackSafeZone then
            pcall(function()
                -- CHAMA O REMOTE EVENT NOVAMENTE
                ReplicatedStorage.RemoteEvents.SafezoneCoreBackpack:FireServer(true)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
                
                if player.PlayerGui:FindFirstChild("KillFreeZoneGUI") then
                    player.PlayerGui.KillFreeZoneGUI.Enabled = true
                end
            end)
        end
    end
end)

-- Reaplicar após morrer
player.CharacterAdded:Connect(function(character)
    -- Espera o personagem carregar completamente
    local humanoid = character:WaitForChild("Humanoid")
    task.wait(3)
    
    print("🔄 Respawn detectado, reaplicando configurações...")
    
    -- Força reaplicar Characters se estava ativo
    if ativadoCharacters then
        aplicarCharacters(true)
        print("✅ Characters reativado")
    end
    
    -- Força reaplicar Backpack se estava ativo
    if backpackSafeZone then
        task.wait(0.5)
        aplicarBackpack(true)
        print("✅ Backpack Safe Zone reativado")
    end
    
    -- Monitora morte para preparar próximo respawn
    humanoid.Died:Connect(function()
        print("💀 Morte detectada, preparando para reaplicar...")
    end)
end)

-- NOTIFICAÇÃO
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Made by Old Scripts";
    Text = "Script loaded";
    Icon = "rbxassetid://15794846967"; -- icone de virus so pra dar um pouco de susto kkkk
    Duration = 6;
    Button1 = "OK";
    Callback = callback;
})

-- Somzinho de carregado
task.spawn(function()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://3023237993"
    s.Volume = 0.4
    s.Parent = game:GetService("SoundService")
    s:Play()
    task.delay(3, function() s:Destroy() end)
end)

print("[loaded]")
