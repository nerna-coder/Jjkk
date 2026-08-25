if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Ошибка при загрузке Rayfield UI: " .. tostring(err))
    return
end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local BadgeService = game:GetService("BadgeService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local placeId = game.PlaceId

local function runSuctionCode()
    task.spawn(function()
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local targets = {"PlungerMain", "plunger glove", "ToiletPlunger", "Unity"}
        for _, name in ipairs(targets) do
            local item = workspace:FindFirstChild(name, true)
            if item then
                hrp.CFrame = item:GetPivot()
                task.wait(0.4)
                local cd = item:FindFirstChildWhichIsA("ClickDetector", true)
                if cd then fireclickdetector(cd) end
                local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                if part and firetouchinterest then
                    firetouchinterest(hrp, part, 0)
                    firetouchinterest(hrp, part, 1)
                end
                task.wait(0.4)
            end
        end
    end)
end

local function runAutoGetCamera()
    task.spawn(function()
        local Players      = game:GetService("Players")
        local RS           = game:GetService("ReplicatedStorage")
        local VIM          = game:GetService("VirtualInputManager")

        local player       = Players.LocalPlayer
        local char         = player.Character or player.CharacterAdded:Wait()
        local hrp          = char:WaitForChild("HumanoidRootPart")
        local humanoid     = char:WaitForChild("Humanoid")
        local camRemotes   = RS.Assets.Obtainments.Camera.Remotes
        local isPhotoValid = camRemotes.IsPhotoValid

        local function tp(pos)
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
            task.wait(0.35)
        end

        local function pressQ()
            VIM:SendKeyEvent(true,  Enum.KeyCode.Q, false, game)
            task.wait(0.15)
            VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            task.wait(0.5)
        end

        local function waitFor(condition, timeout)
            local t = tick()
            repeat task.wait(0.25) until condition() or tick() - t > (timeout or 15)
            return condition()
        end

        pressQ()

        local CAMERA_SPAWN = Vector3.new(-385.063934, 52.0801315, 2.81142139)
        tp(CAMERA_SPAWN)

        local cameraModel = nil

        local gotIt = waitFor(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "CameraModel" and v:IsA("Model") then
                    cameraModel = v
                    return true
                end
            end
        end, 0.4)

        if not gotIt or not cameraModel then
            pressQ()
            tp(CAMERA_SPAWN)
            waitFor(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.Name == "CameraModel" and v:IsA("Model") then
                        cameraModel = v
                        return true
                    end
                end
            end, 0.4)
        end

        if cameraModel then
            local camPartPos = cameraModel.PrimaryPart and cameraModel.PrimaryPart.Position
                or cameraModel:GetPivot().Position
            tp(camPartPos)

            local prompt = cameraModel:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            end
        end

        task.wait(1.5)

        local camTool = player.Backpack:FindFirstChild("Camera")
            or (char and char:FindFirstChild("Camera"))

        if camTool then
            humanoid:EquipTool(camTool)
            task.wait(1.2)
        end

        local PNG_SPOTS = {
            { "1 – Cannon Island",           Vector3.new( 316.721,  31.268,  188.642), Vector3.new( 0.996, 0, -0.087) },
            { "2 – Chain Obby to Slapple",   Vector3.new(-128.993,  -1.786,  125.199), Vector3.new( 0.705, 0, -0.709) },
            { "3 – Moai Island Statue",      Vector3.new(-274.513, -19.490,  -10.172), Vector3.new(-0.714, 0,  0.700) },
            { "4 – Slapple Island Big Tree", Vector3.new(-425.410,  56.777,  -23.400), Vector3.new( 0,     0,  1    ) },
            { "5 – East Island Tree",        Vector3.new(  -8.155,  -2.694, -208.862), Vector3.new(-0.985, 0, -0.174) },
            { "6 – The Fort",                Vector3.new( 242.086, -10.646,  -25.781), Vector3.new( 0.445, 0,  0.895) },
            { "7 – Chain (Default↔Normal)",  Vector3.new( 116.677,  -2.879,    1.637), Vector3.new(-0.991, 0, -0.131) },
        }

        local function photographPart(part, lookVec)
            local standPos = part.Position + lookVec * 7
            tp(standPos)

            workspace.CurrentCamera.CFrame = CFrame.lookAt(
                standPos + Vector3.new(0, 2, 0),
                part.Position
            )
            task.wait(0.25)

            local ok, result = pcall(function()
                return isPhotoValid:InvokeServer(part)
            end)

            if ok and result then
                part:Destroy()
                return true
            elseif ok then
                VIM:SendMouseButtonEvent(0, 0, 0, true,  game, 1)
                task.wait(0.05)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                task.wait(0.4)
                return false
            else
                return false
            end
        end

        local folder = workspace:FindFirstChild("Camera_Obtainment_PNGS")
        if not folder then return end

        for i, spot in ipairs(PNG_SPOTS) do
            local name, targetPos, lookVec = spot[1], spot[2], spot[3]

            local matchedPart = nil
            for _, p in ipairs(folder:GetChildren()) do
                if p:IsA("BasePart") and (p.Position - targetPos).Magnitude < 2 then
                    matchedPart = p
                    break
                end
            end

            if not matchedPart then
                continue
            end

            photographPart(matchedPart, lookVec)
            task.wait(0.5)
        end
    end)
end

local function runAutoGetAlchemist()
    pcall(function()
        local Namecall
        Namecall = hookmetamethod(game, "__namecall", function(self, ...)
           if getnamecallmethod() == "FireServer" and tostring(self) == "Ban" then
               return
           elseif getnamecallmethod() == "FireServer" and tostring(self) == "WalkSpeedChanged" then
               return
           elseif getnamecallmethod() == "FireServer" and tostring(self) == "AdminGUI" then
               return
           end
           return Namecall(self, ...)
        end)
    end)

    _G.AntiRagdoll = true
    if _G.AntiRagdoll then
        game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
            local ragdolled = char:WaitForChild("Ragdolled", 5)
            if ragdolled then
                ragdolled.Changed:Connect(function()
                    if ragdolled.Value == true and _G.AntiRagdoll then
                        repeat task.wait() 
                            if char:FindFirstChild("Torso") then
                                char.Torso.Anchored = true
                            end
                        until ragdolled.Value == false
                        if char:FindFirstChild("Torso") then
                            char.Torso.Anchored = false
                        end
                    end
                end)
            end
        end)
    end

    local arenaBarrier = workspace:FindFirstChild("ArenaBarrier")
    local deathBarrier = workspace:FindFirstChild("DEATHBARRIER")
    local deathBarrier2 = workspace:FindFirstChild("DEATHBARRIER2")
    local dedBarrier = workspace:FindFirstChild("dedBarrier")

    if arenaBarrier then arenaBarrier:Destroy() end
    if deathBarrier then deathBarrier:Destroy() end
    if deathBarrier2 then deathBarrier2:Destroy() end
    if dedBarrier then dedBarrier:Destroy() end

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(1000, 1, 1000) 
    platform.Position = Vector3.new(-24058.8594, 306.104187, -844.946045)
    platform.CFrame = CFrame.new(platform.Position)
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Material = Enum.Material.Plastic
    platform.Transparency = 1
    platform.Parent = workspace

    local weld = Instance.new("WeldConstraint")
    weld.Parent = platform
    weld.Part0 = platform
    weld.Part1 = workspace.Terrain

    task.wait(0.2)

    pcall(function()
        if game.Players.LocalPlayer.leaderstats.Slaps.Value >= 666 then
            pcall(function() fireclickdetector(workspace.Lobby.Ghost.ClickDetector) end)
            task.wait(0.3)
            pcall(function() game:GetService("ReplicatedStorage").Ghostinvisibilityactivated:FireServer() end)
        end
    end)

    task.wait(0.3)

    local scriptActive = true

    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        scriptActive = false
    end)

    pcall(function()
        if game:GetService("BadgeService"):UserHasBadgeAsync(game.Players.LocalPlayer.UserId, 2124819262) then
            pcall(function() fireclickdetector(workspace.Lobby.Plague.ClickDetector) end)
            task.wait(0.3)
            
            task.spawn(function()
                local killCount = 0
                local trackedPlayers = {}
                
                while scriptActive do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        for _, targetPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
                            if not scriptActive then break end
                            if targetPlayer ~= player and targetPlayer.Character then
                                local char = targetPlayer.Character
                                local leftArm = char:FindFirstChild("Left Arm")
                                local humanoid = char:FindFirstChildOfClass("Humanoid")
                                
                                if leftArm and humanoid and humanoid.Health > 0 then
                                    game:GetService("ReplicatedStorage").PlagueHit:FireServer(leftArm)
                                    
                                    if (humanoid.Health <= 1 or char:FindFirstChild("ded")) and not trackedPlayers[targetPlayer] then
                                        trackedPlayers[targetPlayer] = true
                                        killCount = killCount + 1
                                        
                                        if killCount >= 5 then
                                            scriptActive = false
                                            task.wait(6)
                                            
                                            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                                                player.Character:FindFirstChildOfClass("Humanoid").Health = 0
                                            end
                                            
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end)

    task.spawn(function()
        local player = game.Players.LocalPlayer
        
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Head") then
                firetouchinterest(player.Character.Head, workspace.Lobby.Teleport1, 0)
            end
        end)
        
        while scriptActive do
            task.wait(2)
            if not scriptActive then break end
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                player.Character.HumanoidRootPart.CFrame = CFrame.new(-24036.2266, 316.696503, -855.74939)
            end)
            
            task.wait(2)
            if not scriptActive then break end
            
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                
                local validPlayers = {}
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local char = p.Character
                        if not char:FindFirstChild("InLobby") and not char:FindFirstChild("ded") and not char:FindFirstChild("InLabyrinth") then
                            table.insert(validPlayers, char)
                        end
                    end
                end
                
                if #validPlayers > 0 then
                    local randomTarget = validPlayers[math.random(1, #validPlayers)]
                    player.Character.HumanoidRootPart.CFrame = randomTarget.HumanoidRootPart.CFrame
                end
            end)
        end
    end)

    task.spawn(function()
        while scriptActive do
            pcall(function()
                for _, v in pairs(game.Players:GetChildren()) do
                    if v.Character and v.Character:FindFirstChild("rock") then
                        v.Character:FindFirstChild("rock").CanTouch = false
                        v.Character:FindFirstChild("rock").CanQuery = false
                    end
                end
            end)
            task.wait()
        end
    end)
end

local function runAutoGetSand()
    local LocalPlayer = Players.LocalPlayer
    local TeleportService = game:GetService("TeleportService")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local queue = queueonteleport or queue_on_teleport

    local targetPlace = 122902713960550

    if game.PlaceId ~= targetPlace then
        TeleportService:Teleport(targetPlace)
        if queue then
            queue([[
                if not game:IsLoaded() then
                   game.Loaded:Wait()
                end
                if game.PlaceId ~= 122902713960550 then return end
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Workspace = game:GetService("Workspace")
                local Camera = Workspace.CurrentCamera
                
                repeat task.wait() until Workspace:FindFirstChild("Island") and Workspace.Island:FindFirstChild("John Surfboard")
                
                LocalPlayer.Character:PivotTo(Workspace.Island["John Surfboard"].Head:GetPivot())
                task.wait(.3)
                fireproximityprompt(Workspace.Island["John Surfboard"].Head:FindFirstChildWhichIsA("ProximityPrompt"))
                wait(.1)
                for i = 1,20 do
                    local args = {
                        [1] = 0
                    }
                    game:GetService("ReplicatedStorage").Modules.Common.Dialogue.Remotes.ResondToDialogue:FireServer(unpack(args))
                    wait()
                end
                
                task.wait(1)
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                
                while wait() do
                    for i,v in pairs(workspace.ObjectSpawner_Objects:GetChildren()) do
                        v:Destroy()
                    end
                end
            ]])
        end
        return
    end

    repeat task.wait() until Workspace:FindFirstChild("Island") and Workspace.Island:FindFirstChild("John Surfboard")

    LocalPlayer.Character:PivotTo(Workspace.Island["John Surfboard"].Head:GetPivot())
    task.wait(.3)
    fireproximityprompt(Workspace.Island["John Surfboard"].Head:FindFirstChildWhichIsA("ProximityPrompt"))
    wait(.1)
    for i = 1,20 do
        local args = {
            [1] = 0
        }
        
        game:GetService("ReplicatedStorage").Modules.Common.Dialogue.Remotes.ResondToDialogue:FireServer(unpack(args))
        wait()
    end

    task.wait(1)
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    while wait() do
        for i,v in pairs(workspace.ObjectSpawner_Objects:GetChildren()) do
            v:Destroy()
        end
    end
end

local Window

if placeId == 122902713960550 then
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Button = Instance.new("TextButton")
    local UICorner_2 = Instance.new("UICorner")

    ScreenGui.Name = "SandGui"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 220, 0, 90)

    UICorner.Parent = MainFrame

    Button.Name = "AutoGetSandButton"
    Button.Parent = MainFrame
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Position = UDim2.new(0.08, 0, 0.2, 0)
    Button.Size = UDim2.new(0, 185, 0, 50)
    Button.Font = Enum.Font.SourceSansBold
    Button.Text = "Auto-Get sand"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 18

    UICorner_2.Parent = Button

    Button.MouseButton1Click:Connect(function()
        runAutoGetSand()
    end)

elseif placeId == 11828384869 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Counter & Elude",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Badges", 4483345998)
    Tab:CreateButton({
        Name = "Counter + Elude",
        Callback = function()
            task.spawn(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                for i, v in next, workspace:GetDescendants() do
                    if v:IsA("ClickDetector") then fireclickdetector(v) end
                end
                humanoidRootPart:PivotTo(CFrame.new(0, 1500, 0))
                task.wait(1)
                humanoidRootPart.Anchored = true
                local timeLeft = 120
                for i = 1, 120 do
                    timeLeft = timeLeft - 1
                    local msg = Instance.new("Message", workspace)
                    msg.Text = "Seconds left to receive: " .. timeLeft
                    task.wait(1)
                    msg:Destroy()
                end
                task.wait(2)
                task.spawn(function()
                    while task.wait() do
                        if character and humanoidRootPart and workspace:FindFirstChild("Ruins") then
                            humanoidRootPart:PivotTo(workspace.Ruins.Elude.Glove.CFrame)
                        end
                    end
                end)
                task.wait(0.25)
                for i, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ClickDetector") then fireclickdetector(v) end
                end
            end)
        end
    })
    Tab:CreateButton({
        Name = "Get Alchemist Plushie",
        Callback = function()
            for i, v in next, workspace:GetDescendants() do
                if v:IsA("ClickDetector") then fireclickdetector(v) end
            end
        end
    })

elseif placeId == 18550498098 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Place 18550498098",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Auto-Get scripts", 4483345998)

    Tab:CreateButton({
        Name = "Avatar + Relude",
        Callback = function()
            local plrs = game:GetService("Players")
            local storage = game:GetService("ReplicatedStorage")
            local lp = plrs.LocalPlayer
            local function getChar()
                local char = lp.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then return char, hrp end
                end
            end
            local function freeze(hrp, enable)
                if not hrp then return end
                local bv = hrp:FindFirstChild("ServerHoldVelocity")
                if enable then
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "ServerHoldVelocity"
                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                        bv.Velocity = Vector3.zero
                        bv.Parent = hrp
                    end
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                else
                    if bv then bv:Destroy() end
                end
            end
            task.spawn(function()
                local cf = CFrame.new(3249.47, -58.50, 821.98, 0.017, 0, -1, 0, 1, 0, 1, 0, 0.017)
                local t = tick()
                while tick() - t < 26 do
                    local _, hrp = getChar()
                    if hrp then hrp.CFrame = cf end
                    task.wait()
                end
            end)
            task.wait(5)
            for _, v in workspace:GetDescendants() do
                if v.Name == "ShackLever" then
                    local cd = v:FindFirstChildWhichIsA("ClickDetector")
                    if cd then
                        pcall(function()
                            for _ = 1, 10 do fireclickdetector(cd) task.wait(0.1) end
                        end)
                    end
                end
            end
            repeat task.wait(0.5)
            until workspace:FindFirstChild("Map")
              and workspace.Map:FindFirstChild("Components")
              and workspace.Map.Components:FindFirstChild("GuideNPC")
            local cf2 = CFrame.new(589.10, 189.86, -246.86, -1, 0, 0.012, 0, 1, -0.004, -0.012, -0.004, -1)
            task.spawn(function()
                while true do
                    local char, hrp = getChar()
                    if char and hrp then char:PivotTo(cf2) freeze(hrp, true) end
                    task.wait()
                end
            end)
            while task.wait(0.1) do
                local char, hrp = getChar()
                if char then
                    local item = lp.Backpack:FindFirstChild("Lantern")
                    if item then item.Parent = char end
                    pcall(function()
                        local remotes = storage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("Data") and remotes.Data:FindFirstChild("AnswerInCutscene") then
                            remotes.Data.AnswerInCutscene:FireServer("Spare")
                        end
                    end)
                    local lantern = char:FindFirstChild("Lantern")
                    if lantern then
                        lantern:Activate()
                        local net = lantern:FindFirstChild("Network")
                        if net then
                            for _, v in workspace:GetChildren() do
                                if v.Name == "PusherWall" and v:IsA("BasePart") then v.CanCollide = false
                                elseif v.Name == "golem" and v:FindFirstChild("Hitbox") then net:FireServer("Hit", v.Hitbox)
                                elseif (v.Name == "GuideNPC" or v.Name == "ReplicaNPC") and v:FindFirstChild("HumanoidRootPart") then net:FireServer("Hit", v.HumanoidRootPart)
                                elseif v.Name == "TrackGloveMissile" then net:FireServer("Hit", v)
                                end
                            end
                        end
                    end
                end
            end
        end
    })

    Tab:CreateButton({
        Name = "Avatar + Hunters",
        Callback = function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local function getChar()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
                    if char.Humanoid.Health > 0 then return char, char.HumanoidRootPart end
                end
                return nil, nil
            end
            local function setPhysicsFreeze(hrp, state)
                if not hrp then return end
                local bv = hrp:FindFirstChild("ServerHoldVelocity")
                if state then
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "ServerHoldVelocity"
                        bv.MaxForce = Vector3.new(30000000, 30000000, 30000000)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bv.Parent = hrp
                    end
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                else
                    if bv then bv:Destroy() end
                end
            end
            task.spawn(function()
                local targetCFrame = CFrame.new(3249.47, -58.50, 821.98, 0.017, -0.000, -1.000, -0.000, 1.000, -0.000, 1.000, 0.000, 0.017)
                local start = tick()
                while tick() - start < 26 do
                    local char, hrp = getChar()
                    if char and hrp then hrp.CFrame = targetCFrame end
                    task.wait()
                end
            end)
            task.wait(5)
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "ShackLever" then
                    local detector = v:FindFirstChildWhichIsA("ClickDetector")
                    if detector then
                        pcall(function()
                            for i = 1, 10 do fireclickdetector(detector) task.wait(0.1) end
                        end)
                    end
                end
            end
            repeat task.wait(0.5)
            until workspace:FindFirstChild("Map")
              and workspace.Map:FindFirstChild("Components")
              and workspace.Map.Components:FindFirstChild("GuideNPC")
            local targetCFrame2 = CFrame.new(589.10, 189.86, -246.86, -1.000, 0.000, 0.012, 0.000, 1.000, -0.004, -0.012, -0.004, -1.000)
            task.spawn(function()
                while true do
                    local char, hrp = getChar()
                    if char and hrp then char:PivotTo(targetCFrame2) setPhysicsFreeze(hrp, true) end
                    task.wait()
                end
            end)
            while task.wait(0.1) do
                local char, hrp = getChar()
                if char then
                    local backpackLantern = LocalPlayer.Backpack:FindFirstChild("Lantern")
                    if backpackLantern then backpackLantern.Parent = char end
                    local lantern = char:FindFirstChild("Lantern")
                    if lantern then
                        lantern:Activate()
                        local network = lantern:FindFirstChild("Network")
                        if network then
                            for _, v in ipairs(workspace:GetChildren()) do
                                if v.Name == "PusherWall" and v:IsA("BasePart") then v.CanCollide = false end
                                if v.Name == "golem" and v:FindFirstChild("Hitbox") then network:FireServer("Hit", v.Hitbox) end
                                if (v.Name == "GuideNPC" or v.Name == "ReplicaNPC") and v:FindFirstChild("HumanoidRootPart") then network:FireServer("Hit", v.HumanoidRootPart) end
                                if v.Name == "TrackGloveMissile" then network:FireServer("Hit", v) end
                            end
                        end
                    end
                end
            end
        end
    })

    Tab:CreateButton({
        Name = "Relude",
        Callback = function()
            local plrs = game:GetService("Players")
            local storage = game:GetService("ReplicatedStorage")
            local lp = plrs.LocalPlayer
            local function getChar()
                local char = lp.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then return char, hrp end
                end
            end
            local function freeze(hrp, enable)
                if not hrp then return end
                local bv = hrp:FindFirstChild("ServerHoldVelocity")
                if enable then
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "ServerHoldVelocity"
                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                        bv.Velocity = Vector3.zero
                        bv.Parent = hrp
                    end
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                else
                    if bv then bv:Destroy() end
                end
            end
            local startCF = CFrame.new(3270.68, -227.50, 822.93, 0.580, 0.000, -0.814, -0.000, 1.000, 0.000, 0.814, 0.000, 0.580)
            local t0 = tick()
            while tick() - t0 < 0.5 do
                local char, hrp = getChar()
                if char and hrp then char:PivotTo(startCF) end
                task.wait()
            end
            task.spawn(function()
                local cf = CFrame.new(3249.47, -58.50, 821.98, 0.017, 0, -1, 0, 1, 0, 1, 0, 0.017)
                local t = tick()
                while tick() - t < 26 do
                    local _, hrp = getChar()
                    if hrp then hrp.CFrame = cf end
                    task.wait()
                end
            end)
            task.wait(5)
            for _, v in workspace:GetDescendants() do
                if v.Name == "ShackLever" then
                    local cd = v:FindFirstChildWhichIsA("ClickDetector")
                    if cd then
                        pcall(function()
                            for _ = 1, 10 do fireclickdetector(cd) task.wait(0.1) end
                        end)
                    end
                end
            end
            repeat task.wait(0.5)
            until workspace:FindFirstChild("Map")
              and workspace.Map:FindFirstChild("Components")
              and workspace.Map.Components:FindFirstChild("GuideNPC")
            local cf2 = CFrame.new(589.10, 189.86, -246.86, -1, 0, 0.012, 0, 1, -0.004, -0.012, -0.004, -1)
            task.spawn(function()
                while true do
                    local char, hrp = getChar()
                    if char and hrp then char:PivotTo(cf2) freeze(hrp, true) end
                    task.wait()
                end
            end)
            while task.wait(0.1) do
                local char, hrp = getChar()
                if char then
                    local item = lp.Backpack:FindFirstChild("Lantern")
                    if item then item.Parent = char end
                    pcall(function()
                        local remotes = storage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("Data") and remotes.Data:FindFirstChild("AnswerInCutscene") then
                            remotes.Data.AnswerInCutscene:FireServer("Spare")
                        end
                    end)
                    local lantern = char:FindFirstChild("Lantern")
                    if lantern then
                        lantern:Activate()
                        local net = lantern:FindFirstChild("Network")
                        if net then
                            for _, v in workspace:GetChildren() do
                                if v.Name == "PusherWall" and v:IsA("BasePart") then v.CanCollide = false
                                elseif v.Name == "golem" and v:FindFirstChild("Hitbox") then net:FireServer("Hit", v.Hitbox)
                                elseif (v.Name == "GuideNPC" or v.Name == "ReplicaNPC") and v:FindFirstChild("HumanoidRootPart") then net:FireServer("Hit", v.HumanoidRootPart)
                                elseif v.Name == "TrackGloveMissile" then net:FireServer("Hit", v)
                                end
                            end
                        end
                    end
                end
            end
        end
    })

    Tab:CreateButton({
        Name = "Hunters",
        Callback = function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local function getChar()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
                    if char.Humanoid.Health > 0 then return char, char.HumanoidRootPart end
                end
            end
            local function setPhysicsFreeze(hrp, state)
                if not hrp then return end
                local bv = hrp:FindFirstChild("ServerHoldVelocity")
                if state then
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "ServerHoldVelocity"
                        bv.MaxForce = Vector3.new(30000000, 30000000, 30000000)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bv.Parent = hrp
                    end
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                else
                    if bv then bv:Destroy() end
                end
            end
            local initStart = tick()
            while tick() - initStart < 0.5 do
                local char, hrp = getChar()
                if char and hrp then
                    hrp.CFrame = CFrame.new(3270.68, -227.50, 822.93, 0.580, 0.000, -0.814, -0.000, 1.000, 0.000, 0.814, 0.000, 0.580)
                end
                task.wait()
            end
            task.spawn(function()
                local targetCFrame = CFrame.new(3249.47, -58.50, 821.98, 0.017, -0.000, -1.000, -0.000, 1.000, -0.000, 1.000, 0.000, 0.017)
                local start = tick()
                while tick() - start < 26 do
                    local char, hrp = getChar()
                    if char and hrp then hrp.CFrame = targetCFrame end
                    task.wait()
                end
            end)
            task.wait(5)
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "ShackLever" then
                    local detector = v:FindFirstChildWhichIsA("ClickDetector")
                    if detector then
                        pcall(function()
                            for i = 1, 10 do fireclickdetector(detector) task.wait(0.1) end
                        end)
                    end
                end
            end
            repeat task.wait(0.5)
            until workspace:FindFirstChild("Map")
              and workspace.Map:FindFirstChild("Components")
              and workspace.Map.Components:FindFirstChild("GuideNPC")
            local targetCFrame2 = CFrame.new(589.10, 189.86, -246.86, -1.000, 0.000, 0.012, 0.000, 1.000, -0.004, -0.012, -0.004, -1.000)
            task.spawn(function()
                while true do
                    local char, hrp = getChar()
                    if char and hrp then char:PivotTo(targetCFrame2) setPhysicsFreeze(hrp, true) end
                    task.wait()
                end
            end)
            while task.wait(0.1) do
                local char, hrp = getChar()
                if char then
                    local backpackLantern = LocalPlayer.Backpack:FindFirstChild("Lantern")
                    if backpackLantern then backpackLantern.Parent = char end
                    local lantern = char:FindFirstChild("Lantern")
                    if lantern then
                        lantern:Activate()
                        local network = lantern:FindFirstChild("Network")
                        if network then
                            for _, v in ipairs(workspace:GetChildren()) do
                                if v.Name == "PusherWall" and v:IsA("BasePart") then v.CanCollide = false end
                                if v.Name == "golem" and v:FindFirstChild("Hitbox") then network:FireServer("Hit", v.Hitbox) end
                                if (v.Name == "GuideNPC" or v.Name == "ReplicaNPC") and v:FindFirstChild("HumanoidRootPart") then network:FireServer("Hit", v.HumanoidRootPart) end
                                if v.Name == "TrackGloveMissile" then network:FireServer("Hit", v) end
                            end
                        end
                    end
                end
            end
        end
    })

elseif placeId == 128229958211947 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Shellbert",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Shellbert", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get Shellbert",
        Callback = function()
            local char = lp.Character or lp.CharacterAdded:Wait()
            local HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
            local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
            if not remotes then return end
            for i = 1, 3 do
                pcall(function()
                    remotes.Cutscene.OnComplete:FireServer("Scene1")
                    task.wait(0.1)
                    remotes.PhaseTransition.Switch:FireServer()
                    task.wait(0.1)
                    remotes.PhaseTransition.Finished:FireServer()
                    task.wait(0.1)
                    remotes.Cutscene.OnLoaded:FireServer("Scene2")
                    task.wait(0.1)
                    remotes.Cutscene.OnComplete:FireServer("Scene2")
                    task.wait(0.1)
                    remotes.GloveReward.Replicate:FireServer()
                    task.wait(0.1)
                end)
            end
            task.wait(2)
            if HumanoidRootPart then
                for i = 1, 50 do
                    if Workspace:FindFirstChild("RewardGlove") and Workspace.RewardGlove:FindFirstChild("RewardGlove") then
                        HumanoidRootPart:PivotTo(Workspace.RewardGlove.RewardGlove.CFrame)
                    end
                    task.wait(0.05)
                end
            end
        end
    })

elseif placeId == 89837553336708 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Suction",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Suction", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get suction",
        Callback = function() runSuctionCode() end
    })

elseif placeId == 74169485398268 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Bind",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Bind", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get bind",
        Callback = function()
            task.spawn(function()
                local orb = workspace:FindFirstChild("Orb")
                if orb then
                    local cd = orb:FindFirstChildWhichIsA("ClickDetector")
                    if cd then
                        for i = 1, 10 do fireclickdetector(cd) end
                    end
                end
            end)
        end
    })

elseif placeId == 129665246576996 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Eggler",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Eggler", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get eggler",
        Callback = function()
            local char = lp.Character or lp.CharacterAdded:Wait()
            local folder = workspace:FindFirstChild("TrialCompletedPoints")
            if char and char:FindFirstChild("HumanoidRootPart") and folder then
                local cf = char.HumanoidRootPart.CFrame
                for i = 1, 3 do
                    local trial = folder:FindFirstChild("Trial " .. i)
                    if trial and trial:FindFirstChild("root") then
                        trial.root.CFrame = cf
                    end
                end
            end
        end
    })
    Tab:CreateButton({
        Name = "Auto-Get Shellbert",
        Callback = function()
            local tpdata = (queue_on_teleport or queueonteleport)
            local code = [[
                for i=1,3 do
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Cutscene"):WaitForChild("OnComplete"):FireServer("Scene1")
                    task.wait(0.1)
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PhaseTransition"):WaitForChild("Switch"):FireServer()
                    task.wait(0.1)
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PhaseTransition"):WaitForChild("Finished"):FireServer()
                    task.wait(0.1)
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Cutscene"):WaitForChild("OnLoaded"):FireServer("Scene2")
                    task.wait(0.1)
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Cutscene"):WaitForChild("OnComplete"):FireServer("Scene2")
                    task.wait(0.1)
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GloveReward"):WaitForChild("Replicate"):FireServer()
                    task.wait(0.1)
                end
                task.wait(2)
                local char = game:GetService("Players").LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for i=1,50 do
                        if workspace:FindFirstChild("RewardGlove") then
                            char.HumanoidRootPart:PivotTo(workspace.RewardGlove.RewardGlove.CFrame)
                        end
                        task.wait(0.05)
                    end
                end
            ]]
            if tpdata then
                pcall(function() tpdata((GlobalTPData or "") .. code) end)
            end
            task.spawn(function()
                local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
                if not remotes then return end
                for i = 1, 50 do
                    pcall(function()
                        remotes.FourthTrialTeleport:FireServer()
                        remotes.InviteFriends.PlayWithParty:FireServer()
                        remotes.InviteFriends.CancelPartyTeleport:FireServer()
                    end)
                    task.wait(0.2)
                end
            end)
        end
    })

elseif placeId == 106620300132058 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Plate ID",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Plate", 4483345998)
    Tab:CreateButton({
        Name = "Plate",
        Callback = function()
            local RED_COLOR = Color3.fromRGB(255, 0, 0)
            local function cleanAndNoclip()
                local character = lp.Character
                if not character then return end
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if part.Color == RED_COLOR then pcall(function() part:Destroy() end) end
                        if part:IsDescendantOf(character) then part.CanCollide = false end
                    end
                end
            end
            RunService.Stepped:Connect(cleanAndNoclip)
        end
    })

elseif placeId == 97220865182663 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Rat Place",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Rats", 4483345998)
    Tab:CreateButton({
        Name = "Instail kills rat",
        Callback = function()
            _G.KillRatsInstantly = true
            task.spawn(function()
                while _G.KillRatsInstantly do
                    pcall(function()
                        for _, rat in ipairs(game.Workspace.Game.Enemies:GetChildren()) do
                            if rat.Name == 'Rat' and rat:FindFirstChild('Humanoid') then
                                rat.Humanoid.Health = 0
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
    })
    Tab:CreateButton({
        Name = "auto Master Whiskers Potion",
        Callback = function()
            _G.AutoPotion = true
            task.spawn(function()
                while _G.AutoPotion do
                    game:GetService('ReplicatedStorage').Remotes.UnlockGloveWithOrbs:FireServer()
                    task.wait(0.2)
                end
            end)
        end
    })

elseif placeId == 113228834069218 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Penguin / Fish",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Quest", 4483345998)
    Tab:CreateButton({
        Name = "collect all fish",
        Callback = function()
            local hrp = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
            for i, v in workspace.Fih:GetChildren() do
                if v:FindFirstChild("Fish") then
                    firetouchinterest(hrp, v.Fish, 0)
                    firetouchinterest(hrp, v.Fish, 1)
                end
            end
            task.wait(0.5)
            firetouchinterest(hrp, workspace.FinishPart, 0)
        end
    })

elseif placeId == 86643839793301 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Quests",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Quests", 4483345998)
    Tab:CreateButton({
        Name = "Teleport to Alex's quest",
        Callback = function() game:GetService("TeleportService"):Teleport(95356852680586) end
    })
    Tab:CreateButton({
        Name = "Teleport to Sam quest",
        Callback = function() game:GetService("TeleportService"):Teleport(113228834069218) end
    })

elseif placeId == 95356852680586 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Snowman",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Snowman", 4483345998)
    Tab:CreateButton({
        Name = "Build a snowman",
        Callback = function()
            local lp = game:GetService("Players").LocalPlayer
            local char = lp.Character
            local hrp = char.HumanoidRootPart
            local fpp = function(proximity, sec)
                hrp.CFrame = proximity.Parent:GetPivot()
                task.wait(sec or 1)
                fireproximityprompt(proximity)
            end
            local acc = {}
            for i, v in workspace.Snowman.Models.DisplaySnowman.Accessories:GetDescendants() do
                if v.Name == "Handle" and v.Transparency == 0 then
                    table.insert(acc, workspace.Accessories:FindFirstChild(v.Parent.Name).ProximityPrompt)
                end
            end
            local playerSnowman = workspace.Snowman.Models.PlayerSnowman.ProximityPrompt
            fpp(workspace.Interactables.SnowObject.ProximityPrompt, 0.5)
            char.Humanoid:EquipTool(lp.Backpack:WaitForChild("Snow"))
            for i = 1, 3 do fpp(playerSnowman) end
            for i, v in acc do fpp(v, 0.5) fpp(playerSnowman) end
        end
    })

elseif placeId == 7234087065 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - ID 7234087065",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Fan & Riftshot", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get Fan",
        Callback = function()
            local character = lp.Character or lp.CharacterAdded:Wait()
            local HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            if not HumanoidRootPart then return end
            for i = 1, 50 do
                if workspace:FindFirstChild("QuestStuff") and workspace.QuestStuff:FindFirstChild("Key") then
                    HumanoidRootPart:PivotTo(workspace.QuestStuff.Key.CFrame)
                end
                task.wait(0.02)
            end
            task.wait(1.5)
            local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if remotes then
                pcall(function()
                    remotes.SuitUpClown:FireServer()
                    task.wait(0.25)
                    remotes.KeyQuest:FireServer()
                    task.wait(0.25)
                    remotes.KeyAcquired:FireServer()
                    task.wait(0.25)
                    remotes.GOHOME:FireServer()
                    task.wait(0.25)
                    remotes.KeyBadgeReward:FireServer()
                end)
            end
        end
    })
    Tab:CreateButton({
        Name = "Auto-Get Riftshot",
        Callback = function()
            pcall(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    lp.Character.HumanoidRootPart.CFrame = CFrame.new(-260, 16, 477)
                    task.wait(0.8)
                    if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("TargetPractice") then
                        ReplicatedStorage.RemoteEvents.TargetPractice.OnComplete:FireServer()
                    end
                    lp.Character.HumanoidRootPart.CFrame = CFrame.new(-260, 16, 477)
                    task.wait(1)
                    if ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("TargetPractice") then
                        ReplicatedStorage.RemoteEvents.TargetPractice.OnComplete:FireServer()
                    end
                end
            end)
        end
    })
    Tab:CreateButton({
        Name = "Auto Boxing Gloves",
        Callback = function()
            local targetCFrame = CFrame.new(4231.91, 3505.89, 269.59, 0.993, -0.000, 0.120, 0.000, 1.000, 0.000, -0.120, -0.000, 0.993)
            local character = lp.Character or lp.CharacterAdded:Wait()
            character:PivotTo(targetCFrame)
            task.wait(1.5)
            if workspace:FindFirstChild("BoxingGloves") and workspace.BoxingGloves:FindFirstChild("ClickDetector") then
                fireclickdetector(workspace.BoxingGloves.ClickDetector)
            end
        end
    })
    Tab:CreateButton({
        Name = "Auto-Get UTG",
        Callback = function()
            local targetCFrame = CFrame.new(-1233.92, 9900.16, 704.24, 0.936, -0.000, -0.352, 0.000, 1.000, 0.000, 0.352, -0.000, 0.936)
            if placeId == 115782629143468 then
                local character = lp.Character or lp.CharacterAdded:Wait()
                character:PivotTo(targetCFrame)
            else
                TeleportService:Teleport(115782629143468, lp)
            end
        end
    })
    Tab:CreateButton({
        Name = "Auto-Get Clock",
        Callback = function()
            local character = lp.Character or lp.CharacterAdded:Wait()
            local HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            if not HumanoidRootPart then return end
            local tpdata = (queue_on_teleport or queueonteleport)
            if tpdata then
                pcall(function()
                    tpdata((GlobalTPData or '') .. ' for i=1,2 do for i,v in ipairs(workspace:GetDescendants()) do if v.ClassName == "ClickDetector" then fireclickdetector(v) end end task.wait(2.5) end while task.wait() do game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:PivotTo(CFrame.new(26.34,4,-1.84)) end')
                end)
            end
            task.wait(.5)
            for i = 1, 100 do
                task.wait(0.1)
                if workspace:FindFirstChild("Buildings") and workspace.Buildings:FindFirstChild("wizard twoer") and workspace.Buildings["wizard twoer"]:FindFirstChild("Cone") then
                    HumanoidRootPart:PivotTo(workspace.Buildings["wizard twoer"].Cone.CFrame * CFrame.new(0,15,0))
                end
            end
        end
    })
    Tab:CreateButton({
        Name = "Auto-Get Metaverse",
        Callback = function()
            local p = game:GetService("Players").LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            local q = queue_on_teleport or queueonteleport
            if q then
                q([[
                    local p = game:GetService("Players").LocalPlayer
                    local c = p.Character or p.CharacterAdded:Wait()
                    local h = c:WaitForChild("HumanoidRootPart")
                    local pf = (game.UserInputService.TouchEnabled and not game.UserInputService.MouseEnabled) and "Mobile" or "PC"
                    task.wait(2)
                    fireclickdetector(workspace.Kitchen.Fridge.HitBox.ClickDetector)
                    fireclickdetector(workspace.Kitchen.Fridge.GrantAward.ClickDetector)
                    task.wait(.25)
                    fireclickdetector(workspace.Microwave.HitBox.ClickDetector)
                    task.wait(10)
                    fireclickdetector(workspace.Microwave.HitBox.ClickDetector)
                    task.wait(1)
                    fireclickdetector(workspace.Microwave.Brewzucki.ClickDetector)
                    repeat task.wait() until p.Backpack:FindFirstChild("Brewzucki")
                    if p.Backpack:FindFirstChild("Brewzucki") then p.Backpack["Brewzucki"].Parent = c end
                    c["Brewzucki"]:Activate()
                    task.wait(3)
                    if p.Backpack:FindFirstChild("Brewzucki") then p.Backpack["Brewzucki"].Parent = c end
                    repeat task.wait() until c:FindFirstChild("Brewzucki")
                    c["Brewzucki"]:Destroy()
                    task.wait(2)
                    fireclickdetector(workspace.BasementTable.HitBox.ClickDetector)
                    task.wait(15)
                    h.CFrame = workspace.ComputerChair.Seat.CFrame
                    task.wait(5)
                    game:GetService("ReplicatedStorage").Remotes.ComputerState:FireServer("Victory")
                    task.wait(.25)
                    game:GetService("ReplicatedStorage").Remotes.ComputerState:Destroy()
                    if p.PlayerGui:FindFirstChild("RealComputerScreenGui") then p.PlayerGui.RealComputerScreenGui.Enabled = false end
                    c.Humanoid.Sit = false
                    task.wait(1.5)
                    h.CFrame = CFrame.new(-14, 37, 49)
                    task.wait(2)
                    repeat
                        task.wait()
                        if pf == "Mobile" then
                            local sa = p.PlayerGui.DavidShrineQTE.DavidShrineQTE.Mobile.SpawnArea
                            if sa:FindFirstChild("TapLabel") then
                                sa.TapLabel.Size = UDim2.new(10000, 0, 10000, 0)
                                game:GetService("VirtualUser"):CaptureController()
                                game:GetService("VirtualUser"):ClickButton1(Vector2.new())
                            end
                        else
                            local ql = p.PlayerGui.DavidShrineQTE.DavidShrineQTE.PC.QuickTimeLabel
                            if ql.Visible == true then
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, ql.Text, false, game:GetService("VirtualInputManager"))
                                task.wait()
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, ql.Text, false, game:GetService("VirtualInputManager"))
                            end
                        end
                    until p.PlayerGui.DavidShrineQTE.DavidShrineQTE.ScoreLabel.Text == "Score: 150"
                ]])
            end
            task.spawn(function()
                while task.wait() do
                    local b = workspace.Buildings:FindFirstChild("wizard twoer 2")
                    if b and b:FindFirstChild("Model") and b.Model:FindFirstChild("Trigger") then
                        h:PivotTo(b.Model.Trigger.CFrame)
                    end
                end
            end)
        end
    })

elseif placeId == 136005148166028 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Metaverse ID",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Metaverse", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get Metaverse",
        Callback = function()
            local p = game:GetService("Players").LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            local q = queue_on_teleport or queueonteleport
            if q then
                q([[
                    local p = game:GetService("Players").LocalPlayer
                    local c = p.Character or p.CharacterAdded:Wait()
                    local h = c:WaitForChild("HumanoidRootPart")
                    local pf = (game.UserInputService.TouchEnabled and not game.UserInputService.MouseEnabled) and "Mobile" or "PC"
                    task.wait(2)
                    fireclickdetector(workspace.Kitchen.Fridge.HitBox.ClickDetector)
                    fireclickdetector(workspace.Kitchen.Fridge.GrantAward.ClickDetector)
                    task.wait(.25)
                    fireclickdetector(workspace.Microwave.HitBox.ClickDetector)
                    task.wait(10)
                    fireclickdetector(workspace.Microwave.HitBox.ClickDetector)
                    task.wait(1)
                    fireclickdetector(workspace.Microwave.Brewzucki.ClickDetector)
                    repeat task.wait() until p.Backpack:FindFirstChild("Brewzucki")
                    if p.Backpack:FindFirstChild("Brewzucki") then p.Backpack["Brewzucki"].Parent = c end
                    c["Brewzucki"]:Activate()
                    task.wait(3)
                    if p.Backpack:FindFirstChild("Brewzucki") then p.Backpack["Brewzucki"].Parent = c end
                    repeat task.wait() until c:FindFirstChild("Brewzucki")
                    c["Brewzucki"]:Destroy()
                    task.wait(2)
                    fireclickdetector(workspace.BasementTable.HitBox.ClickDetector)
                    task.wait(15)
                    h.CFrame = workspace.ComputerChair.Seat.CFrame
                    task.wait(5)
                    game:GetService("ReplicatedStorage").Remotes.ComputerState:FireServer("Victory")
                    task.wait(.25)
                    game:GetService("ReplicatedStorage").Remotes.ComputerState:Destroy()
                    if p.PlayerGui:FindFirstChild("RealComputerScreenGui") then p.PlayerGui.RealComputerScreenGui.Enabled = false end
                    c.Humanoid.Sit = false
                    task.wait(1.5)
                    h.CFrame = CFrame.new(-14, 37, 49)
                    task.wait(2)
                    repeat
                        task.wait()
                        if pf == "Mobile" then
                            local sa = p.PlayerGui.DavidShrineQTE.DavidShrineQTE.Mobile.SpawnArea
                            if sa:FindFirstChild("TapLabel") then
                                sa.TapLabel.Size = UDim2.new(10000, 0, 10000, 0)
                                game:GetService("VirtualUser"):CaptureController()
                                game:GetService("VirtualUser"):ClickButton1(Vector2.new())
                            end
                        else
                            local ql = p.PlayerGui.DavidShrineQTE.DavidShrineQTE.PC.QuickTimeLabel
                            if ql.Visible == true then
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, ql.Text, false, game:GetService("VirtualInputManager"))
                                task.wait()
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, ql.Text, false, game:GetService("VirtualInputManager"))
                            end
                        end
                    until p.PlayerGui.DavidShrineQTE.DavidShrineQTE.ScoreLabel.Text == "Score: 150"
                ]])
            end
            task.spawn(function()
                while task.wait() do
                    local b = workspace.Buildings:FindFirstChild("wizard twoer 2")
                    if b and b:FindFirstChild("Model") and b.Model:FindFirstChild("Trigger") then
                        h:PivotTo(b.Model.Trigger.CFrame)
                    end
                end
            end)
        end
    })

elseif placeId == 115782629143468 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - UTG ID",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("UTG", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get UTG",
        Callback = function()
            local targetCFrame = CFrame.new(-1233.92, 9900.16, 704.24, 0.936, -0.000, -0.352, 0.000, 1.000, 0.000, 0.352, -0.000, 0.936)
            local character = lp.Character or lp.CharacterAdded:Wait()
            character:PivotTo(targetCFrame)
        end
    })

elseif placeId == 118650724506449 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Snowroller",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Snowroller", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get snowroller",
        Callback = function()
            local character = lp.Character or lp.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            hrp.CFrame = CFrame.new(59.134, 44.207, 187.602, -1.000, 0.000, -0.031, 0.000, 1.000, 0.000, 0.031, 0.000, -1.000)
        end
    })

elseif placeId == 79885102123162 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Collector", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get Collector",
        Callback = function()
            task.spawn(function()
                local function touch(part)
                    if part and firetouchinterest then
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            firetouchinterest(hrp, part, 0)
                            task.wait(0.1)
                            firetouchinterest(hrp, part, 1)
                        end
                    end
                end
                local hexaPath = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("obstacle/puzzles")
                    and Workspace.Map["obstacle/puzzles"]:FindFirstChild("CastleIsland")
                    and Workspace.Map["obstacle/puzzles"].CastleIsland:FindFirstChild("Hexa_Path")
                if hexaPath then
                    for _, v in ipairs(hexaPath:GetChildren()) do
                        if v and v:IsA("BasePart") then v.Size = Vector3.new(100, 1, 100) end
                    end
                end
                repeat
                    task.wait(0.2)
                    local gloveLocation = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("GloveLocation")
                    if gloveLocation then
                        for _, location in ipairs(gloveLocation:GetChildren()) do
                            if location then
                                local targetPart = location:FindFirstChildWhichIsA("BasePart", true)
                                local char = lp.Character or lp.CharacterAdded:Wait()
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if hrp and targetPart then hrp.CFrame = targetPart.CFrame end
                                task.wait(5)
                                for _, glove in ipairs(location:GetChildren()) do
                                    if glove then
                                        local solved = glove:GetAttribute("Solved")
                                        local visible = glove:GetAttribute("Visible")
                                        local touchTarget = glove:GetChildren()[1]
                                        if (solved ~= nil and solved == false) and visible == false then
                                            glove:SetAttribute("Solved", true)
                                            task.wait(1)
                                            touch(touchTarget)
                                        elseif (solved == nil or solved == true) and visible == true then
                                            touch(touchTarget)
                                        else
                                            continue
                                        end
                                    end
                                end
                            end
                        end
                    end
                until BadgeService:UserHasBadgeAsync(lp.UserId, 1902849233175110)
            end)
        end
    })

elseif placeId == 132277598079047 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Slender", 4483345998)
    Tab:CreateButton({
        Name = "Collection Pages",
        Callback = function()
            task.spawn(function()
                local folder = Workspace:WaitForChild("Pages", 10)
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:FindFirstChild("Part") and obj.Part:FindFirstChildWhichIsA("ProximityPrompt") then
                            local char = lp.Character or lp.CharacterAdded:Wait()
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = obj.Part.CFrame
                                task.wait(0.2)
                                fireproximityprompt(obj.Part.ProximityPrompt)
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end)
        end
    })

elseif placeId == 101113181694564 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Shellbert",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Shellbert", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get conker",
        Callback = function()
            task.spawn(function()
                local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
                if remotes and remotes:FindFirstChild("Dialogue") then
                    remotes.Dialogue.FinishedNPCDialogue:FireServer()
                end
                task.wait(1)
                if Workspace:FindFirstChild("Map") and Workspace.Map.Props.BasketCollection.Basket:FindFirstChild("ClickDetector") then
                    fireclickdetector(Workspace.Map.Props.BasketCollection.Basket.ClickDetector)
                end
                task.wait(7.5)
                while task.wait() do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(36, 4, 1.5)
                        local conker = Workspace:FindFirstChild("Conker")
                        if conker then
                            firetouchinterest(hrp, conker, 0)
                            firetouchinterest(hrp, conker, 1)
                        end
                        pcall(function()
                            ReplicatedStorage.Remotes.tool.use:FireServer("slap")
                            if Workspace:FindFirstChild("NPCs") then
                                for _, v in ipairs(Workspace.NPCs:GetChildren()) do
                                    if v:FindFirstChild("HumanoidRootPart") then
                                        ReplicatedStorage.Remotes.tool.hit:FireServer("slap", {["Instance"] = v.HumanoidRootPart})
                                    end
                                end
                            end
                        end)
                        pcall(function()
                            if Workspace.Map.CoreAssets.Bowl:FindFirstChild("ProximityPrompt") then
                                fireproximityprompt(Workspace.Map.CoreAssets.Bowl.ProximityPrompt)
                            end
                        end)
                    end
                end
            end)
        end
    })

elseif placeId == 125845699717230 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Doorkeeper",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Doorkeeper", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get doorkeeper",
        Callback = function()
            task.spawn(function()
                while true do
                    for _, prompt in ipairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(prompt) end) end
                    end
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("ClickDetector") then
                            pcall(function() fireclickdetector(obj) end)
                        elseif obj.Name == "Hitbox" and obj:IsA("BasePart") then
                            pcall(function()
                                if firetouchinterest and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                    firetouchinterest(lp.Character.HumanoidRootPart, obj, 0)
                                    firetouchinterest(lp.Character.HumanoidRootPart, obj, 1)
                                end
                            end)
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    })

elseif placeId == 93981091811742 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - Lotus",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("Lotus", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get lotus",
        Callback = function()
            local ws = workspace
            local rs = game:GetService("ReplicatedStorage")
            task.spawn(function()
                pcall(function() fireclickdetector(ws.Lotus1_Red.Lotus.Primary.ClickDetector) end)
                pcall(function() rs.Remotes.Lotus2Complete:FireServer() end)
                pcall(function()
                    fireclickdetector(ws.Lotus4_Pink.Lotus.Primary.ClickDetector)
                    fireclickdetector(ws.Lotus5_White.Lotus.Primary.ClickDetector)
                    if typeof(TouchObject) == "function" then TouchObject(ws.Lotus3_Blue.Detector) end
                end)
                task.wait(0.2)
                pcall(function() rs.Remotes.Minigames.Complete:FireServer() end)
                local blue = ws:WaitForChild("Lotus3_Blue")
                repeat task.wait() until blue:FindFirstChild("Lotus") and blue.Lotus:FindFirstChild("Primary") and blue.Lotus.Primary:FindFirstChild("ClickDetector")
                fireclickdetector(blue.Lotus.Primary.ClickDetector)
            end)
        end
    })

elseif placeId == 77283826005207 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - G-X ID",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    local Tab = Window:CreateTab("G-X", 4483345998)
    Tab:CreateButton({
        Name = "Auto-Get G-X",
        Callback = function()
            local localPlayer = Players.LocalPlayer
            local function touchPart(part)
                local character = localPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and part then
                    character.HumanoidRootPart.CFrame = part.CFrame
                    if firetouchinterest then
                        firetouchinterest(character.HumanoidRootPart, part, 0)
                        task.wait(0.05)
                        firetouchinterest(character.HumanoidRootPart, part, 1)
                    end
                end
            end
            task.spawn(function()
                task.wait(math.random(130, 170) / 10)
                local map = Workspace:WaitForChild("Map", 10)
                if not map then return end
                local lobby = map:WaitForChild("Lobby", 10)
                if not lobby then return end
                for i = 1, 3 do
                    local portal = lobby:FindFirstChild("Portal" + i)
                    local part = portal and portal:FindFirstChild("Part")
                    if part then
                        touchPart(part)
                        local startTime = tick()
                        repeat task.wait() until map:FindFirstChild("Challenge" .. i) or (tick() - startTime > 10)
                        task.wait(math.random(8, 14) / 10)
                        local challenge = map:FindFirstChild("Challenge" .. i)
                        if challenge then
                            local redButton = challenge:FindFirstChild("RedButton")
                            local button = redButton and redButton:FindFirstChild("Button")
                            local detector = button and button:FindFirstChild("ClickDetector")
                            if detector then fireclickdetector(detector) end
                        end
                        startTime = tick()
                        repeat task.wait() until not map:FindFirstChild("Challenge" .. i) or (tick() - startTime > 15)
                    end
                    task.wait(math.random(9, 16) / 10)
                end
                local endPortalParent = lobby:FindFirstChild("EndPortal")
                local endPortalPart = endPortalParent and endPortalParent:FindFirstChild("Portal")
                if endPortalPart then touchPart(endPortalPart) end
            end)
        end
    })

elseif placeId == 13833961666 then
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub - The Eternal Bob",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = false }
    })
    _G.AutoSlapBobBoss = false
    _G.AutoTycoon = false
    _G.SlapBobClone = false
    local GloveSlap = "Tycoon"
    local TabAuto = Window:CreateTab("Auto Scripts", 4483345998)
    TabAuto:CreateToggle({
        Name = "Auto Slap BobBoss",
        CurrentValue = false,
        Flag = "AutoSlapBobBoss",
        Callback = function(Value)
            _G.AutoSlapBobBoss = Value
            if Value then
                task.spawn(function()
                    while _G.AutoSlapBobBoss do
                        pcall(function()
                            local Event = game:GetService("Workspace").bobBoss.DamageEvent
                            Event:FireServer()
                        end)
                        task.wait()
                    end
                end)
            end
        end
    })
    TabAuto:CreateToggle({
        Name = "Auto Click Tycoon",
        CurrentValue = false,
        Flag = "AutoTycoon",
        Callback = function(Value)
            _G.AutoTycoon = Value
            if Value then
                task.spawn(function()
                    while _G.AutoTycoon do
                        pcall(function()
                            for _, v in pairs(workspace:GetChildren()) do
                                if string.find(v.Name, "Tycoon") and v:FindFirstChild("Click") then
                                    local cd = v.Click:FindFirstChildWhichIsA("ClickDetector")
                                    if cd then fireclickdetector(cd, 0) fireclickdetector(cd, 1) end
                                end
                            end
                        end)
                        task.wait()
                    end
                end)
            end
        end
    })
    TabAuto:CreateToggle({
        Name = "Slap Bob Clone",
        CurrentValue = false,
        Flag = "SlapBobClone",
        Callback = function(Value)
            _G.SlapBobClone = Value
            if Value then
                task.spawn(function()
                    while _G.SlapBobClone do
                        pcall(function()
                            if game.Workspace:FindFirstChild("BobClone") then
                                for _, v in pairs(workspace:GetChildren()) do
                                    if v.Name == "BobClone" then
                                        local hrp = v:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            if GloveSlap == "Killstreak" then game:GetService("ReplicatedStorage").KSHit:FireServer(hrp)
                                            elseif GloveSlap == "Reaper" then game:GetService("ReplicatedStorage").ReaperHit:FireServer(hrp)
                                            elseif GloveSlap == "God's Hand" then game:GetService("ReplicatedStorage").Godshand:FireServer(hrp)
                                            elseif GloveSlap == "Tycoon" then game:GetService("ReplicatedStorage").GeneralHit:FireServer(hrp)
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(0.7)
                    end
                end)
            end
        end
    })
    TabAuto:CreateDropdown({
        Name = "Glove for Slap Bob Clone",
        Options = {"Tycoon", "Killstreak", "Reaper", "God's Hand"},
        CurrentOption = {"Tycoon"},
        MultipleOptions = false,
        Flag = "GloveSlapDropdown",
        Callback = function(Selected)
            GloveSlap = Selected[1] or Selected
        end
    })
    local TabTp = Window:CreateTab("Teleport", 4483345998)
    local TeleportLocations = {
        {Name = "Arena",          CF = CFrame.new(0,    5,  0)},
        {Name = "Lobby",          CF = CFrame.new(0,    5,  100)},
        {Name = "Hunter Room",    CF = CFrame.new(100,  5,  0)},
        {Name = "Brazil",         CF = CFrame.new(-100, 5,  0)},
        {Name = "Island Slapple", CF = CFrame.new(0,    5, -100)},
        {Name = "Plate",          CF = CFrame.new(200,  5,  0)},
    }
    for _, loc in ipairs(TeleportLocations) do
        local locCF = loc.CF
        TabTp:CreateButton({
            Name = loc.Name,
            Callback = function()
                local char = lp.Character or lp.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = locCF end
            end
        })
    end

else
    Window = Rayfield:CreateWindow({
        Name = "Femboy Hub",
        LoadingTitle = "Femboy Hub",
        LoadingSubtitle = "by silentabsolutedayn",
        ConfigurationSaving = { Enabled = true, FolderName = "FemboyHubConfig", FileName = "Config" }
    })

    local currentJob = game.JobId
    local req = (syn and syn.request) or (http and http.request) or http_request or request

    local function hop()
        if not req then return TeleportService:Teleport(placeId, lp) end
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
        local res = req({Url = url, Method = "GET"})
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            if data and data.data then
                for _, server in pairs(data.data) do
                    if server.id ~= currentJob and server.playing < server.maxPlayers then
                        local success = pcall(function()
                            TeleportService:TeleportToPlaceInstance(placeId, server.id, lp)
                        end)
                        if success then return end
                    end
                end
            end
        end
        TeleportService:Teleport(placeId, lp)
    end

    local Tab1 = Window:CreateTab("Slap Battles Badges", 4483345998)

    Tab1:CreateButton({
        Name = "Auto-Get Alchemist",
        Callback = function()
            runAutoGetAlchemist()
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get sand",
        Callback = function()
            runAutoGetSand()
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get camera (Nothing is required)",
        Callback = function()
            runAutoGetCamera()
        end
    })

    Tab1:CreateButton({ Name = "Auto-Get G-X", Callback = function() TeleportService:Teleport(77283826005207) end })
    Tab1:CreateButton({ Name = "Auto-Get Counter + Elude", Callback = function() TeleportService:Teleport(11828384869, lp) end })
    Tab1:CreateButton({ Name = "Auto-Get penguin", Callback = function() TeleportService:Teleport(113228834069218) end })

    Tab1:CreateButton({
        Name = "Auto-Get mouse (request el gato)",
        Callback = function()
            pcall(function()
                local equip = debug.getupvalues(require(game.ReplicatedStorage.BACKEND.Lib.Network).fireServer)[3]("SelectGlove")
                equip:FireServer("el gato")
                task.wait(0.5)
                fireclickdetector(workspace.Arena.Cheese.ClickDetector)
            end)
        end
    })

    Tab1:CreateButton({
        Name = "[REDACTED] ( Requires 5000 Slaps)",
        Callback = function()
            task.spawn(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                if character:FindFirstChild("entered") then return end
                for i = 1, 10 do
                    local pocketDim = workspace:FindFirstChild("PocketDimension")
                    local doors = pocketDim and pocketDim:FindFirstChild("Doors")
                    local door = doors and doors:FindFirstChild(tostring(i))
                    if door then
                        firetouchinterest(character.HumanoidRootPart, door, 0)
                        firetouchinterest(character.HumanoidRootPart, door, 1)
                    end
                    task.wait(1)
                    if humanoid.Health ~= 0 then
                        humanoid.Health = 0
                        break
                    else
                        task.wait(3)
                        character = player.Character or player.CharacterAdded:Wait()
                        humanoid = character:WaitForChild("Humanoid")
                        character:WaitForChild("HumanoidRootPart")
                    end
                end
            end)
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get Link",
        Callback = function()
            pcall(function()
                local equip = debug.getupvalues(require(game.ReplicatedStorage.BACKEND.Lib.Network).fireServer)[3]("SelectGlove")
                equip:FireServer("Error")
            end)
        end
    })

    Tab1:CreateButton({ Name = "Auto-Get bind", Callback = function() TeleportService:Teleport(74169485398268) end })
    Tab1:CreateButton({ Name = "Auto-Get suction", Callback = function() runSuctionCode() end })

    Tab1:CreateButton({
        Name = "Auto-Get lag",
        Callback = function()
            pcall(function()
                if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("celestial") then
                    ReplicatedStorage.Events.celestial:FireServer("air_time_guy")
                end
            end)
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get the schlob",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    local LocalPlayer = lp
                    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    local Humanoid = Character:WaitForChild("Humanoid")
                    local equip = debug.getupvalues(require(ReplicatedStorage.BACKEND.Lib.Network).fireServer)[3]("SelectGlove")
                    local function getLatestCloud()
                        local latest = nil
                        for _, v in pairs(Workspace:GetChildren()) do
                            if v.Name:find("_Cloud") and v:FindFirstChild("VehicleSeat") then latest = v end
                        end
                        return latest
                    end
                    HumanoidRootPart:PivotTo(CFrame.new(243, -16, 0))
                    task.wait(0.3)
                    equip:FireServer("Cloud")
                    task.wait(0.2)
                    ReplicatedStorage.CloudAbility:FireServer()
                    task.wait(0.3)
                    HumanoidRootPart:PivotTo(CFrame.new(243.14, -15.72, -8.10, 1, 0, -0.021, 0, 1, 0, 0.021, 0, 1))
                    task.wait(0.2)
                    equip:FireServer("fish")
                    task.wait(0.3)
                    HumanoidRootPart:PivotTo(CFrame.new(120, 360, -3))
                    local cloudModel = nil
                    local seat = nil
                    for i = 1, 20 do
                        local cloud = getLatestCloud()
                        if cloud and cloud:FindFirstChild("VehicleSeat") then
                            cloudModel = cloud
                            seat = cloud.VehicleSeat
                            break
                        end
                        task.wait(0.1)
                    end
                    if seat then
                        repeat
                            HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                            seat:Sit(Humanoid)
                            task.wait(0.1)
                        until Humanoid.Sit == true
                    end
                    task.wait(0.8)
                    local targetCloudCFrame = CFrame.new(196.48, 147.59, 88.80, 0.234, 0.000, 0.972, -0.000, 1.000, 0.000, -0.972, -0.000, 0.234)
                    if cloudModel and cloudModel.PrimaryPart then cloudModel:PivotTo(targetCloudCFrame) end
                    task.wait(1.5)
                    Humanoid.Sit = false
                    task.wait(0.1)
                    ReplicatedStorage.GeneralAbility:FireServer()
                    task.wait(0.7)
                    local plate = Workspace:WaitForChild("Arena"):WaitForChild("Plate")
                    for i = 1, 400 do
                        HumanoidRootPart.CFrame = plate.CFrame * CFrame.new(0, 1.5, 0)
                        task.wait(0.005)
                    end
                    Humanoid.Health = 0
                end)
            end)
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get Conker",
        Callback = function()
            local s = [[
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hrp = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
ReplicatedStorage.Remotes.Dialogue.FinishedNPCDialogue:FireServer()
task.wait(1)
fireclickdetector(workspace.Map.Props.BasketCollection.Basket.ClickDetector)
task.wait(7.5)
while task.wait() do
    hrp.CFrame = CFrame.new(36, 4, 1.5)
    if workspace:FindFirstChild("Conker") then
        firetouchinterest(hrp, workspace.Conker, 0)
        firetouchinterest(hrp, workspace.Conker, 1)
    end
    ReplicatedStorage.Remotes.tool.use:FireServer("slap")
    for i, v in ipairs(workspace.NPCs:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") then
            ReplicatedStorage.Remotes.tool.hit:FireServer("slap", {["Instance"] = v.HumanoidRootPart})
        end
    end
    fireproximityprompt(workspace.Map.CoreAssets.Bowl.ProximityPrompt)
end
]]
            local qtp = queue_on_teleport or queueonteleport
            if game.PlaceId == 101113181694564 then
                loadstring(s)()
            else
                if qtp then 
                    pcall(function() qtp(s) end)
                end
                TeleportService:Teleport(101113181694564, lp)
            end
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get debug",
        Callback = function()
            task.spawn(function()
                repeat task.wait() until game:IsLoaded()
                local char = lp.Character or lp.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                hrp.CFrame = CFrame.new(-17948.535156, 59.828022, 3600.984863)
                task.wait(0.5)
                local room = workspace:FindFirstChild("Debug Room")
                if room then
                    local btns = room.Keypad.Buttons
                    local function press(btn)
                        if btn and btn:FindFirstChild("ClickDetector") then
                            fireclickdetector(btn.ClickDetector)
                            task.wait(0.1)
                        end
                    end
                    press(btns[tostring(room.DuckTable.DuckTable.Duckies.Value)])
                    press(btns[room.AdminGloves.GlovesCode.SurfaceGui.AdminNumber.Text])
                    press(btns[room.Maze.MazePrize.SurfaceGui.MazeNumber.Text])
                    press(btns["7"])
                    press(btns.Enter)
                end
            end)
        end
    })

    Tab1:CreateButton({ Name = "Plate", Callback = function() TeleportService:Teleport(106620300132058, lp) end })

    Tab1:CreateButton({
        Name = "Brazil Badge",
        Callback = function()
            local char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(-1119.05, 309.54, -5.09, 0.039, -0.000, 0.999, -0.000, 1.000, 0.000, -0.999, -0.000, 0.039)
            end
        end
    })

    Tab1:CreateButton({ Name = "Collector (Teleport)", Callback = function() TeleportService:Teleport(79885102123162, lp) end })
    Tab1:CreateButton({ Name = "Auto UTG", Callback = function() TeleportService:Teleport(115782629143468, lp) end })

    Tab1:CreateButton({
        Name = "Auto-Get relude",
        Callback = function()
            local character = lp.Character or lp.CharacterAdded:Wait()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(17942.72, -130.16, -3558.06, 0.998, -0.000, -0.057, 0.000, 1.000, -0.000, 0.057, 0.000, 0.998)
            end
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get hunter",
        Callback = function()
            local character = lp.Character or lp.CharacterAdded:Wait()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(17942.72, -130.16, -3558.06, 0.998, -0.000, -0.057, 0.000, 1.000, -0.000, 0.057, 0.000, 0.998)
            end
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get avatar+relude",
        Callback = function()
            local character = lp.Character or lp.CharacterAdded:Wait()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(17942.72, -130.16, -3558.06, 0.998, -0.000, -0.057, 0.000, 1.000, -0.000, 0.057, 0.000, 0.998)
            end
        end
    })

    Tab1:CreateButton({
        Name = "Auto-Get avatar+hunters",
        Callback = function()
            local character = lp.Character or lp.CharacterAdded:Wait()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(17942.72, -130.16, -3558.06, 0.998, -0.000, -0.057, 0.000, 1.000, -0.000, 0.057, 0.000, 0.998)
            end
        end
    })

    Tab1:CreateButton({
        Name = "Auto Slender",
        Callback = function()
            task.spawn(function()
                if placeId == 6403373529 or placeId == 9015014224 then
                    local function gethrp()
                        local c = lp.Character or lp.CharacterAdded:Wait()
                        return c:WaitForChild("HumanoidRootPart", 5)
                    end
                    local function equipGlove(glove)
                        local stats = lp:FindFirstChild("leaderstats")
                        if stats and stats:FindFirstChild("Glove") and stats.Glove.Value ~= glove then
                            if lp.Character and not lp.Character:FindFirstChild("entered") then
                                local g = Workspace.Lobby:FindFirstChild(glove)
                                if g and g:FindFirstChild("ClickDetector") then
                                    fireclickdetector(g.ClickDetector)
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                    local function reset()
                        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                            lp.Character.Humanoid.Health = 0
                        end
                        lp.CharacterAdded:Wait()
                        task.wait(1)
                    end
                    equipGlove("Balloony")
                    local root = gethrp()
                    if root then root.CFrame = CFrame.new(-1210.02, 331.92, 3.47, 0.018, 0, 1, 0, 1, 0, -1, 0, 0.018) end
                    local tape = Workspace:WaitForChild("TapeRecorder", 10)
                    if tape and tape:FindFirstChild("Front") then
                        root = gethrp()
                        if root then root.CFrame = tape.Front.CFrame * CFrame.new(0, 0, -1) end
                        task.wait(0.2)
                        if tape.Front:FindFirstChild("ProximityPrompt") then fireproximityprompt(tape.Front.ProximityPrompt) end
                        task.wait(0.15)
                        local code = ""
                        local rec = true
                        local sfx = tape.Front:FindFirstChild("DigitsSFX")
                        while rec do
                            task.wait()
                            if sfx then
                                for i = 0, 9 do
                                    local d = tostring(i)
                                    local snd = sfx:FindFirstChild(d)
                                    if snd and snd.Playing then
                                        code = code .. d
                                        task.wait(1)
                                        break
                                    end
                                end
                            end
                            if tape.Front.ProximityPrompt.Enabled then rec = false end
                        end
                        reset()
                        equipGlove("Pocket")
                        root = gethrp()
                        if root then
                            root.CFrame = CFrame.new(-1210.02, 331.92, 3.47, 0.018, 0, 1, 0, 1, 0, -1, 0, 0.018)
                            task.wait(0.5)
                            root.CFrame = CFrame.new(123.28, 255.30, 1.05, 0.998, 0, -0.055, 0, 1, 0, 0.055, 0, 0.998)
                            task.wait(0.5)
                            root.CFrame = CFrame.new(17944.88, -130.16, -3492.70, -0.998, 0, -0.070, 0, 1, 0, 0.070, 0, -0.998)
                            task.wait(0.5)
                        end
                        local rem = ReplicatedStorage:FindFirstChild("GeneralAbility")
                        if rem and root then rem:FireServer(root.CFrame) end
                        local pocket = nil
                        local t = tick() + 10
                        repeat
                            task.wait(0.2)
                            for _, v in ipairs(Workspace:GetChildren()) do
                                if v:IsA("Model") and string.find(v.Name, "'s Pocket") then
                                    if v:FindFirstChildWhichIsA("ProximityPrompt", true) then pocket = v break end
                                end
                            end
                        until pocket or tick() > t
                        if pocket then
                            local prompt = pocket:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then fireproximityprompt(prompt) end
                        end
                    end
                end
            end)
        end
    })
end
