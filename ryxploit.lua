local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local function notifyAndPlaySound(title, content)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 5,
        Image = 4483362460
    })
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6897623656"
    sound.Volume = 1
    sound.PlayOnRemove = true
    sound.Parent = game.CoreGui
    sound:Destroy()
end

local function playTickSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9055474333"
    sound.Volume = 0.6
    sound.Parent = game.CoreGui
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local Window = Rayfield:CreateWindow({
    Name = "Maple Hub",
    Icon = 0,
    LoadingTitle = "Maple Hub",
    LoadingSubtitle = "Destroy Euphoria.",
    Theme = "AmberGlow",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RyXploitHub",
        FileName = "RyXploit_Config"
    },
    Discord = {
        Enabled = true,
        Invite = "yourdiscordcode",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Maple Hub",
        Subtitle = "Key System",
        Note = "Get the key at https://workink.net/20ny/nspl4kl9",
        FileName = "RyXploitKey",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/vzqjWt4j"}
    }
})

local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local PlayerTab = Window:CreateTab("Player", "user")
PlayerTab:CreateDivider()

-- Fly
local flyToggle = false
local flyConn
PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        flyToggle = state
        local plr = players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        if flyToggle then
            notifyAndPlaySound("Fly", "Fly enabled!")

            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.P = 9e4
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Name = "FlyGyro"
            bodyGyro.Parent = hrp

            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVel.Name = "FlyVel"
            bodyVel.Parent = hrp

            flyConn = runService.RenderStepped:Connect(function()
                if not flyToggle then return end
                local cam = workspace.CurrentCamera
                local moveVec = Vector3.new()
                if uis:IsKeyDown(Enum.KeyCode.W) then moveVec += cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveVec -= cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveVec -= cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveVec += cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then moveVec += cam.CFrame.UpVector end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec -= cam.CFrame.UpVector end

                if moveVec.Magnitude > 0 then
                    bodyVel.Velocity = moveVec.Unit * 50
                else
                    bodyVel.Velocity = Vector3.new(0, 0, 0)
                end
                bodyGyro.CFrame = cam.CFrame
            end)
        else
            notifyAndPlaySound("Fly", "Fly disabled!")
            local flyParts = { hrp:FindFirstChild("FlyGyro"), hrp:FindFirstChild("FlyVel") }
            for _, v in ipairs(flyParts) do if v then v:Destroy() end end
            if flyConn then flyConn:Disconnect() flyConn = nil end
        end
        playTickSound()
    end,
})

-- Noclip
local noclipToggle = false
local noclipConn
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(state)
        local plr = players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        noclipToggle = state

        if noclipToggle then
            notifyAndPlaySound("Noclip", "Noclip enabled!")
            noclipConn = runService.Stepped:Connect(function()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            notifyAndPlaySound("Noclip", "Noclip disabled!")
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        playTickSound()
    end,
})

-- Teleport to player
local function getPlayerList()
    local list = {}
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= players.LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

PlayerTab:CreateDropdown({
    Name = "Teleport To Player",
    Options = getPlayerList(),
    CurrentOption = nil,
    Multiple = false,
    FlagChangedCallback = function(selected)
        local target = players:FindFirstChild(selected)
        local localChar = players.LocalPlayer.Character or players.LocalPlayer.CharacterAdded:Wait()

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            localChar:WaitForChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            notifyAndPlaySound("Teleport", "Teleported to "..selected)
        else
            notifyAndPlaySound("Teleport", "Failed to teleport to "..selected)
        end
        playTickSound()
    end
})

-- Walk Speed
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {1, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(value)
        local char = players.LocalPlayer.Character or players.LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = value end
        playTickSound()
    end
})

-- Jump Power
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Callback = function(value)
        local char = players.LocalPlayer.Character or players.LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = value end
        playTickSound()
    end
})

-- Miscs Tab with icon "tool"
local MiscsTab = Window:CreateTab("Miscs", "wrench")

MiscsTab:CreateButton({
    Name = "Get Cords",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        if char and char.PrimaryPart then
            print("My Position:", char.PrimaryPart.Position)
            notifyAndPlaySound("Notice", "Position printed to console.")
        end
    end,
})

MiscsTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        notifyAndPlaySound("Misc", "Rejoining...")
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
})

MiscsTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        notifyAndPlaySound("Misc", "Server hopping...")
        local HttpService = game:GetService("HttpService")
        local PlaceID = game.PlaceId
        local Cursor = ""
        local found = false
        while not found do
            local success, response = pcall(function()
                return game:HttpGetAsync("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100&cursor="..Cursor)
            end)
            if not success then break end
            local data = HttpService:JSONDecode(response)
            for _, server in pairs(data.data) do
                if server.playing < server.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, server.id)
                    found = true
                    break
                end
            end
            Cursor = data.nextPageCursor
            if not Cursor then break end
        end
        if not found then
            notifyAndPlaySound("Misc", "No suitable server found!")
        end
    end,
})

MiscsTab:CreateButton({
    Name = "Leave Game",
    Callback = function()
        notifyAndPlaySound("Misc", "Leaving game...")
        game:Shutdown()
    end,
})

MiscsTab:CreateButton({
    Name = "Big Guy FE",
    Callback = function()
        notifyAndPlaySound("Misc", "You need a certain items equipped, this script also has reanimation.")
        getgenv().OxideSettings = {
            Refit = true,
            noclip = false,
            FlingEnabled = false,
            ToolFling = false,
            AntiFling = false,
            Legacy = false,
            Scale = 4,
            ClientHats = {},
            CustomHats = true,
            CH = {
                Torso = {
                    Name= "Accessory (Torso)",
                    TextureId = "83269599235494",
                    Orientation= CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))
                },
                RightArm = {
                    Name= "Accessory (BIGGEST RIGHT ARMAccessory)",
                    TextureId = "117484156735788", 
                    Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
                },
                LeftArm = {
                    Name= "Accessory (BIGGEST LEFT ARMAccessory)",
                    TextureId = "117484156735788", 
                    Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
                },
                RightLeg = {
                    Name= "Accessory (RLeg)",
                    TextureId = "83269599235494", 
                    Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
                },
                LeftLeg = {
                    Name= "Accessory (LLeg)",
                    TextureId = "83269599235494", 
                    Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
                },
                Head = {
                    Name = "Accessory (BIG HEAD!!)",
                    Orientation = CFrame.new(),
                }
            }
        }
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nitro-GT/Oxide/refs/heads/main/LoadstringPerma"))()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nitro-GT/OxideReanim/refs/heads/main/KrystalDance3"))()
    end,
})

-- Client Sided Tab with icon "cpu"
local ClientTab = Window:CreateTab("Client Sided", "cpu")
ClientTab:CreateLabel("THESE SCRIPTS ARE CLIENT SIDED!")

ClientTab:CreateButton({
    Name = "Remove Fog",
    Callback = function()
        notifyAndPlaySound("Client Script", "Removed fog!")
        game.Lighting.FogEnd = 100000
        game.Lighting.FogStart = 0
    end,
})

ClientTab:CreateButton({
    Name = "Remove Shadows",
    Callback = function()
        notifyAndPlaySound("Client Script", "Removed shadows!")
        game.Lighting.GlobalShadows = false
    end,
})

ClientTab:CreateToggle({
    Name = "Toggle Full Bright",
    CurrentValue = false,
    Callback = function(State)
        if State then
            notifyAndPlaySound("Client Script", "Full bright enabled!")
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").Brightness = 3
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
        else
            notifyAndPlaySound("Client Script", "Full bright disabled!")
            game:GetService("Lighting").ClockTime = 12
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").FogEnd = 1000
            game:GetService("Lighting").GlobalShadows = true
        end
    end,
})

ClientTab:CreateButton({
    Name = "Reset Lighting to Default",
    Callback = function()
        notifyAndPlaySound("Client Script", "Lighting reset to default!")
        local Lighting = game:GetService("Lighting")
        Lighting.ClockTime = 12
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
    end,
})

notifyAndPlaySound("RyXploit", "Script Hub loaded!")

local InfoTab = Window:CreateTab("Info", "book")
InfoTab:CreateLabel("Computer Time: " .. os.date("%X"))
InfoTab:CreateDivider()

local RobloxVersion = "N/A"
pcall(function()
    RobloxVersion = tostring(game:GetService("RunService"):IsStudio() and "Studio" or game:GetService("RobloxGui").RobloxVersionLabel.Text or "N/A")
end)
InfoTab:CreateLabel("Roblox Version: " .. RobloxVersion)

local ServerId = tostring(game.JobId or "Unknown")
InfoTab:CreateLabel("Server ID: " .. ServerId)

local GameName = "Unknown"
local success, info = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
end)
if success and info then
    GameName = info.Name or "Unknown"
end
local GameId = tostring(game.PlaceId)
InfoTab:CreateLabel("Game Name: " .. GameName)
InfoTab:CreateLabel("Game ID: " .. GameId)

InfoTab:CreateDivider()

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local fpsLabel = InfoTab:CreateLabel("FPS: Calculating...")
local pingLabel = InfoTab:CreateLabel("PING: Calculating...")

local lastUpdate = 0
local updateInterval = 1

RunService.Heartbeat:Connect(function(dt)
    lastUpdate = lastUpdate + dt
    if lastUpdate >= updateInterval then
        lastUpdate = 0
        local fps = math.floor(1/dt)
        fpsLabel:Set("FPS: " .. fps)

        local ping = 0
        local success, result = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if success and result then
            ping = math.floor(result)
        else
            if LocalPlayer then
                ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            end
        end
        pingLabel:Set("PING: " .. ping .. " ms")
    end
end)

local MapleHospitalTab = Window:CreateTab("Maple Hospital", "hospital")
ClientTab:CreateLabel("Maple Hospital uses an Anti Cheat. Bypass is not known at this time. Current known exploits banned are Fly.")

MapleHospitalTab:CreateButton({
    Name = "Teleport to Hidden 1",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        if char and char.PrimaryPart then
            local emergencyRoomCFrame = CFrame.new(-277, 26, 202)
            char:SetPrimaryPartCFrame(emergencyRoomCFrame)
            notifyAndPlaySound("Maple Hospital", "Teleported to Hidden 1")
        else
            notifyAndPlaySound("Maple Hospital", "Failed to teleport!")
        end
    end,
})

MapleHospitalTab:CreateButton({
    Name = "Teleport to Hidden 2",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        if char and char.PrimaryPart then
            local lobbyCFrame = CFrame.new(-19, -471, -673)
            char:SetPrimaryPartCFrame(lobbyCFrame)
            notifyAndPlaySound("Maple Hospital", "Teleported to Hidden 2")
        else
            notifyAndPlaySound("Maple Hospital", "Failed to teleport!")
        end
    end,
})

MapleHospitalTab:CreateButton({
    Name = "Teleport to Hidden 3",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        if char and char.PrimaryPart then
            local lobbyCFrame = CFrame.new(-136, 22, 9)
            char:SetPrimaryPartCFrame(lobbyCFrame)
            notifyAndPlaySound("Maple Hospital", "Teleported to Hidden 3")
        else
            notifyAndPlaySound("Maple Hospital", "Failed to teleport!")
        end
    end,
})

MapleHospitalTab:CreateButton({
    Name = "Teleport to Hidden 4",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        if char and char.PrimaryPart then
            local lobbyCFrame = CFrame.new(-192, 4, 92)
            char:SetPrimaryPartCFrame(lobbyCFrame)
            notifyAndPlaySound("Maple Hospital", "Teleported to Hidden 4")
        else
            notifyAndPlaySound("Maple Hospital", "Failed to teleport!")
        end
    end,
})

local Section = MapleHospitalTab:CreateSection("Scripts")

local Paragraph = MapleHospitalTab:CreateParagraph({
    Title = "Scripts are Here!",
    Content = "These scripts sometimes require extra instructions (For Example, putting on a shit load of nails or etc.)"
})

local equipSpamConnection
local equipSpeed = 0.1

MapleHospitalTab:CreateButton({
    Name = "Enable Auto Janitor",
    Callback = function()
        print("[Auto Janitor] Button clicked")
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RunService = game:GetService("RunService")
        local lp = Players.LocalPlayer

        local char = lp.Character or lp.CharacterAdded:Wait()
        local humanoid = char:WaitForChild("Humanoid")
        local rootPart = char:WaitForChild("HumanoidRootPart")

        humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            RunService.Heartbeat:Wait()
            humanoid.Sit = false
        end)

        ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")
            :WaitForChild("RolesService"):WaitForChild("__comm__"):WaitForChild("RE")
            :WaitForChild("SetRole"):FireServer("Janitor")

        local MopTool = lp.Backpack:FindFirstChild("Mop")
        if not MopTool then
            print("[Auto Janitor] Requesting Mop")
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Equip")
                :FireServer(ReplicatedStorage:WaitForChild("Tools"):WaitForChild("Mop"))
            repeat task.wait() until lp.Backpack:FindFirstChild("Mop")
        end

        MopTool = lp.Backpack:WaitForChild("Mop")
        local Bottom = MopTool:WaitForChild("Bottom")
        local Garbage = workspace:WaitForChild("Garbage")

        workspace.FallenPartsDestroyHeight = 0/0

        humanoid:UnequipTools()
        MopTool.Parent = char

        local currentlycleaning = false
        local function clean(Spill)
            if not Spill:IsA("BasePart") then return end
            if currentlycleaning then return end

            currentlycleaning = true
            local originalCFrame = rootPart.CFrame
            print("[Auto Janitor] Cleaning:", Spill.Name)

            repeat
                MopTool.Parent = char
                rootPart.CFrame = Spill.CFrame + Vector3.new(0, 2, 0)
                firetouchinterest(Bottom, Spill, 0)
                MopTool:Activate()
                firetouchinterest(Bottom, Spill, 1)
                RunService.Heartbeat:Wait()
            until not Spill or not Spill:IsDescendantOf(workspace)

            rootPart.CFrame = originalCFrame
            currentlycleaning = false
        end

        for _, v in pairs(Garbage:GetChildren()) do
            clean(v)
        end
        Garbage.ChildAdded:Connect(clean)
        print("[Auto Janitor] Running and waiting for new spills...")
    end,
})

MapleHospitalTab:CreateSlider({
    Name = "Equip Spam Speed",
    Range = {0.00001, 1},
    Increment = 0.00001,
    Suffix = "sec",
    CurrentValue = 0.1,
    Callback = function(value)
        equipSpeed = value
        playTickSound()
    end
})

MapleHospitalTab:CreateToggle({
    Name = "Spam Equip All Tools",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer

        if state then
            notifyAndPlaySound("Maple Hospital", "Equip a bunch of nails in the Avatar editor, they are located under tops. Server required layered clothing to be enabled.")
            equipSpamConnection = task.spawn(function()
                while true do
                    for _, tool in pairs(plr.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool.Parent = plr.Character
                            task.wait(equipSpeed)
                            tool.Parent = plr.Backpack
                            task.wait(equipSpeed)
                        end
                    end
                    task.wait(equipSpeed)
                end
            end)
        else
            if equipSpamConnection then
                task.cancel(equipSpamConnection)
                equipSpamConnection = nil
                notifyAndPlaySound("Maple Hospital", "Tool spam disabled.")
            end
        end
        playTickSound()
    end,
})

local UniversalTab = Window:CreateTab("Universal", "globe")

UniversalTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        notifyAndPlaySound("Universal", "Infinite Yield loaded!")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
})

UniversalTab:CreateButton({
    Name = "Dex Explorer",
    Callback = function()
        notifyAndPlaySound("Universal", "Dex Explorer loaded!")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
    end,
})