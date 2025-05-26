local success, lib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
end)

if not success or not lib then
    warn("Failed to load UI library. Using fallback.")
    return
end

local win = lib:Window("Snare", Color3.fromRGB(255, 50, 50), Enum.KeyCode.RightControl)

-- Services
local players = game:GetService("Players")
local player = players.LocalPlayer
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local collectionService = game:GetService("CollectionService")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")

-- Safe remote detection with error handling
local function getRemote(name, alternatives)
    local remote = replicatedStorage:FindFirstChild(name)
    if remote then return remote end
    
    for _, alt in ipairs(alternatives or {}) do
        remote = replicatedStorage:FindFirstChild(alt)
        if remote then return remote end
    end
    
    return nil
end

local remotes = {
    gunRemote = getRemote("GunEvent", {"ShootEvent", "WeaponEvent"}),
    arrestRemote = getRemote("Arrest", {"ArrestPlayer", "CuffEvent"}),
    taseRemote = getRemote("TasePlayer", {"TaseEvent", "StunEvent"}),
    vehicleRemote = getRemote("VehicleEvent", {"DriveEvent", "CarEvent"}),
    robberyRemote = getRemote("RobberyEvent", {"RobEvent", "StoreEvent"}),
    notificationRemote = getRemote("Notifications", {"Notify", "Alert"})
}

-- Character handling with safety checks
local character, humanoid, rootPart

local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(setupCharacter)
setupCharacter()

-- Error handling wrapper
local function safeCall(func, errorMessage)
    local success, err = pcall(func)
    if not success then
        warn(errorMessage or "Error in function: " .. tostring(err))
        return false
    end
    return true
end

-- Helper function for section creation with fallbacks
local function createSection(tab, sectionName)
    if tab.CreateSection then
        return tab:CreateSection(sectionName)
    elseif tab.AddSection then
        return tab:AddSection(sectionName)
    elseif tab.Section then
        return tab:Section(sectionName)
    else
        warn("Failed to create section '"..sectionName.."' - no valid method found")
        return nil
    end
end

-- Tab 1: Combat
local combatTab = win:Tab("Combat")
local combatSection = createSection(combatTab, "Weapon Modifications")

if combatSection then
    combatSection:Toggle("Silent Aim", false, function(state)
        _G.silentAim = state
    end)

    combatSection:Toggle("Automatic Guns", false, function(state)
        _G.automaticGuns = state
    end)

    combatSection:Toggle("No Spread", false, function(state)
        _G.noSpread = state
    end)

    combatSection:Toggle("No Bullet Drop", false, function(state)
        _G.noBulletDrop = state
    end)

    combatSection:Toggle("No Knockback", false, function(state)
        _G.noKnockback = state
    end)

    combatSection:Toggle("Rapid Fire", false, function(state)
        _G.rapidFire = state
    end)

    combatSection:Toggle("Kill Aura", false, function(state)
        _G.killAura = state
    end)

    combatSection:Toggle("Instant Hit", false, function(state)
        _G.instantHit = state
    end)

    combatSection:Toggle("Shoot Through Walls", false, function(state)
        _G.wallPenetration = state
    end)

    combatSection:Toggle("Shoot Through Forcefields", false, function(state)
        _G.forcefieldPenetration = state
    end)

    combatSection:Toggle("One Hit Bandits", false, function(state)
        _G.oneHitBandits = state
    end)

    combatSection:Toggle("One Hit Vehicles", false, function(state)
        _G.oneHitVehicles = state
    end)

    combatSection:Toggle("Always Headshot", false, function(state)
        _G.alwaysHeadshot = state
    end)
end

-- Tab 2: Target
local targetTab = win:Tab("Target")
local targetSection = createSection(targetTab, "Target Selection")

if targetSection then
    targetSection:Toggle("Target Police", false, function(state)
        _G.targetPolice = state
    end)

    targetSection:Toggle("Target Criminals", false, function(state)
        _G.targetCriminals = state
    end)

    targetSection:Toggle("Target Bandits", false, function(state)
        _G.targetBandits = state
    end)

    targetSection:Toggle("Target CEO", false, function(state)
        _G.targetCEO = state
    end)
end

-- Tab 3: Visuals
local visualsTab = win:Tab("Visuals")
local espSection = createSection(visualsTab, "ESP Settings")

if espSection then
    espSection:Toggle("ESP", false, function(state)
        _G.espEnabled = state
        if state then
            createESP()
        else
            clearESP()
        end
    end)

    espSection:Dropdown("ESP Style", {"Boxes", "Filled", "Names", "Distances", "Weapons", "Bounties", "Health Bars"}, function(option)
        _G.espStyle = option
        if _G.espEnabled then
            clearESP()
            createESP()
        end
    end)
end

-- Tab 4: Aura
local auraTab = win:Tab("Aura")
local auraSection = createSection(auraTab, "Aura Settings")

if auraSection then
    auraSection:Toggle("Auto Equip Handcuffs", false, function(state)
        _G.autoHandcuffs = state
    end)

    auraSection:Toggle("Eject Player", false, function(state)
        _G.ejectAura = state
    end)

    auraSection:Slider("Eject Range", 1, 15, 10, function(value)
        _G.ejectRange = value
    end)

    auraSection:Toggle("Takeout Nearby Vehicle", false, function(state)
        _G.vehicleTakeout = state
    end)

    auraSection:Slider("Vehicle Range", 1, 600, 300, function(value)
        _G.vehicleRange = value
    end)
end

-- Tab 5: Player
local playerTab = win:Tab("Player")
local movementSection = createSection(playerTab, "Movement")
local combatSection = createSection(playerTab, "Combat")
local utilitySection = createSection(playerTab, "Utility")

if movementSection then
    movementSection:Toggle("CFrame Speed", false, function(state)
        _G.cframeSpeed = state
    end)

    movementSection:Slider("Speed Value", 1, 20, 10, function(value)
        _G.speedValue = value
    end)

    movementSection:Toggle("Inf Jump", false, function(state)
        _G.infJump = state
    end)
end

if combatSection then
    combatSection:Toggle("No Ragdoll", false, function(state)
        _G.noRagdoll = state
        if state then
            preventRagdoll()
        end
    end)

    combatSection:Toggle("No Fall Damage", false, function(state)
        _G.noFallDamage = state
        if state then
            preventFallDamage()
        end
    end)

    combatSection:Toggle("No Skydive", false, function(state)
        _G.noSkydive = state
    end)

    combatSection:Toggle("Anti Tase", false, function(state)
        _G.antiTase = state
    end)
end

if utilitySection then
    utilitySection:Toggle("No E Wait", false, function(state)
        _G.noEWait = state
    end)

    utilitySection:Toggle("Always Keycard", false, function(state)
        _G.alwaysKeycard = state
    end)

    utilitySection:Toggle("Always Sprint", false, function(state)
        _G.alwaysSprint = state
        if state then
            humanoid.WalkSpeed = 20
        else
            humanoid.WalkSpeed = 16
        end
    end)

    utilitySection:Toggle("Always Juiced", false, function(state)
        _G.alwaysJuiced = state
    end)

    utilitySection:Toggle("Equip While Crawling", false, function(state)
        _G.equipWhileCrawling = state
    end)

    utilitySection:Toggle("No Punch Cooldown", false, function(state)
        _G.noPunchCooldown = state
    end)

    utilitySection:Toggle("No Crawl Cooldown", false, function(state)
        _G.noCrawlCooldown = state
    end)

    utilitySection:Toggle("No Roll Cooldown", false, function(state)
        _G.noRollCooldown = state
    end)

    utilitySection:Toggle("Disable Military Turrets", false, function(state)
        _G.disableMilitaryTurrets = state
        if state then
            disableTurrets("Military")
        end
    end)

    utilitySection:Toggle("Disable Apartment Turrets", false, function(state)
        _G.disableApartmentTurrets = state
        if state then
            disableTurrets("Apartment")
        end
    end)

    utilitySection:Toggle("Freeze Max Prison Lasers", false, function(state)
        _G.freezePrisonLasers = state
        if state then
            freezeLasers()
        end
    end)
end

-- Tab 6: Vehicles
local vehicleTab = win:Tab("Vehicles")
local vehicleSection = createSection(vehicleTab, "Vehicle Modifications")

if vehicleSection then
    vehicleSection:Toggle("Vfly", false, function(state)
        _G.vfly = state
        if state then
            setupVfly()
        end
    end)

    vehicleSection:Toggle("Infinite Nitro", false, function(state)
        _G.infiniteNitro = state
    end)

    vehicleSection:Toggle("Drive on Water", false, function(state)
        _G.driveOnWater = state
    end)

    vehicleSection:Toggle("Anti Tire Pop", false, function(state)
        _G.antiTirePop = state
    end)

    vehicleSection:Toggle("Anti Spike Pop", false, function(state)
        _G.antiSpikePop = state
    end)

    vehicleSection:Slider("Engine Speed", 1, 50, 20, function(value)
        _G.engineSpeed = value
        safeCall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.SeatPart then
                local vehicle = player.Character.Humanoid.SeatPart.Parent
                if vehicle:FindFirstChild("EngineSpeed") then
                    vehicle.EngineSpeed.Value = value
                end
            end
        end, "Failed to set engine speed")
    end)

    vehicleSection:Slider("Turn Speed", 1, 50, 20, function(value)
        _G.turnSpeed = value
        safeCall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.SeatPart then
                local vehicle = player.Character.Humanoid.SeatPart.Parent
                if vehicle:FindFirstChild("TurnSpeed") then
                    vehicle.TurnSpeed.Value = value
                end
            end
        end, "Failed to set turn speed")
    end)

    vehicleSection:Slider("Brake Power", 1, 200, 100, function(value)
        _G.brakePower = value
        safeCall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.SeatPart then
                local vehicle = player.Character.Humanoid.SeatPart.Parent
                if vehicle:FindFirstChild("BrakePower") then
                    vehicle.BrakePower.Value = value
                end
            end
        end, "Failed to set brake power")
    end)

    vehicleSection:Slider("Suspension Height", 1, 100, 50, function(value)
        _G.suspensionHeight = value
        safeCall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.SeatPart then
                local vehicle = player.Character.Humanoid.SeatPart.Parent
                for _, part in pairs(vehicle:GetDescendants()) do
                    if part:IsA("VehicleSeat") or part:IsA("BasePart") then
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5, value/100, 0)
                    end
                end
            end
        end, "Failed to set suspension height")
    end)
end

-- Tab 7: Robberies
local robberyTab = win:Tab("Robberies")
local robberySection = createSection(robberyTab, "Robbery Modifications")

if robberySection then
    robberySection:Toggle("No Laser Damage", false, function(state)
        _G.noLaserDamage = state
        if state then
            disableLaserDamage()
        end
    end)

    robberySection:Toggle("Auto Breach Vault", false, function(state)
        _G.autoBreachVault = state
    end)

    robberySection:Toggle("Auto Place Dynamite", false, function(state)
        _G.autoPlaceDynamite = state
    end)

    robberySection:Toggle("Auto Grab Nearby Jewels", false, function(state)
        _G.autoGrabJewels = state
    end)

    robberySection:Toggle("Auto Solve Puzzles", false, function(state)
        _G.autoSolvePuzzles = state
    end)

    robberySection:Toggle("No Impact Damage", false, function(state)
        _G.noImpactDamage = state
        if state then
            preventImpactDamage()
        end
    end)

    robberySection:Toggle("Auto Solve Keypad", false, function(state)
        _G.autoSolveKeypad = state
    end)

    robberySection:Toggle("Auto Collect Nearby Cash", false, function(state)
        _G.autoCollectCash = state
    end)

    robberySection:Toggle("Auto Hack Nearby Computers", false, function(state)
        _G.autoHackComputers = state
    end)

    robberySection:Toggle("Disable Turrets", false, function(state)
        _G.disableTurrets = state
        if state then
            disableTurrets("All")
        end
    end)

    robberySection:Toggle("Disable Bandits", false, function(state)
        _G.disableBandits = state
        if state then
            disableBandits()
        end
    end)

    robberySection:Toggle("No Piston Damage", false, function(state)
        _G.noPistonDamage = state
        if state then
            disablePistonDamage()
        end
    end)

    robberySection:Toggle("No Darts", false, function(state)
        _G.noDarts = state
        if state then
            disableDarts()
        end
    end)

    robberySection:Toggle("No Spike Damage", false, function(state)
        _G.noSpikeDamage = state
        if state then
            disableSpikeDamage()
        end
    end)

    robberySection:Toggle("No Bridge Collapse", false, function(state)
        _G.noBridgeCollapse = state
        if state then
            preventBridgeCollapse()
        end
    end)

    robberySection:Toggle("Auto Duck Planks", false, function(state)
        _G.autoDuckPlanks = state
    end)

    robberySection:Toggle("Auto Grab Nearby Crates", false, function(state)
        _G.autoGrabCrates = state
    end)

    robberySection:Toggle("No Trap Detection", false, function(state)
        _G.noTrapDetection = state
        if state then
            disableTrapDetection()
        end
    end)

    robberySection:Toggle("Disable Guards", false, function(state)
        _G.disableGuards = state
        if state then
            disableGuards()
        end
    end)

    robberySection:Toggle("Disable CEO", false, function(state)
        _G.disableCEO = state
        if state then
            disableCEO()
        end
    end)

    robberySection:Toggle("Auto Kill Nearby Guards", false, function(state)
        _G.autoKillGuards = state
    end)
end

-- Tab 8: Inventory
local inventoryTab = win:Tab("Inventory")
local inventorySection = createSection(inventoryTab, "Inventory")

if inventorySection then
    inventorySection:Button("Open Gun UI", function()
        safeCall(function()
            if replicatedStorage:FindFirstChild("OpenGunUI") then
                replicatedStorage.OpenGunUI:FireServer()
            end
        end, "Failed to open gun UI")
    end)

    inventorySection:Button("Give Owned Weapons", function()
        safeCall(function()
            if replicatedStorage:FindFirstChild("GiveOwnedWeapons") then
                replicatedStorage.GiveOwnedWeapons:FireServer()
            end
        end, "Failed to give weapons")
    end)
end

-- Tab 9: Exploits
local exploitsTab = win:Tab("Exploits")
local exploitsSection = exploitsTab:CreateSection("Exploits") or exploitsTab:AddSection("Exploits") or exploitsTab:Section("Exploits")

exploitsSection:Toggle("Open Nearby Doors", false, function(state)
    _G.openDoors = state
    if state then
        openNearbyDoors()
    end
end)

exploitsSection:Toggle("Notify Store Open", false, function(state)
    _G.notifyStoreOpen = state
    if state then
        setupStoreNotifications()
    end
end)

-- Tab 10: Credits
local creditsTab = win:Tab("Credits")
local creditsSection = creditsTab:Section("Credits")

-- Custom UI for credits
local profileFrame = Instance.new("Frame")
profileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
profileFrame.BorderSizePixel = 0
profileFrame.Size = UDim2.new(0, 150, 0, 150)
profileFrame.Position = UDim2.new(0.5, -75, 0.2, 0)

local profileImage = Instance.new("ImageLabel")
profileImage.Image = "rbxassetid://YOUR_IMAGE_ID" -- Replace with your image ID
profileImage.BackgroundTransparency = 1
profileImage.Size = UDim2.new(1, 0, 1, 0)
profileImage.Parent = profileFrame

local devLabel = Instance.new("TextLabel")
devLabel.Text = "Developer & UI, Ree"
devLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
devLabel.BackgroundTransparency = 1
devLabel.Size = UDim2.new(1, 0, 0, 20)
devLabel.Position = UDim2.new(0, 0, 1.1, 0)
devLabel.Parent = profileFrame

creditsSection:Button("Join Discord", function()
    setclipboard("https://discord.com/invite/v2QAwMZHHG")
    safeCall(function()
        if remotes.notificationRemote then
            remotes.notificationRemote:FireServer("Snare Discord Invite has been copied")
        end
    end, "Failed to send notification")
end)

-- Feature Implementations
local function initializeFeatures()
    -- Silent Aim Implementation
    local function silentAimHook()
        if not remotes.gunRemote then return end
        
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if _G.silentAim and self == remotes.gunRemote and (method == "FireServer" or method == "InvokeServer") then
                -- Find closest player to crosshair based on targeting preferences
                local closestPlayer, closestDistance = nil, math.huge
                local camera = workspace.CurrentCamera
                local mousePos = player:GetMouse().Hit.Position
                
                for _, v in pairs(players:GetPlayers()) do
                    if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                        -- Check targeting preferences
                        local shouldTarget = false
                        local team = v.Team and v.Team.Name or ""
                        
                        if _G.targetPolice and team:lower():find("police") then
                            shouldTarget = true
                        elseif _G.targetCriminals and team:lower():find("criminal") then
                            shouldTarget = true
                        elseif _G.targetBandits and v.Name:lower():find("bandit") then
                            shouldTarget = true
                        elseif _G.targetCEO and v.Name:lower():find("ceo") then
                            shouldTarget = true
                        end
                        
                        if shouldTarget then
                            local headPos = v.Character.Head.Position
                            local screenPos = camera:WorldToScreenPoint(headPos)
                            local mousePos = player:GetMouse().X, player:GetMouse().Y
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                            
                            if distance < closestDistance then
                                closestPlayer = v
                                closestDistance = distance
                            end
                        end
                    end
                end
                
                if closestPlayer then
                    -- Modify args to hit closest player's head
                    args[1] = closestPlayer.Character.Head.Position
                    if _G.alwaysHeadshot then
                        args[3] = closestPlayer.Character.Head
                    end
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
    end

    -- Infinite Jump
    uis.JumpRequest:Connect(function()
        if _G.infJump and character and humanoid then
            humanoid:ChangeState("Jumping")
        end
    end)
    
    -- CFrame Speed
    runService.Heartbeat:Connect(function()
        if _G.cframeSpeed and character and rootPart then
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                rootPart.CFrame = rootPart.CFrame + (moveDir * _G.speedValue * 0.1)
            end
        end
    end)
    
    -- Vehicle Modifications
    runService.Heartbeat:Connect(function()
        if _G.vfly and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.SeatPart then
                local vehicle = humanoid.SeatPart.Parent
                if not vehicle:FindFirstChild("BodyGyro") then
                    local gyro = Instance.new("BodyGyro")
                    gyro.P = 10000
                    gyro.D = 500
                    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    gyro.Parent = vehicle
                end
                
                local gyro = vehicle:FindFirstChild("BodyGyro")
                if gyro then
                    if uis:IsKeyDown(Enum.KeyCode.Space) then
                        gyro.CFrame = CFrame.new(vehicle.Position, vehicle.Position + Vector3.new(0, 1, 0))
                    elseif uis:IsKeyDown(Enum.KeyCode.LeftControl) then
                        gyro.CFrame = CFrame.new(vehicle.Position, vehicle.Position + Vector3.new(0, -1, 0))
                    end
                end
            end
        end
    end)
    
    -- Infinite Nitro
    runService.Heartbeat:Connect(function()
        if _G.infiniteNitro and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.SeatPart then
                local vehicle = humanoid.SeatPart.Parent
                if vehicle:FindFirstChild("Nitro") then
                    vehicle.Nitro.Value = 100
                end
            end
        end
    end)
    
    -- Drive on Water
    runService.Heartbeat:Connect(function()
        if _G.driveOnWater and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.SeatPart then
                local vehicle = humanoid.SeatPart.Parent
                for _, part in pairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    
    -- Robbery Features
    runService.Heartbeat:Connect(function()
        if _G.autoBreachVault then
            for _, part in pairs(workspace:GetDescendants()) do
                if part.Name:lower():find("vault") and part:FindFirstChild("ClickDetector") then
                    fireclickdetector(part.ClickDetector)
                end
            end
        end
        
        if _G.autoGrabJewels then
            for _, part in pairs(workspace:GetDescendants()) do
                if part.Name:lower():find("jewel") and part:FindFirstChild("ClickDetector") then
                    fireclickdetector(part.ClickDetector)
                end
            end
        end
        
        if _G.autoCollectCash then
            for _, part in pairs(workspace:GetDescendants()) do
                if part.Name:lower():find("cash") and part:FindFirstChild("ClickDetector") then
                    fireclickdetector(part.ClickDetector)
                end
            end
        end
    end)
    
    -- ESP Implementation
    local espObjects = {}
    
    local function createESP()
        for _, player in pairs(players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local char = player.Character
                if char:FindFirstChild("HumanoidRootPart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = player.Name .. "_ESP"
                    highlight.Adornee = char
                    highlight.Parent = char
                    
                    if _G.espStyle == "Boxes" then
                        highlight.FillTransparency = 1
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    elseif _G.espStyle == "Filled" then
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                    end
                    
                    table.insert(espObjects, highlight)
                    
                    if _G.espStyle == "Names" or _G.espStyle == "Distances" or _G.espStyle == "Weapons" or _G.espStyle == "Bounties" or _G.espStyle == "Health Bars" then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = player.Name .. "_ESPText"
                        billboard.Adornee = char.Head
                        billboard.Size = UDim2.new(0, 100, 0, 100)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = char.Head
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextSize = 14
                        textLabel.Font = Enum.Font.SourceSansBold
                        textLabel.Parent = billboard
                        
                        table.insert(espObjects, billboard)
                        
                        runService.Heartbeat:Connect(function()
                            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                                local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                local text = ""
                                
                                if _G.espStyle == "Names" then
                                    text = player.Name
                                elseif _G.espStyle == "Distances" then
                                    text = string.format("%.1f studs", distance)
                                elseif _G.espStyle == "Weapons" then
                                    -- Check for weapons
                                    text = "No Weapon"
                                    for _, tool in pairs(player.Character:GetChildren()) do
                                        if tool:IsA("Tool") then
                                            text = tool.Name
                                            break
                                        end
                                    end
                                elseif _G.espStyle == "Bounties" then
                                    -- Check for bounty (Jailbreak specific)
                                    text = "Bounty: $0"
                                    if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Wanted") then
                                        text = "Bounty: $" .. player.leaderstats.Wanted.Value
                                    end
                                elseif _G.espStyle == "Health Bars" then
                                    text = string.format("HP: %d/%d", char.Humanoid.Health, char.Humanoid.MaxHealth)
                                end
                                
                                textLabel.Text = text
                            end
                        end)
                    end
                end
            end
        end
    end
    
    local function clearESP()
        for _, obj in pairs(espObjects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        espObjects = {}
    end
    
    players.PlayerAdded:Connect(function(player)
        if _G.espEnabled then
            player.CharacterAdded:Connect(function(char)
                wait(1) -- Wait for character to fully load
                if _G.espEnabled then
                    createESP()
                end
            end)
        end
    end)
    
    -- No Ragdoll
    local function preventRagdoll()
        if character:FindFirstChild("Ragdoll") then
            character.Ragdoll:Destroy()
        end
        
        character.ChildAdded:Connect(function(child)
            if child.Name == "Ragdoll" then
                child:Destroy()
            end
        end)
    end
    
    -- No Fall Damage
    local function preventFallDamage()
        if character:FindFirstChild("FallDamage") then
            character.FallDamage:Destroy()
        end
        
        character.ChildAdded:Connect(function(child)
            if child.Name == "FallDamage" then
                child:Destroy()
            end
        end)
    end
    
    -- No Impact Damage
    local function preventImpactDamage()
        if character:FindFirstChild("ImpactDamage") then
            character.ImpactDamage:Destroy()
        end
        
        character.ChildAdded:Connect(function(child)
            if child.Name == "ImpactDamage" then
                child:Destroy()
            end
        end)
    end
    
    -- Disable Turrets
    local function disableTurrets(type)
        for _, turret in pairs(workspace:GetDescendants()) do
            if turret:IsA("Model") and turret.Name:lower():find("turret") then
                if type == "All" or (type == "Military" and turret:FindFirstChild("Military")) or (type == "Apartment" and turret:FindFirstChild("Apartment")) then
                    if turret:FindFirstChild("Shoot") then
                        turret.Shoot:Destroy()
                    end
                    if turret:FindFirstChild("Aim") then
                        turret.Aim:Destroy()
                    end
                end
            end
        end
    end
    
    -- Freeze Prison Lasers
    local function freezeLasers()
        for _, laser in pairs(workspace:GetDescendants()) do
            if laser.Name:lower():find("laser") and laser:IsA("BasePart") then
                laser.Anchored = true
                laser.CanCollide = false
                if laser:FindFirstChild("TouchInterest") then
                    laser.TouchInterest:Destroy()
                end
            end
        end
    end
    
    -- No Laser Damage
    local function disableLaserDamage()
        for _, laser in pairs(workspace:GetDescendants()) do
            if laser.Name:lower():find("laser") and laser:IsA("BasePart") then
                if laser:FindFirstChild("TouchInterest") then
                    laser.TouchInterest:Destroy()
                end
            end
        end
    end
    
    -- Disable Bandits
    local function disableBandits()
        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc.Name:lower():find("bandit") then
                if npc:FindFirstChild("Humanoid") then
                    npc.Humanoid:Destroy()
                end
            end
        end
    end
    
    -- Disable Piston Damage
    local function disablePistonDamage()
        for _, piston in pairs(workspace:GetDescendants()) do
            if piston.Name:lower():find("piston") and piston:IsA("BasePart") then
                if piston:FindFirstChild("TouchInterest") then
                    piston.TouchInterest:Destroy()
                end
            end
        end
    end
    
    -- Disable Darts
    local function disableDarts()
        for _, dart in pairs(workspace:GetDescendants()) do
            if dart.Name:lower():find("dart") and dart:IsA("BasePart") then
                if dart:FindFirstChild("TouchInterest") then
                    dart.TouchInterest:Destroy()
                end
            end
        end
    end
    
    -- Disable Spike Damage
    local function disableSpikeDamage()
        for _, spike in pairs(workspace:GetDescendants()) do
            if spike.Name:lower():find("spike") and spike:IsA("BasePart") then
                if spike:FindFirstChild("TouchInterest") then
                    spike.TouchInterest:Destroy()
                end
            end
        end
    end
    
    -- Prevent Bridge Collapse
    local function preventBridgeCollapse()
        for _, bridge in pairs(workspace:GetDescendants()) do
            if bridge.Name:lower():find("bridge") and bridge:IsA("BasePart") then
                bridge.Anchored = true
                if bridge:FindFirstChild("Break") then
                    bridge.Break:Destroy()
                end
            end
        end
    end
    
    -- Disable Trap Detection
    local function disableTrapDetection()
        for _, trap in pairs(workspace:GetDescendants()) do
            if trap:IsA("Model") and trap.Name:lower():find("trap") then
                if trap:FindFirstChild("Detect") then
                    trap.Detect:Destroy()
                end
            end
        end
    end
    
    -- Disable Guards
    local function disableGuards()
        for _, guard in pairs(workspace:GetDescendants()) do
            if guard:IsA("Model") and (guard.Name:lower():find("guard") or guard.Name:lower():find("security")) then
                if guard:FindFirstChild("Humanoid") then
                    guard.Humanoid:Destroy()
                end
            end
        end
    end
    
    -- Disable CEO
    local function disableCEO()
        for _, ceo in pairs(workspace:GetDescendants()) do
            if ceo:IsA("Model") and ceo.Name:lower():find("ceo") then
                if ceo:FindFirstChild("Humanoid") then
                    ceo.Humanoid:Destroy()
                end
            end
        end
    end
    
    -- Open Nearby Doors
    local function openNearbyDoors()
        for _, door in pairs(workspace:GetDescendants()) do
            if door:IsA("Model") and door.Name:lower():find("door") and door:FindFirstChild("ClickDetector") then
                fireclickdetector(door.ClickDetector)
            end
        end
    end
    
    -- Setup Vfly
    local function setupVfly()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.SeatPart then
                local vehicle = humanoid.SeatPart.Parent
                if not vehicle:FindFirstChild("BodyGyro") then
                    local gyro = Instance.new("BodyGyro")
                    gyro.P = 10000
                    gyro.D = 500
                    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    gyro.Parent = vehicle
                end
            end
        end
    end
    
    -- Store Notifications
    local function setupStoreNotifications()
        -- Listen for store openings
        for _, store in pairs(workspace:GetDescendants()) do
            if store:IsA("Model") and (store.Name:lower():find("store") or store.Name:lower():find("bank") or store.Name:lower():find("jewelry") or store.Name:lower():find("museum") or store.Name:lower():find("casino")) then
                if store:FindFirstChild("Open") then
                    store.Open.Changed:Connect(function()
                        if store.Open.Value and remotes.notificationRemote then
                            remotes.notificationRemote:FireServer("Snare: " .. store.Name .. " has opened!")
                        end
                    end)
                end
            end
        end
    end
    
    -- Initialize features
    silentAimHook()
    
    if _G.noRagdoll then preventRagdoll() end
    if _G.noFallDamage then preventFallDamage() end
    if _G.disableMilitaryTurrets then disableTurrets("Military") end
    if _G.disableApartmentTurrets then disableTurrets("Apartment") end
    if _G.freezePrisonLasers then freezeLasers() end
    if _G.noLaserDamage then disableLaserDamage() end
    if _G.disableBandits then disableBandits() end
    if _G.noPistonDamage then disablePistonDamage() end
    if _G.noDarts then disableDarts() end
    if _G.noSpikeDamage then disableSpikeDamage() end
    if _G.noBridgeCollapse then preventBridgeCollapse() end
    if _G.noTrapDetection then disableTrapDetection() end
    if _G.disableGuards then disableGuards() end
    if _G.disableCEO then disableCEO() end
    if _G.openDoors then openNearbyDoors() end
    if _G.vfly then setupVfly() end
    if _G.espEnabled then createESP() end
    if _G.notifyStoreOpen then setupStoreNotifications() end
end

-- Initialize all features
initializeFeatures()
