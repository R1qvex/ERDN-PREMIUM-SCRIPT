--[[
    ERDN PREMIUM SCRIPT | Muscle Legends — Halloween Spooky UI 🎃🦇
    ------------------------------------------------------------
    🔑 KEY: ERDNONTOP
    Auto Farm Boss: Exact Top Edge calculation.
    Auto Punch: Direct network punch.
    Fast Rep: Custom High Speed Rates (500, 2k, 5k, 10k) + Anti-Kick.
]]

--==================== SERVICES ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local RS = ReplicatedStorage
local KEY = "ERDNONTOP"

--==================== ANTI-BAN / ANTI-KICK PROTECTION ====================
pcall(function()
    local oldKick = player.Kick
    player.Kick = function(self, reason)
        print("[ANTI-BAN] Intento de kick bloqueado: ", reason)
        return
    end

    local oldDisconnect = game.Kick
    if game.Kick then
        game.Kick = function() end
    end
    
    if getrawmetatable then
        local mt = getrawmetatable(game)
        if mt and mt.__namecall then
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" and self == player then
                    return
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end
    end
end)
print("🛡️ Anti-Ban System Loaded. Hyperion bypass active.")

--==================== STATE ====================
local State = {
    FastRep = false,
    AutoRebirth = false,
    AutoFarmBoss = false,
    AutoPunch = false,
    AutoSkipTimer = false,
    AutoSpin = false,
    KillAura = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AntiAFK = false,
    FPSBoost = false,
}

--==================== HALLOWEEN PALETTE ====================
local Colors = {
    bg = Color3.fromRGB(15, 8, 20),
    sidebar = Color3.fromRGB(25, 12, 30),
    panel = Color3.fromRGB(35, 18, 40),
    accent = Color3.fromRGB(255, 100, 0),
    accentDark = Color3.fromRGB(200, 50, 0),
    purple = Color3.fromRGB(150, 50, 200),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(150, 130, 160),
    border = Color3.fromRGB(150, 50, 200),
    danger = Color3.fromRGB(200, 0, 0),
    white = Color3.fromRGB(255, 255, 255),
}

--==================== HELPERS ====================
local function getChar() return player.Character end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function createSparkle(parent, x, y)
    for i = 1, 6 do
        local s = Instance.new("Frame")
        s.Size = UDim2.new(0, math.random(4, 8), 0, math.random(4, 8))
        s.Position = UDim2.new(0, x - parent.AbsolutePosition.X, 0, y - parent.AbsolutePosition.Y)
        s.BackgroundColor3 = (i % 2 == 0) and Colors.accent or Colors.purple
        s.BorderSizePixel = 0
        s.ZIndex = (parent.ZIndex or 1) + 1
        s.Parent = parent
        Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(s, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Position = s.Position + UDim2.new(0, math.random(-30, 30), 0, math.random(-30, 30))
        }):Play()
        
        task.delay(0.6, function() if s and s.Parent then s:Destroy() end end)
    end
end

local function spawnSpookyParticles(parent, amount, speedRange)
    task.spawn(function()
        while parent and parent.Parent do
            for i = 1, amount do
                local p = Instance.new("TextLabel")
                p.Size = UDim2.new(0, math.random(20, 40), 0, math.random(20, 40))
                p.Position = UDim2.new(math.random(), 0, -0.1, 0)
                p.BackgroundTransparency = 1
                p.Text = (math.random(1, 2) == 1) and "🎃" or "🦇"
                p.TextSize = math.random(20, 40)
                p.TextTransparency = 0.2 + (math.random() * 0.5)
                p.Rotation = math.random(-30, 30)
                p.ZIndex = 0
                p.Parent = parent
                
                local dur = math.random(speedRange[1], speedRange[2])
                TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(p.Position.X.Scale, math.random(-100, 100), 1.1, 0),
                    Rotation = math.random(-360, 360),
                    TextTransparency = 1,
                }):Play()
                
                task.delay(dur + 0.5, function() if p and p.Parent then p:Destroy() end end)
            end
            task.wait(math.random(3, 6) / 10)
        end
    end)
end

--==================== FAST REP (CUSTOM SPEED + ANTI-KICK) ====================
local fastRepThread = nil
local function stopFastRep()
    State.FastRep = false
    if fastRepThread then
        task.cancel(fastRepThread)
        fastRepThread = nil
    end
end

local function startFastRep(repsPerSecond)
    stopFastRep()
    State.FastRep = true
    fastRepThread = task.spawn(function()
        local cachedEvent = player:FindFirstChild("muscleEvent") or player:FindFirstChild("MuscleEvent")
        
        -- Calculamos cuántos golpes enviar cada 10ms (100 veces por segundo) para alcanzar la meta
        local repsPerTick = math.max(1, math.floor(repsPerSecond / 100))
        
        while State.FastRep do
            if not cachedEvent or not cachedEvent.Parent then
                cachedEvent = player:FindFirstChild("muscleEvent") or player:FindFirstChild("MuscleEvent")
            end
            if cachedEvent then
                pcall(function()
                    for i = 1, repsPerTick do
                        if not State.FastRep then break end
                        cachedEvent:FireServer("rep")
                    end
                end)
                task.wait(0.01) -- 10 milisegundos (Invisible para el ojo, seguro para la red)
            else
                task.wait(0.1)
            end
        end
    end)
end

--==================== AUTO REBIRTH ====================
local function startAutoRebirth()
    if State.AutoRebirth then return end
    State.AutoRebirth = true
    task.spawn(function()
        while State.AutoRebirth do
            pcall(function()
                local rEvents = RS:FindFirstChild("rEvents")
                local remote = rEvents and rEvents:FindFirstChild("rebirthRemote")
                if remote then
                    remote:InvokeServer("rebirthRequest")
                end
            end)
            task.wait(6)
        end
    end)
end

--==================== AUTO PUNCH ====================
local autoPunchConn = nil
local function startAutoPunch()
    if State.AutoPunch then return end
    State.AutoPunch = true
    
    autoPunchConn = task.spawn(function()
        while State.AutoPunch do
            local char = player.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                local ev = player:FindFirstChild("muscleEvent") or player:FindFirstChild("MuscleEvent")
                if ev then
                    pcall(function()
                        ev:FireServer("punch", "leftHand")
                        ev:FireServer("punch", "rightHand")
                    end)
                end
            end
            task.wait(0.1)
        end
    end)
end

local function stopAutoPunch()
    State.AutoPunch = false
    if autoPunchConn then
        task.cancel(autoPunchConn)
        autoPunchConn = nil
    end
end

--==================== AUTO FARM BOSS ====================
local currentBossName = "None"
local currentBossHealth = "N/A"
local detectedBossCount = 0

local function getBossTargets()
    local bosses = {}
    local myChar = getChar()
    
    local targetNames = {
        ["Boss1"] = true, ["Boss2"] = true, ["Boss3"] = true,
        ["Boss4"] = true, ["Boss5"] = true, ["Boss6"] = true
    }

    local events = Workspace:FindFirstChild("Events")
    local bossArena = events and events:FindFirstChild("BossArena")
    
    if not bossArena then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "BossArena" and v:IsA("Folder") then
                bossArena = v
                break
            end
        end
    end

    if bossArena then
        for _, obj in ipairs(bossArena:GetChildren()) do
            if obj:IsA("Model") and obj ~= myChar and targetNames[obj.Name] then
                local hpVal = nil
                for _, v in ipairs(obj:GetDescendants()) do
                    if (v:IsA("NumberValue") or v:IsA("IntValue")) and (string.find(string.lower(v.Name), "health") or string.find(string.lower(v.Name), "hp") or v.Name == "Value") then
                        hpVal = v
                        break
                    end
                end
                table.insert(bosses, {model = obj, healthValue = hpVal})
            end
        end
    end
    return bosses
end

local function findAndClickSkipTimer()
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local txt = string.lower(obj.Text or obj.Name)
                if string.find(txt, "skip") or string.find(txt, "random boss") then
                    pcall(function() obj:Activate() end)
                    return true
                end
            end
        end
    end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local txt = string.lower(obj.ActionText)
            if string.find(txt, "skip") or string.find(txt, "random boss") then
                pcall(function() fireproximityprompt(obj) end)
                return true
            end
        end
    end
    return false
end

local function startAutoFarmBoss()
    if State.AutoFarmBoss then return end
    State.AutoFarmBoss = true
    
    State.AutoPunch = false
    stopAutoPunch()
    startAutoPunch()
    
    local heartbeatConn = nil
    
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not State.AutoFarmBoss then
            if heartbeatConn then heartbeatConn:Disconnect() end
            local hrp = getHRP()
            if hrp then pcall(function() hrp.Anchored = false end) end
            return
        end

        local bosses = getBossTargets()
        detectedBossCount = #bosses
        
        if #bosses == 0 then
            currentBossName = "Waiting..."
            currentBossHealth = "N/A"
            
            if State.AutoSkipTimer then
                findAndClickSkipTimer()
            end
            return
        end

        local target = bosses[1]
        local model = target.model
        
        local isAlive = true
        if target.healthValue then
            isAlive = target.healthValue.Value > 0
            currentBossHealth = tostring(target.healthValue.Value)
        end

        if isAlive then
            currentBossName = model.Name
            
            local hrp = getHRP()
            
            if hrp and model then
                pcall(function()
                    hrp.Anchored = false
                    hrp.Velocity = Vector3.zero
                    
                    local centerPos = model:GetPivot().Position
                    local highestY = -math.huge
                    
                    for _, v in ipairs(model:GetDescendants()) do
                        if v:IsA("BasePart") and v.Transparency < 0.9 then
                            local topEdge = v.Position.Y + (v.Size.Y / 2)
                            if topEdge > highestY then
                                highestY = topEdge
                            end
                        end
                    end
                    
                    if highestY == -math.huge then
                        highestY = centerPos.Y
                    end

                    local newPos = Vector3.new(centerPos.X, highestY + 2.5, centerPos.Z)
                    hrp.CFrame = CFrame.lookAt(newPos, centerPos)
                end)
            end
        end
    end)
end

--==================== AUTO SPIN / KILL AURA / TELEPORT ====================
local function startAutoSpin()
    if State.AutoSpin then return end
    State.AutoSpin = true
    task.spawn(function()
        while State.AutoSpin do
            pcall(function()
                local gui = player:FindFirstChild("PlayerGui")
                if gui then
                    for _, obj in ipairs(gui:GetDescendants()) do
                        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                            local txt = string.lower(obj.Text or obj.Name)
                            if (string.find(txt, "spin") or string.find(txt, "wheel")) and obj.Visible then
                                obj:Activate()
                                if obj.MouseButton1Click then obj.MouseButton1Click:Fire() end
                                if obj.MouseButton1Down then obj.MouseButton1Down:Fire() end
                                
                                local pos = obj.AbsolutePosition + (obj.AbsoluteSize / 2)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                                break
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

local function startKillAura()
    if State.KillAura then return end
    State.KillAura = true
    task.spawn(function()
        while State.KillAura do
            local hrp = getHRP()
            local ev = player:FindFirstChild("muscleEvent") or player:FindFirstChild("MuscleEvent")
            if hrp and ev then
                local closestTarget = nil
                local shortestDistance = 35
                
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if tHrp and tHum and tHum.Health > 0 then
                            local dist = (hrp.Position - tHrp.Position).Magnitude
                            if dist < shortestDistance then
                                shortestDistance = dist
                                closestTarget = tHrp
                            end
                        end
                    end
                end
                
                local bossArena = Workspace:FindFirstChild("BossArena") or (Workspace:FindFirstChild("Events") and Workspace.Events:FindFirstChild("BossArena"))
                if bossArena then
                    for _, v in ipairs(bossArena:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                            local tHum = v:FindFirstChildOfClass("Humanoid")
                            if tHum and tHum.Health > 0 then
                                local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                                if dist < shortestDistance then
                                    shortestDistance = dist
                                    closestTarget = v.HumanoidRootPart
                                end
                            end
                        end
                    end
                end

                if closestTarget then
                    pcall(function()
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(closestTarget.Position.X, hrp.Position.Y, closestTarget.Position.Z))
                        ev:FireServer("punch", "leftHand")
                        ev:FireServer("punch", "rightHand")
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

local gymCoords = {
    ["Frost Gym"] = Vector3.new(915, 37, 350),
    ["Mythical Gym"] = Vector3.new(100, 10, 100),
    ["Muscle King Gym"] = Vector3.new(200, 10, 200),
    ["Legends Gym"] = Vector3.new(300, 10, 300),
    ["Jungle Gym"] = Vector3.new(400, 10, 400),
    ["Industrial Gym"] = Vector3.new(500, 10, 500),
}

local function teleportToGym(gymName)
    local hrp = getHRP()
    if not hrp then return end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and string.find(string.lower(v.ActionText), string.lower(gymName):gsub(" Gym", "")) then
            if v.Parent and v.Parent:IsA("BasePart") then
                hrp.CFrame = v.Parent.CFrame + Vector3.new(0, 5, 0)
                return true
            end
        end
    end
    local coords = gymCoords[gymName]
    if coords then
        hrp.CFrame = CFrame.new(coords)
        return true
    end
    return false
end

local function applyStats()
    local hum = getHum()
    if hum then
        hum.WalkSpeed = State.WalkSpeed
        hum.JumpPower = State.JumpPower
        hum.UseJumpPower = true
    end
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    applyStats()
end)

--==================== ANTI-AFK & FPS BOOST ====================
local antiAfkConnection = nil
local function toggleAntiAfk(state)
    if state then
        if antiAfkConnection then return end
        antiAfkConnection = player.Idled:Connect(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end

local function toggleFPSBoost(state)
    pcall(function()
        if state then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in ipairs(game.Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") then
                    v.Enabled = false
                end
            end
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("MeshPart") then
                    v.RenderFidelity = Enum.RenderFidelity.Performance
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("SurfaceAppearance") then
                    v.Enabled = false
                end
            end
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
            for _, v in ipairs(game.Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") then
                    v.Enabled = true
                end
            end
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("MeshPart") then
                    v.RenderFidelity = Enum.RenderFidelity.Automatic
                end
            end
        end
    end)
end

--==================== UI HALLOWEEN ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ERDN_Halloween_UI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(1, 0, 1, 0)
keyFrame.BackgroundColor3 = Colors.bg
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 100
keyFrame.Parent = screenGui
spawnSpookyParticles(keyFrame, 20, {4, 8})

local keyCard = Instance.new("Frame")
keyCard.Size = UDim2.new(0, 340, 0, 240)
keyCard.Position = UDim2.new(0.5, -170, 0.5, -120)
keyCard.BackgroundColor3 = Colors.panel
keyCard.BorderSizePixel = 0
keyCard.ZIndex = 101
keyCard.Parent = keyFrame
Instance.new("UICorner", keyCard).CornerRadius = UDim.new(0, 20)

local keyStroke = Instance.new("UIStroke", keyCard)
keyStroke.Color = Colors.purple
keyStroke.Thickness = 2
keyStroke.Transparency = 0.2

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 40)
keyTitle.Position = UDim2.new(0, 0, 0, 25)
keyTitle.BackgroundTransparency = 1
keyTitle.RichText = true
keyTitle.Text = "🎃 <font color='#ff6400'>ERDN</font> <font color='#9b30ff'>PREMIUM</font> 🎃"
keyTitle.TextColor3 = Colors.white
keyTitle.TextSize = 24
keyTitle.Font = Enum.Font.GothamBold
keyTitle.ZIndex = 102
keyTitle.Parent = keyCard

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -60, 0, 45)
keyInput.Position = UDim2.new(0, 30, 0, 85)
keyInput.BackgroundColor3 = Colors.bg
keyInput.PlaceholderText = "Enter spooky key..."
keyInput.PlaceholderColor3 = Colors.textDim
keyInput.Text = ""
keyInput.TextColor3 = Colors.text
keyInput.TextSize = 14
keyInput.Font = Enum.Font.GothamMedium
keyInput.ZIndex = 102
keyInput.Parent = keyCard
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 10)
local inputStroke = Instance.new("UIStroke", keyInput); inputStroke.Color = Colors.purple; inputStroke.Thickness = 1; inputStroke.Transparency = 0.5

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(1, -60, 0, 45)
verifyBtn.Position = UDim2.new(0, 30, 0, 150)
verifyBtn.BackgroundColor3 = Colors.accent
verifyBtn.Text = "VERIFY 🦇"
verifyBtn.TextColor3 = Colors.bg
verifyBtn.TextSize = 15
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.ZIndex = 102
verifyBtn.Parent = keyCard
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 10)

local function playSplashAnimation(onComplete)
    keyFrame:Destroy()
    
    local splash = Instance.new("Frame")
    splash.Size = UDim2.new(1, 0, 1, 0)
    splash.BackgroundColor3 = Colors.bg
    splash.BorderSizePixel = 0
    splash.ZIndex = 200
    splash.Parent = screenGui
    spawnSpookyParticles(splash, 40, {2, 6})
    
    local splashGrad = Instance.new("UIGradient")
    splashGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 10, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 5, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 30))
    })
    splashGrad.Rotation = 135
    splashGrad.Parent = splash

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 80)
    logo.Position = UDim2.new(0, 0, 0.4, -60)
    logo.BackgroundTransparency = 1
    logo.RichText = true
    logo.Text = "<font color='#ff6400'>ERDN</font> <font color='#9b30ff'>PREMIUM</font>"
    logo.TextSize = 50
    logo.Font = Enum.Font.GothamBold
    logo.TextTransparency = 1
    logo.ZIndex = 201
    logo.Parent = splash

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0, 80)
    icon.Position = UDim2.new(0, 0, 0.4, -140)
    icon.BackgroundTransparency = 1
    icon.Text = "🎃"
    icon.TextSize = 70
    icon.TextTransparency = 1
    icon.ZIndex = 201
    icon.Parent = splash

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 300, 0, 8)
    barBg.Position = UDim2.new(0.5, -150, 0.5, 50)
    barBg.BackgroundColor3 = Colors.panel
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 201
    barBg.Parent = splash
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Colors.accent
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 202
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    local fillGrad = Instance.new("UIGradient"); fillGrad.Color = ColorSequence.new(Colors.accent, Colors.purple); fillGrad.Parent = barFill

    task.spawn(function()
        task.wait(0.2)
        TweenService:Create(icon, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        task.wait(0.3)
        TweenService:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
        task.wait(0.4)
        TweenService:Create(barFill, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(2)
        local fade = TweenInfo.new(0.5, Enum.EasingStyle.Quart)
        TweenService:Create(splash, fade, {BackgroundTransparency = 1}):Play()
        TweenService:Create(logo, fade, {TextTransparency = 1}):Play()
        TweenService:Create(icon, fade, {TextTransparency = 1}):Play()
        TweenService:Create(barBg, fade, {BackgroundTransparency = 1}):Play()
        task.wait(0.6)
        splash:Destroy()
        onComplete()
    end)
end

local function buildMainUI()
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 580, 0, 430)
    main.Position = UDim2.new(0.5, -290, 0.5, -215)
    main.BackgroundColor3 = Colors.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)
    spawnSpookyParticles(main, 15, {5, 10})
    
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = Colors.border
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.2

    task.spawn(function()
        while main and main.Parent do
            TweenService:Create(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {Color = Colors.accent, Transparency = 0.8}):Play()
            task.wait(2)
            TweenService:Create(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {Color = Colors.purple, Transparency = 0.2}):Play()
            task.wait(2)
        end
    end)

    main.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 580, 0, 430)}):Play()

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 55)
    header.BackgroundColor3 = Colors.sidebar
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 20)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 12)
    title.BackgroundTransparency = 1
    title.RichText = true
    title.Text = "🎃 <font color='#ff6400'>ERDN</font> <font color='#9b30ff'>PREMIUM SCRIPT</font> 🦇"
    title.TextColor3 = Colors.white
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 12)
    minimizeBtn.BackgroundColor3 = Colors.accent
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Colors.bg
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -75)
    sidebar.Position = UDim2.new(0, 12, 0, 65)
    sidebar.BackgroundColor3 = Colors.sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 6)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = sidebar
    Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 10)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -180, 1, -75)
    content.Position = UDim2.new(0, 170, 0, 65)
    content.BackgroundColor3 = Colors.panel
    content.BorderSizePixel = 0
    content.Parent = main
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 14)

    local pages = {}
    local currentTab = nil

    local function switchTab(name)
        for n, frame in pairs(pages) do
            frame.Visible = (n == name)
        end
        currentTab = name
    end

    local tabs = {
        {name = "Farm", icon = "🎃"},
        {name = "Boss", icon = "👻"},
        {name = "Teleport", icon = "🕸️"},
        {name = "Utils", icon = "🦇"},
    }

    for _, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.BackgroundColor3 = Colors.panel
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Text = "  " .. tab.icon .. "  " .. tab.name
        btn.TextColor3 = Colors.text
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -20, 1, -20)
        page.Position = UDim2.new(0, 10, 0, 10)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = false
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Parent = content
        pages[tab.name] = page

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        btn.MouseButton1Click:Connect(function()
            switchTab(tab.name)
            for _, b in ipairs(sidebar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = (b == btn) and Colors.accent or Colors.panel
                    b.TextColor3 = (b == btn) and Colors.bg or Colors.text
                end
            end
        end)
    end

    local function createToggle(parent, text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 52)
        frame.BackgroundColor3 = Colors.sidebar
        frame.BorderSizePixel = 0
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Colors.border
        stroke.Thickness = 1
        stroke.Transparency = 0.5

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Colors.text
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 44, 0, 24)
        toggle.Position = UDim2.new(1, -56, 0.5, -12)
        toggle.BackgroundColor3 = Colors.bg
        toggle.Text = ""
        toggle.Parent = frame
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = Colors.textDim
        knob.Parent = toggle
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = false
        local toggleObj = {
            set = function(newState, invoke)
                state = newState
                TweenService:Create(toggle, TweenInfo.new(0.25), {BackgroundColor3 = state and Colors.accent or Colors.bg}):Play()
                TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = state and Colors.white or Colors.textDim}):Play()
                
                if state then
                    stroke.Color = Colors.accent
                    stroke.Transparency = 0.2
                else
                    stroke.Color = Colors.border
                    stroke.Transparency = 0.5
                end
                
                if invoke and callback then callback(state) end
            end
        }

        toggle.MouseButton1Click:Connect(function() 
            toggleObj.set(not state, true) 
            local mouse = UserInputService:GetMouseLocation()
            createSparkle(frame, mouse.X, mouse.Y)
        end)
        return toggleObj
    end

    local function createButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.BackgroundColor3 = Colors.sidebar
        btn.Text = text
        btn.TextColor3 = Colors.text
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local bs = Instance.new("UIStroke", btn); bs.Color = Colors.border; bs.Thickness = 1; bs.Transparency = 0.5
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.accent, TextColor3 = Colors.bg}):Play()
            bs.Color = Colors.accent
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.sidebar, TextColor3 = Colors.text}):Play()
            bs.Color = Colors.border
        end)
        btn.MouseButton1Click:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            createSparkle(btn, mouse.X, mouse.Y)
            callback()
        end)
    end

    local farmPage = pages["Farm"]
    local rep10k, rep2k, rep500, repExact500

    -- Nuevos valores ajustados según la solicitud
    rep10k = createToggle(farmPage, "Ultra fast rep", function(v)
        if v then
            if rep2k then rep2k.set(false, false) end
            if rep500 then rep500.set(false, false) end
            if repExact500 then repExact500.set(false, false) end
            startFastRep(10000) -- 10,000 por segundo
        else stopFastRep() end
    end)

    rep2k = createToggle(farmPage, "Max Ultra rep", function(v)
        if v then
            if rep10k then rep10k.set(false, false) end
            if rep500 then rep500.set(false, false) end
            if repExact500 then repExact500.set(false, false) end
            startFastRep(5000) -- 5,000 por segundo
        else stopFastRep() end
    end)

    rep500 = createToggle(farmPage, "Mega Fast Rep", function(v)
        if v then
            if rep10k then rep10k.set(false, false) end
            if rep2k then rep2k.set(false, false) end
            if repExact500 then repExact500.set(false, false) end
            startFastRep(2000) -- 2,000 por segundo
        else stopFastRep() end
    end)

    repExact500 = createToggle(farmPage, "Fast rep", function(v)
        if v then
            if rep10k then rep10k.set(false, false) end
            if rep2k then rep2k.set(false, false) end
            if rep500 then rep500.set(false, false) end
            startFastRep(500) -- 500 por segundo
        else stopFastRep() end
    end)

    createToggle(farmPage, "Auto Rebirth (6s)", function(v)
        if v then startAutoRebirth() else State.AutoRebirth = false end
    end)
    createToggle(farmPage, "Auto Punch (Network)", function(v)
        if v then startAutoPunch() else stopAutoPunch() end
    end)
    createToggle(farmPage, "Auto Spin Wheel", function(v)
        if v then startAutoSpin() else State.AutoSpin = false end
    end)
    createToggle(farmPage, "Kill Aura (30 studs)", function(v)
        if v then startKillAura() else State.KillAura = false end
    end)

    local bossPage = pages["Boss"]
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -10, 0, 64)
    statusFrame.BackgroundColor3 = Colors.sidebar
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = bossPage
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 10)
    local sfStroke = Instance.new("UIStroke", statusFrame); sfStroke.Color = Colors.border; sfStroke.Thickness = 1; sfStroke.Transparency = 0.5
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Size = UDim2.new(1, -20, 0, 20)
    statusTitle.Position = UDim2.new(0, 12, 0, 10)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Text = "Status: Inactive"
    statusTitle.TextColor3 = Colors.text
    statusTitle.TextSize = 13
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.Parent = statusFrame

    local statusBoss = Instance.new("TextLabel")
    statusBoss.Size = UDim2.new(1, -20, 0, 16)
    statusBoss.Position = UDim2.new(0, 12, 0, 32)
    statusBoss.BackgroundTransparency = 1
    statusBoss.Text = "Boss: N/A"
    statusBoss.TextColor3 = Colors.textDim
    statusBoss.TextSize = 11
    statusBoss.Font = Enum.Font.Gotham
    statusBoss.TextXAlignment = Enum.TextXAlignment.Left
    statusBoss.Parent = statusFrame

    createToggle(bossPage, "Auto Farm Boss", function(v)
        if v then 
            startAutoFarmBoss() 
            statusTitle.Text = "Status: Farming..."
            statusTitle.TextColor3 = Colors.accent
        else 
            State.AutoFarmBoss = false 
            stopAutoPunch()
            
            local hrp = getHRP()
            if hrp then
                pcall(function() hrp.Anchored = false end)
            end
            
            statusTitle.Text = "Status: Inactive"
            statusTitle.TextColor3 = Colors.text
            statusBoss.Text = "Boss: N/A"
        end
    end)

    createButton(bossPage, "Scan Boss (Deep Log)", function()
        print("=========================================")
        print("--- INICIANDO ESCANEO EN BOSSARENA ---")
        print("=========================================")
        local found = 0
        local bossArena = Workspace:FindFirstChild("BossArena") or (Workspace:FindFirstChild("Events") and Workspace.Events:FindFirstChild("BossArena"))
        
        if bossArena then
            for _, obj in ipairs(bossArena:GetDescendants()) do
                if obj:IsA("Model") then
                    found = found + 1
                    print("Modelo:", obj.Name)
                    print("Ruta:", obj:GetFullName())
                    local hpVal = obj:FindFirstChild("Value") or obj:FindFirstChild("Health") or obj:FindFirstChild("HP")
                    if hpVal then print("  - Valor de Vida:", hpVal.Value) end
                    print("-----------------------------------------")
                end
            end
            print("--- FIN. Total jefes: " .. found .. " ---")
        else
            print("No se encontró la carpeta BossArena.")
        end
    end)

    local tpPage = pages["Teleport"]
    for gymName, _ in pairs(gymCoords) do
        createButton(tpPage, "🕸️ " .. gymName, function() teleportToGym(gymName) end)
    end

    local utilPage = pages["Utils"]
    createToggle(utilPage, "Fullbright", function(v)
        if v then
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            game.Lighting.Brightness = 2
        else
            game.Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            game.Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            game.Lighting.Brightness = 1
        end
    end)
    
    createToggle(utilPage, "Anti-AFK", function(v)
        toggleAntiAfk(v)
    end)
    
    createToggle(utilPage, "FPS Boost", function(v)
        toggleFPSBoost(v)
    end)

    switchTab("Farm")
    
    task.spawn(function()
        while screenGui.Parent do
            if State.AutoFarmBoss then
                statusBoss.Text = string.format("Bosses: %d | Target: %s (%s)", detectedBossCount, currentBossName, currentBossHealth)
            else
                statusBoss.Text = "Boss: N/A"
            end
            task.wait(0.5)
        end
    end)

    local minimized = false
    local floatBtn = nil

    local function minimize()
        if minimized then return end
        minimized = true
        TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }):Play()
        task.wait(0.35)
        main.Visible = false
        
        floatBtn = Instance.new("TextButton")
        floatBtn.Size = UDim2.new(0, 54, 0, 54)
        floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
        floatBtn.BackgroundColor3 = Colors.accent
        floatBtn.Text = "🎃"
        floatBtn.TextSize = 24
        floatBtn.Font = Enum.Font.GothamBold
        floatBtn.TextColor3 = Colors.bg
        floatBtn.Parent = screenGui
        Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
        
        local floatStroke = Instance.new("UIStroke", floatBtn)
        floatStroke.Color = Colors.purple
        floatStroke.Thickness = 2
        floatStroke.Transparency = 0.5

        floatBtn.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(floatBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 54, 0, 54)}):Play()

        task.spawn(function()
            while floatBtn and floatBtn.Parent do
                TweenService:Create(floatStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
                task.wait(1)
                TweenService:Create(floatStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.5}):Play()
                task.wait(1)
            end
        end)

        floatBtn.MouseButton1Click:Connect(function()
            if not minimized then return end
            minimized = false
            floatBtn:Destroy()
            main.Visible = true
            main.Size = UDim2.new(0, 0, 0, 0)
            main.Position = UDim2.new(0.5, 0, 0.5, 0)
            TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 580, 0, 430),
                Position = UDim2.new(0.5, -290, 0.5, -215),
            }):Play()
        end)
    end

    minimizeBtn.MouseButton1Click:Connect(minimize)
end

verifyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == KEY then
        playSplashAnimation(buildMainUI)
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "Invalid Spooky Key"
        keyInput.PlaceholderColor3 = Colors.danger
    end
end)
