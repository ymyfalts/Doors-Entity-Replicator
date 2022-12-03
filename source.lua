--#region Setup
if getgenv then
    if getgenv().DGEM_LOADED==true then
        repeat task.wait() until true==false
    end
    getgenv().DGEM_LOADED=true
end
local entities={
    AllEntities={"All","Ambush","Eyes","Glitch","Grundge","Halt","Hide","None","Random","Rush","Screech","Seek","Shadow","Smiler","Timothy","Trashbag","Trollface"},
    DeveloperEntities={"Trollface", "None"},
    CustomEntities={"Grundge","Smiler","Trashbag", "None"},
    RegularEntities={"All", "Ambush", "Eyes", "Glitch", "Halt", "Hide", "Random", "None", "Rush", "Screech", "Seek", "Shadow", "Timothy"}
}
for _, tb in pairs(entities) do table.sort(tb) end
if not isfile("interactedWithDiscordPrompt.txt") then
    writefile("interactedWithDiscordPrompt.txt",".")
    local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
    Inviter.Prompt({
        name = "Zepsyy's Server",
        invite = "https://discord.gg/zepsyy",
    })
end
--#endregion

--#region Window
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
	Name = "Doors Entity Replicator | "..(identifyexecutor and identifyexecutor() or syn and "Synapse X" or "Unknown"),
	LoadingTitle = "Loading Doors Entity Spawner",
	LoadingSubtitle = "Made by Zepsyy and Spongus",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = "L.N.K v1" -- ZEPSYY I TOLD YOU ITS NOT GONNA BE NAMED LINK  
	},
    Discord = {
        Enabled = false,
        Invite = "zepsyy", -- The Discord invite code, do not include discord.gg/
        RememberJoins = false -- Set this to false to make them join the discord every time they load it up
    },
    KeySystem = false
})
--#endregion
--#region Connections & Variables
--//MAIN VARIABLES\\--
local Debris = game:GetService("Debris")


local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local RootPart = Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")

local allLimbs = {}

for i,v in pairs(Character:GetChildren()) do
    if v:IsA("BasePart") then
        table.insert(allLimbs, v)
    end
end

--//MAIN USABLE FUNCTIONS\\--

function removeDebris(obj, Duration)
    Debris:AddItem(obj, Duration)
end

-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
}
local Connections = {}

-- Functions

local function playSound(soundId, source, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://".. soundId
    sound.PlayOnRemove = true
    
    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Parent" and i ~= "PlayOnRemove" then
            sound[i] = v
        end
    end

    sound.Parent = source
    sound:Destroy()
end

local function drag(model, dest, speed)
    local reached = false

    Connections.Drag = RS.Stepped:Connect(function(_, step)
        if model.Parent then
            local seekPos = model.PrimaryPart.Position
            local newDest = Vector3.new(dest.X, seekPos.Y, dest.Z)
            local diff = newDest - seekPos
    
            if diff.Magnitude > 0.1 then
                model:SetPrimaryPartCFrame(CFrame.lookAt(seekPos + diff.Unit * math.min(step * speed, diff.Magnitude - 0.05), newDest))
            else
                Connections.Drag:Disconnect()
                reached = true
            end
        else
            Connections.Drag:Disconnect()
        end
    end)

    repeat task.wait() until reached
end

local function jumpscareSeek()
    Hum.Health = 0
    workspace.Ambience_Seek:Stop()

    local func = getconnections(ReSt.Bricks.Jumpscare.OnClientEvent)[1].Function
    debug.setupvalue(func, 1, false)
    func("Seek")
end

local function connectSeek(room)
    local seekMoving = workspace.SeekMoving
    local seekRig = seekMoving.SeekRig

    -- Intro
    
    seekMoving:SetPrimaryPartCFrame(room.RoomStart.CFrame * CFrame.new(0, 0, -15))
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRaise):Play()

    task.spawn(function()
        task.wait(7)
        workspace.Footsteps_Seek:Play()
    end)

    workspace.Ambience_Seek:Play()
    ModuleScripts.SeekIntro(ModuleScripts.MainGame)
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRun):Play()
    Char:SetPrimaryPartCFrame(room.RoomEnd.CFrame * CFrame.new(0, 0, 20))
    ModuleScripts.MainGame.chase = true
    Hum.WalkSpeed = 22
    
    -- Movement

    task.spawn(function()
        local nodes = {}

        for _, v in next, workspace.CurrentRooms:GetChildren() do
            for i2, v2 in next, v:GetAttributes() do
                if string.find(i2, "Seek") and v2 then
                    nodes[#nodes + 1] = v.RoomEnd
                end
            end
        end

        for _, v in next, nodes do
            if seekMoving.Parent and not seekMoving:GetAttribute("IsDead") then
                drag(seekMoving, v.Position, 15)
            end
        end
    end)

    -- Killing

    task.spawn(function()
        while seekMoving.Parent do
            if (Root.Position - seekMoving.PrimaryPart.Position).Magnitude <= 30 and Hum.Health > 0 and not seekMoving.GetAttribute(seekMoving, "IsDead") then
                Connections.Drag:Disconnect()
                workspace.Footsteps_Seek:Stop()
                ModuleScripts.MainGame.chase = false
                Hum.WalkSpeed = 15
                
                -- Crucifix / death

                if not Char.FindFirstChild(Char, "Crucifix") then
                    jumpscareSeek()
                else
                    seekMoving.Figure.Repent:Play()
                    seekMoving:SetAttribute("IsDead", true)
                    workspace.Ambience_Seek.TimePosition = 92.6

                    task.spawn(function()
                        ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
                        task.wait(0.5)
                        ModuleScripts.MainGame.camShaker:ShakeOnce(5, 25, 4, 4)
                    end)

                    -- Crucifix float

                    local model = Instance.new("Model")
                    model.Name = "Crucifix"
                    local hl = Instance.new("Highlight")
                    local crucifix = Char.Crucifix
                    local fakeCross = crucifix.Handle:Clone()
        
                    fakeCross:FindFirstChild("EffectLight").Enabled = true
        
                    ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
        
                    model.Parent = workspace
                    -- hl.Parent = model
                    -- hl.FillTransparency = 1
                    -- hl.OutlineColor = Color3.fromRGB(75, 177, 255)
                    fakeCross.Anchored = true
                    fakeCross.Parent = model
        
                    crucifix:Destroy()
        
                    for i, v in pairs(fakeCross:GetChildren()) do
                        if v.Name == "E" and v:IsA("BasePart") then
                            v.Transparency = 0
                            v.CanCollide = false
                        end
                        if v:IsA("Motor6D") then
                            v.Name = "Motor6D"
                        end
                    end
        


                    -- Seek death

                    task.wait(4)
                    seekMoving.Figure.Scream:Play()
                    playSound(11464351694, workspace, { Volume = 3 })
                    game.TweenService:Create(seekMoving.PrimaryPart, TweenInfo.new(4), {CFrame = seekMoving.PrimaryPart.CFrame - Vector3.new(0, 10, 0)}):Play()
                    task.wait(4)

                    seekMoving:Destroy()
                    fakeCross.Anchored = false
                    fakeCross.CanCollide = true
                    task.wait(0.5)
                    model:Remove()
                end

                break
            end

            task.wait()
        end
    end)
end

-- Setup

local newIdx; newIdx = hookmetamethod(game, "__newindex", newcclosure(function(t, k, v)
    if k == "WalkSpeed" and not checkcaller() then
        if ModuleScripts.MainGame.chase then
            v = ModuleScripts.MainGame.crouching and 17 or 22
        else
            v = ModuleScripts.MainGame.crouching and 10 or 15
        end
    end
    
    return newIdx(t, k, v)
end))

-- Scripts
 
local roomConnection; roomConnection = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    local trigger = room:WaitForChild("TriggerEventCollision", 1)

    if trigger then
        roomConnection:Disconnect()

        local collision = trigger.Collision:Clone()
        collision.Parent = room
        trigger:Destroy()

        local touchedConnection; touchedConnection = collision.Touched:Connect(function(p)
            if p:IsDescendantOf(Char) then
                touchedConnection:Disconnect()

                connectSeek(room)
            end
        end)
    end
end)
--#endregion
--#region Tabs
local MainTab=Window:CreateTab("Entity Spawning", 4370345144)
local DoorsMods=Window:CreateTab("Doors Modifications", 10722835155)
local ConfigEntities = Window:CreateTab("Configure Entities", 8285095937)
local publicServers = Window:CreateTab("Special Servers", 9692125126)
local Tools=Window:CreateTab("Tools", 29402763) 
local CharacterMods=Window:CreateTab("Character Modifications", 483040244)
local global=Window:CreateTab("Global", 1588352259) 
--#endregion
    
--#region Special Servers
publicServers:CreateSection("Server Identifier")
publicServers:CreateLabel("Current Server Identification: "..game.JobId)
publicServers:CreateButton({
    Name="Copy Server Identification",
    Callback=function()
        (syn and syn.write_clipboard or setclipboard)(game.JobId)
    end
})
publicServers:CreateSection("Features")
publicServers:CreateButton({
    Name="Join Empty Special Server",
    Callback=function()
        game.Players.LocalPlayer:Kick("\nJoining Special Server... Please Wait")
		wait()
		game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
publicServers:CreateButton({
    Name="Free Revive",
    Callback=function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})
publicServers:CreateLabel("WARNING: FREE REVIVING REQUIRES TO BE IN A SPECIAL SERVER WITH COMPANY")
publicServers:CreateSection("Server-Hopping")
publicServers:CreateButton({
    Name="Join Random Special Server",
	Callback = function()
        local tb=game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))))
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, tb.data[math.random(1,#tb.data)].id, game.Players.LocalPlayer)
    end,
})
publicServers:CreateInput({
    Name="Join Specific Player",
    PlaceholderText = game.Players.LocalPlayer.Name,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local tb=game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))))
        for _, server in pairs(tb.data) do
            for _, player in pairs(server.players) do
                if player.name==Text or player.UserId==Text then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                end
            end
        end
    end,
})
publicServers:CreateInput({
    Name="Join Special Server",
    PlaceholderText = "Insert Server Identification",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Text, game.Players.LocalPlayer)
    end,
})
--#endregion
--#region Entity Configuration
local EntitiesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")

_G.ScreechConfig = false
_G.TimothyConfig = false
_G.HaltConfig = false
_G.GlitchConfig = false

_G.HaltModel = 0
_G.TimothyModel = 0
_G.ScreechModel = 0
_G.GlitchModel = 0

local function connectEntity(entitytype, id, entityname)
    if entitytype == "3d" then
        game:GetService("Debris"):AddItem(game:GetService("ReplicatedStorage"):WaitForChild("Entities"):FindFirstChild(entityname), 0)

        local customentity = game:GetObjects("rbxassetid://"..id)[1]
        customentity.Name = entityname
        customentity.Parent = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")

        local isCustom = Instance.new("StringValue")
        isCustom.Name = "isCustom"
        isCustom.Parent = customentity

        
    elseif entitytype == string.lower("2d") then
        error("entity cannot be changed because entity is 2D.")
    end
end

ConfigEntities:CreateSection("3D Entities")

ConfigEntities:CreateParagraph({Title="Warning", Content="This setting is for developers only, if you wish to continue, please join discord.gg/zepsyy for the original entity models to edit."})

ConfigEntities:CreateToggle({
    Name = "Screech Configuration",
	CurrentValue = false,
	Flag = "AddScreechConfig",
	Callback = function(Value)
        _G.ScreechConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.ScreechModel, "Screech")
            else
                connectEntity("3d", "11599277464", "Screech")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "Set Screech Model",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.ScreechModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Glitch Configuration",
	CurrentValue = false,
	Flag = "AddGlitchConfig",
	Callback = function(Value)
        _G.GlitchConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.GlitchModel, "Glitch")
            else
                connectEntity("3d", "11689725604", "Glitch")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "Set Glitch Model",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.GlitchModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Timothy Configuration",
	CurrentValue = false,
	Flag = "AddTimothyConfig",
	Callback = function(Value)
        _G.TimothyConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.TimothyModel, "Spider")
            else
                connectEntity("3d", "11689711982", "Spider")
            end
        end)
	end,
})


ConfigEntities:CreateInput({
	Name = "Set Timothy Model",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.TimothyModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Halt Configuration",
	CurrentValue = false,
	Flag = "AddHaltConfig",
	Callback = function(Value)
        _G.HaltConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.HaltModel, "Shade")
            else
                connectEntity("3d", "11689715035", "Shade")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "Set Halt Model",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.HaltModel = Text
	end,
})

ConfigEntities:CreateSection("2D Entities")
--#endregion
--#region Doors Modifications
--#region UI Mods
DoorsMods:CreateSection("Game UI Modifications")

DoorsMods:CreateInput({
	Name = "Set Knobs Amount",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Knobs.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Knobs:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "Set Revives Amount",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Revives.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Revives:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "Set Boosts Amount",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Boosts.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Boosts:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "Show Bottom Text",
	PlaceholderText = "Your lighter ran out of fuel...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, Text)
	end,
})


DoorsMods:CreateButton({
	Name = "Start Heartbeat Minigame",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.ClutchHeartbeat.OnClientEvent)
	end,
})

DoorsMods:CreateButton({
	Name = "Get All Achievements",
	Callback = function()
        for i,v in pairs(require(game.ReplicatedStorage.Achievements)) do
            spawn(function()
                require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock)(nil, i)
            end)
        end
	end,
})
--#endregion
--#region Modify Rooms
DoorsMods:CreateSection("Modify Rooms")

DoorsMods:CreateColorPicker({
    Name="Set Room Color",
    Color=Color3.fromRGB(89,69,72),
    Flag="RoomColor",
    Callback=function(color)
        local room=workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]

        if color==Color3.fromRGB(89,69,72) then
            room.LightBase.SurfaceLight.Enabled=true
            room.LightBase.SurfaceLight.Color=Color3.fromRGB(89,69,72)
            for _, thing in pairs(room.Assets:GetDescendants()) do
                if thing:FindFirstChild"LightFixture" then
                    thing.LightFixture.Neon.Color=Color3.fromRGB(195, 161, 141)
                    for _, light in pairs(thing.LightFixture:GetChildren()) do
                        if light:IsA("SpotLight") or light:IsA("PointLight") then
                            light.Color=Color3.fromRGB(235, 167, 98)
                        end
                    end
                end
            end
            return
        end

        room.LightBase.SurfaceLight.Enabled=true
        room.LightBase.SurfaceLight.Color=color
        for _, thing in pairs(room.Assets:GetDescendants()) do
            if thing:FindFirstChild"LightFixture" then
                thing.LightFixture.Neon.Color=color
                for _, light in pairs(thing.LightFixture:GetChildren()) do
                    if light:IsA("SpotLight") or light:IsA("PointLight") then
                        light.Color=color
                    end
                end
            end
        end
    end
})

DoorsMods:CreateParagraph({Title="Warning", Content="If you'd like to reset the room's color, leave it as 89,69,72"})

DoorsMods:CreateButton({
	Name = "Spawn Red Room",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "tryp", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 9e307)
        -- Imagine someone actually waits 90000000000000000... seconds for the red room to run out, would be crazy 
	end,
})

DoorsMods:CreateButton({
	Name = "Break Lights",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "breakLights", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 0.416, 60) 
	end,
})

DoorsMods:CreateInput({
	Name = "Flicker Lights",
	PlaceholderText = "time in seconds...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "flickerLights", game.Players.LocalPlayer:GetAttribute("CurrentRoom"), tonumber(Text)) 
	end,
})

DoorsMods:CreateInput({
	Name = "Set Door Text",
	PlaceholderText = "gahaa lolz",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local r=workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]
        r.Door.Sign.Stinker.Text=Text
        r.Door.Sign.Stinker.Highlight.Text=Text
        r.Door.Sign.Stinker.Shadow.Text=Text
	end,    
})
--#endregion
--#region Modify Entities
DoorsMods:CreateSection("Modify Entities")

local EnabledEntities={
    EnabledScreech=false,
    EnabledHalt=false,
    EnabledGlitch=false,
}

DoorsMods:CreateToggle({
    Name = "Ignore Screech",
	CurrentValue = false,
	Flag = "IgnoreScreech",
	Callback = function(Value)
        EnabledEntities.EnabledScreech = Value
	end,
})

DoorsMods:CreateToggle({
    Name = "Ignore Glitch",
	CurrentValue = false,
	Flag = "IgnoreGlitch",
	Callback = function(Value)
        EnabledEntities.EnabledGlitch = Value
	end,
})

DoorsMods:CreateToggle({
    Name = "Ignore Halt",
	CurrentValue = false,
	Flag = "IgnoreHalt",
	Callback = function(Value)
        EnabledEntities.EnabledHalt = Value
	end,
})

workspace.Camera.ChildAdded:Connect(function(c)
    if c.Name == "Screech" then
        wait(0.1)
        if EnabledEntities.EnabledScreech then
            removeDebris(c, 0)
        end
    end

    if c.Name == "Shade" then
        wait(.1)
        if EnabledEntities.EnabledHalt then
            removeDebris(c, 0)
        end
    end
end)

workspace.CurrentRooms.ChildAdded:Connect(function()
    if EnabledEntities.EnabledGlitch then
        local currentRoom=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
        local roomAmt=#workspace.CurrentRooms:GetChildren()
        local lastRoom=game.ReplicatedStorage.GameData.LatestRoom.Value
    
        if roomAmt>=4 and currentRoom<lastRoom-3 then
            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(lastRoom.RoomStart.Position))
        end    
    end
end)
--#endregion
--#region Global Doors Mods

DoorsMods:CreateSection("Global Doors Modifications")

local thanksgivingEnabled=false
DoorsMods:CreateButton({
	Name = "Enable Thanksgiving Update",
	Callback = function()
        if thanksgivingEnabled then
            return Rayfield:Notify({
                Title = "Error",
                Content = "You have already ran this",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
        thanksgivingEnabled=true
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/DOORSthanksgiving"))()
	end,
})
--#endregion
--#endregion
--#region Character Mods
local con
local con2
local isJumping=false
CharacterMods:CreateInput({
    Name="Set Guiding Light",
    PlaceholderText = "message 1~message 2",
	RemoveTextAfterFocusLost = true,
    Callback=function(Text)
        game.Players.LocalPlayer.Character.Humanoid.Health=0
        debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, Text:split"~")
    end
})
CharacterMods:CreateLabel("This input will instantly kill you when used... Be careful with it")

CharacterMods:CreateButton({
    Name="Instant Death",
    Callback=function()
        game.Players.LocalPlayer.Character.Humanoid.Health=0
    end
})
CharacterMods:CreateButton({
    Name="Revive",
    Callback=function()
        game.ReplicatedStorage.Bricks.Revive:FireServer()
    end
})
CharacterMods:CreateParagraph({Title = "Warning", Content = "The revive button requires you to have atleast 1 revive, the special thing about it, is that it can bypass the \"You can only revive in a run once\" message, and other things"})

CharacterMods:CreateToggle({
    Name="Enable Jumping",
    CurrentValue=false,
    Flag="enableJump",
    Callback=function(val)
        if val==true then
            con=game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode==Enum.KeyCode.Space then
                    isJumping=true
                    repeat 
                        task.wait()
                        if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):GetState()==Enum.HumanoidStateType.Freefall then else
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState(3) end
                    until isJumping==false
                end
            end)

            con2=game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode==Enum.KeyCode.Space then
                    isJumping=false
                end
            end)
        else con:Disconnect() con2:Disconnect() end
    end
})

local Speed = 15

local EVC=CharacterMods:CreateToggle({
    Name="Enable Velocity Cheat",
    CurrentValue=false,
    Callback=function() end
})

CharacterMods:CreateSlider({
    Name="Velocity",
    Range={15,100},
    Increment=5,
    Suffix="studs/s",
    CurrentValue=15,
    Flag="speed",
    Callback=function(val)
        for _, child in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if child.ClassName == "Part" then
                child.CustomPhysicalProperties = PhysicalProperties.new(999, 0.3, 0.5)
            end
        end
        Speed = tonumber(val)
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if EVC.CurrentValue==true then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed end
end)
--#endregion
--#region Tools
--#region Vitamins
_G.VitaminsDurability = 0

Tools:CreateButton({
    Name="Obtain Vitamins",
    Callback = function()
        local Vitamins = game:GetObjects("rbxassetid://11685698403")[1]
        local idle = Vitamins.Animations:FindFirstChild("idle")
        local open = Vitamins.Animations:FindFirstChild("open")

        local tweenService = game:GetService("TweenService")

        local sound_open = Vitamins.Handle:FindFirstChild("sound_open")

        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacteAdded:Wait()
        local hum = char:WaitForChild("Humanoid")

        local idleTrack = hum.Animator:LoadAnimation(idle)
        local openTrack = hum.Animator:LoadAnimation(open)

        local Durability = 35
        local InTrans = false
        local Duration = 10

        local xUsed = tonumber(_G.VitaminsDurability)

        local v1 = {};



        function v1.AddDurability()
            InTrans = true
            hum:SetAttribute("SpeedBoost", 15)
            wait(Duration)
            InTrans = false
            hum:SetAttribute("SpeedBoost", 0)
        end




        function v1.SetupVitamins()
            Vitamins.Parent = game.Players.LocalPlayer.Backpack
            Vitamins.Name = "FakeVitamins"

            for slotNum, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if tool.Name == "FakeVitamins" then
                    local slot =game.Players.LocalPlayer.PlayerGui:WaitForChild("MainUI").MainFrame.Hotbar:FindFirstChild(slotNum)
                    -- while task.wait() do
                    --     slot.DurabilityNumber.Text = "x"..xUsed
                    -- end
                    -- slot.DurabilityNumber.Text = "x"..xUsed
                    slot.DurabilityNumber.Visible = true
                    slot.DurabilityNumber.Text = "x"..xUsed

                    Vitamins.Unequipped:Connect(function()
                        slot.DurabilityNumber.Visible = true
                        slot.DurabilityNumber.Text = "x"..xUsed
                    end)

                    Vitamins.Equipped:Connect(function()
                        slot.DurabilityNumber.Visible = true
                    end)

                    Vitamins.Activated:Connect(function()
                        if not InTrans and xUsed > 0 then
                            xUsed = xUsed - 1
                            slot.DurabilityNumber.Visible = true
                            slot.DurabilityNumber.Text = "x"..xUsed
                            openTrack:Play()
                            sound_open:Play()
                    
                            tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2), {FieldOfView = 100}):Play()
                            v1.AddDurability()
                        end
                    end)
                end
            end




            Vitamins.Equipped:Connect(function()
                idleTrack:Play()
            end)


            Vitamins.Unequipped:Connect(function()
                idleTrack:Stop()

            end)
        end

        v1.SetupVitamins()

        function v1.AddLoop()
            while task.wait() do
                if InTrans then
                    wait()
                    print'in trans'
                    hum.WalkSpeed = Durability
                else
                    hum.WalkSpeed = 16
                end
            end
        end

        while task.wait() do
            v1.AddLoop()
        end

        return v1


    end
})

Tools:CreateInput({
	Name = "Vitamin Durability",
	PlaceholderText = "ex: 100",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local durability = tonumber(Text)



        if durability then
            _G.VitaminsDurability = Text
        elseif not durability or durability == '0' then
            Rayfield:Notify({
                Title = "ERROR",
                Content = "Please enter a valid number.",
                Duration = 5,
                Image = 4483362458,
                Actions = {},
            })
        end
	end,    
})
 
Tools:CreateParagraph({Title = "NOTE", Content = "These are fake vitamins but works just as efficient as the actual ones do. So others can't see you holding the item globally. Please do not include decimals or fractions in this written piece meaning that this script will be caused to break and no longer function."})
--#endregion

--#region Skeleton Key
Tools:CreateButton({
    Name="Obtain Skeleton Key",
    Callback=function()
        local uses=5
        local keyTool: Tool=game:GetObjects((getcustomasset or getsynasset)("skellyKey.rbxm"))[1]
        keyTool.Parent=game.Players.LocalPlayer.Backpack
    end
})
--#endregion

--#region Crucifix
Tools:CreateButton({
    Name="Obtain Crucifix",
    Callback=function()
        return Rayfield:Notify({
            Title="Sorry!",
            Content="The crucifix script is disabled in this beta release due to Zepsyy being unable to obfuscate it, we will add it as soon as we can!",
            Duration=1000,
            Image=4483362458,
            Actions={
                normalPerson={
                    Name="take your time",
                    Callback=function() end
                },
                parasite={
                    Name="hurry up idiot",
                    Callback=function() end
                }
            }
        })
    end
})
--#endregion

--#region Candle
Tools:CreateButton({
    Name="Obtain Candle",
    Callback=function()
        local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
        local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()


        local Candle = game:GetObjects("rbxassetid://11630702537")[1]
        Candle.Parent = game.Players.LocalPlayer.Backpack

        local plr = game.Players.LocalPlayer
        local Char = plr.Character or plr.CharacterAdded:Wait()
        local Hum = Char:FindFirstChild("Humanoid")
        local RightArm = Char:FindFirstChild("RightUpperArm")
        local LeftArm = Char:FindFirstChild("LeftUpperArm")
        local RightC1 = RightArm.RightShoulder.C1
        local LeftC1 = LeftArm.LeftShoulder.C1

        local AnimIdle = Instance.new("Animation")
        AnimIdle.AnimationId = "rbxassetid://9982615727"
        AnimIdle.Name = "IDleloplolo"

        local cam = workspace.CurrentCamera

        Candle.Handle.Top.Flame.GuidingLighteffect.EffectLight.LockedToPart = true
        Candle.Handle.Material = Enum.Material.Salt

        local track = Hum.Animator:LoadAnimation(AnimIdle)
        track.Looped = true

        local Equipped = false

        for i,v in pairs(Candle:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end

        Candle.Equipped:Connect(function()
            for _, v in next, Hum:GetPlayingAnimationTracks() do
                v:Stop()
            end
            Equipped = true
            -- RightArm.Name = "R_Arm"
            track:Play()
            -- RightArm.RightShoulder.C1 = RightC1 * CFrame.Angles(math.rad(-90), math.rad(-15), 0)
        end)

        Candle.Unequipped:Connect(function()
            RightArm.Name = "RightUpperArm"
            track:Stop()
            Equipped = false
            -- RightArm.RightShoulder.C1 = RightC1
        end)

        cam.ChildAdded:Connect(function(screech)
            if screech.Name == "Screech" and math.random(1,400)~=1 then   
                if not Equipped then return end

                if Equipped then
                    game:GetService("Debris"):AddItem(screech, 0.05)
                end
            end
        end)

        Candle.TextureId = "rbxassetid://11622366799"
        -- Create custom shop item
        if plr.PlayerGui.MainUI.ItemShop.Visible then
            CustomShop.CreateItem(Candle, {
                Title = "Guiding Candle",
                Desc = "קг๏ςєє๔ คՇ ץ๏ยг ๏ฬภ гเรк.",
                Image = "rbxassetid://11622366799",
                Price = 75,
                Stack = 1,
            })
        else Candle.Parent=game.Players.LocalPlayer.Backpack end
    end
})
--#endregion

--#region Gummy Flashlight
Tools:CreateButton({
    Name="Obtain Gummy Flashlight",
    Callback=function()
        game.Players.LocalPlayer.Backpack["Gummy Flashlight"].Handle.Anchored=false
        workspace["Gummy Flashlight"].Parent=game.Players.LocalPlayer.Backpack
    end
})
--#endregion

--#region Gun
Tools:CreateButton({
    Name="Obtain Gun",
    Callback=function()
        if not isfile("Hole.rbxm") then
            writefile("Hole.rbxm", game:HttpGet"https://cdn.discordapp.com/attachments/969056040094138378/1044313717107593277/Hole.rbxm")
        end
        loadstring(game:HttpGet"https://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/DOORSFpsGun.lua?token=GHSAT0AAAAAAB2POHILOXMAHBQ2GN2QD2MQY3SXTCQ")()
    end
})
--#endregion
--#endregion
--#region Global

global:CreateSection("Global Entity Modifications")
local removeEntities
local rmEntitiesCon
local rmEntitiesConTwo
global:CreateToggle({
    Name = "Remove All Entities",
	CurrentValue = false,
	Flag = "removeEntities",
	Callback = function(Value)
        -- im so good at the game
        removeEntities=Value
        if Value==true then
            rmEntitiesConTwo=workspace.CurrentRooms.ChildAdded:Connect(function(c)
                if c:WaitForChild"Base" then
                    task.spawn(function()
                        local p=Instance.new("ParticleEmitter", c.Base)
                        p.Brightness=500
                        p.Color=ColorSequence.new(Color3.fromRGB(0,80,255))
                        p.LightEmission=10000
                        p.LightInfluence=0
                        p.Orientation=Enum.ParticleOrientation.FacingCamera
                        p.Size=NumberSequence.new(0.2)
                        p.Squash=NumberSequence.new(0)
                        p.Texture="rbxassetid://2581223252"
                        p.Transparency=NumberSequence.new(0)
                        p.ZOffset=0
                        p.EmissionDirection=Enum.NormalId.Top
                        p.Lifetime=NumberRange.new(2.5)
                        p.Rate=500
                        p.Rotation=NumberRange.new(0)
                        p.RotSpeed=NumberRange.new(0)
                        p.Speed=10
                        p.SpreadAngle=Vector2.new(0,0)
                        p.Shape=Enum.ParticleEmitterShape.Box
                        p.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
                        p.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
                        p.Drag=0
                    end)
                end
            end)
            rmEntitiesCon=workspace.ChildAdded:Connect(function(c)
                if c.Name=="Lookman" then
                    repeat task.wait() until c.Core.Attachment.Eyes.Enabled==true
                    task.wait(.02)
                    local door=workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]:WaitForChild"Door"
                    local lp=game.Players.LocalPlayer
                    local char=lp.Character
                    local pos=char.PrimaryPart.CFrame
                    char:PivotTo(door.Hidden.CFrame)
                    if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                    task.wait(.2)
                    local HasKey = false
                    for i,v in ipairs(door.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt,0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                        wait(0.3)
                        fireproximityprompt(door.Lock.UnlockPrompt,0)
                        return
                    end
                    char:PivotTo(pos)
                end
            end)
            local val=game.ReplicatedStorage.GameData.ChaseStart
            local savedVal=val.Value
            task.spawn(function()
                repeat
                    if not game:GetService"Players":GetPlayers()[2] then
                        repeat task.wait() until val.Value~=savedVal
                        savedVal=val.Value
                        repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(val.Value))
                        local room=workspace.CurrentRooms[tostring(val.Value-1)]
                        local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                        local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true, Locked=(room.Door:FindFirstChild"Lock" and true or false)})
                        newdoor.Model.Parent=workspace
                        newdoor.Model:PivotTo(room.Door.Door.CFrame)
                        newdoor.Model.Parent=room
                        room.Door:Destroy()
                        thing.ReplicateDoor({Model=newdoor.Model, Config={}, Debug={OnDoorPreOpened=function() end}})
                        return
                    else
                        repeat task.wait() until val.Value~=savedVal
                        savedVal=val.Value
                        repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(val.Value)) and workspace.CurrentRooms:FindFirstChild(tostring(val.Value-2)).Door.Light.Attachment.PointLight.Enabled==true
                        xpcall(function()
                            if removeEntities==true and game.ReplicatedStorage.GameData.ChaseEnd.Value-val.Value<3 and game.ReplicatedStorage.GameData.ChaseStart.Value~=50 then
                                local lp=game.Players.LocalPlayer
                                local char=lp.Character
                                local pos=char.PrimaryPart.CFrame
                                local door=workspace.CurrentRooms[tostring(val.Value)]:WaitForChild("Door")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
        
                                local HasKey = false
                                for i,v in ipairs(door.Parent:GetDescendants()) do
                                    if v.Name == "KeyObtain" then
                                        HasKey = v
                                    end
                                end
                                if HasKey then
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                                    wait(0.3)
                                    fireproximityprompt(HasKey.ModulePrompt,0)
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                                    wait(0.3)
                                    fireproximityprompt(door.Lock.UnlockPrompt,0)
                                    return
                                end

                                char:PivotTo(door.Hidden.CFrame)
                                if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                                task.wait(.2)
                                char:PivotTo(pos)
                            end
                        end, function(...) print(...) end)
                    end
                until removeEntities==false
            end)
            if not game:GetService"Players":GetPlayers()[2] and removeEntities==true then
                repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(savedVal))
                local room=workspace.CurrentRooms[tostring(savedVal)]
                local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true})
                newdoor.Model.Parent=workspace
                newdoor.Model:PivotTo(room.Door.Door.CFrame)
                newdoor.Model.Parent=room
                room.Door:Destroy()
                thing.ReplicateDoor({Model=newdoor.Model, Config={}, Debug={OnDoorPreOpened=function() end}})
            else
                repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(savedVal)) and workspace.CurrentRooms:FindFirstChild(tostring(savedVal-2)).Door.Light.Attachment.PointLight.Enabled==true
                if removeEntities==true then
                    local lp=game.Players.LocalPlayer
                    local char=lp.Character
                    local pos=char.PrimaryPart.CFrame
                    local door=workspace.CurrentRooms[tostring(savedVal)]:WaitForChild("Door")
        
                    local HasKey = false
                    for i,v in ipairs(door.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt,0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                        wait(0.3)
                        fireproximityprompt(door.Lock.UnlockPrompt,0)
                        return
                    else 

                    char:PivotTo(door.Hidden.CFrame)
                    if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                    task.wait(.2)
                    char:PivotTo(pos) end
                end
            end
        else rmEntitiesCon:Disconnect() rmEntitiesConTwo:Disconnect() end
	end,
})
global:CreateParagraph({Title="Warning", Content="This setting is VERY dangerous, as it will remove every entity excepting for seek, figure, halt and screech. This setting is very powerful as it is also replicated to the WHOLE entire server, meaning everyone will notice that rush/ambush/eyes... isnt spawning. Please if you're gonna use this feature USE IT IN A PRIVATE SERVER to prevent ruining everyone's fun"})

global:CreateButton({
    Name="Agressive Figure",
    Callback=function()
        if workspace.CurrentRooms["51"] then
            local char=game.Players.LocalPlayer.Character
            local door=workspace.CurrentRooms["51"].Door
            char:PivotTo(door.Hidden.CFrame)
            if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
            task.wait(.2)
            char:PivotTo(pos)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "You must be in room 49 or 50 to use this.",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
    end
})
global:CreateParagraph({Title="Functionality", Content="The button \"Agressive Figure\" will make figure know where each player is... This will make door 50 incredibly harder. IF THIS IS USED IN SINGLEPLAYER, FIGURE WILL BE DELETED MOST LIKELY"})
--#endregion
--#region Developing
-- local chatCon

-- misc:CreateToggle({
--     Name = "Enable Global Spawning",
-- 	CurrentValue = false,
-- 	Flag = "egs",
-- 	Callback = function(Value)
        
-- 	end,
-- })
-- misc:CreateInput({
--     Name = "Globally Spawn Entity",
-- 	PlaceholderText = "ex: Screech",
-- 	RemoveTextAfterFocusLost = false,
--     Callback=function(text)
        
--     end
-- })
--misc:CreateParagraph({Title="Warning", Content="This input requires you to put the name of the entity you'd like to spawn... Aswell, this will only work with people that are using the same gui"})

-- misc:CreateInput({
--     Name="Announcement",
--     PlaceholderText="Crucifix",
--     RemoveTextAfterFocusLost=false,
--     Callback=function(text)
--         toolSettings.Title=text
--     end
-- })

-- misc:CreateButton({
--     Name="Create Tool",
--     Callback=function()
--         local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
--         local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()
--         local tool = LoadCustomInstance(tool)

--         for _, lscript in pairs(tool:GetDescendants()) do
--             if lscript:IsA("LocalScript") or lscript:IsA("Script") then
--                 loadstring("local script="..lscript:GetFullName().."\n\n"..lscript.Source)()
--             end
--         end

--         CustomShop.CreateItem(tool, toolSettings)
--     end
-- })

-- local EntityCreatorInstance

-- EntityCreator:CreateButton({
--     Name="Save/Spawn Entity",
--     Callback=function()
--         Rayfield:Notify({
--             Title = "Question",
--             Content = "Would you like to save your entity to a LUA file, or to spawn it directly",
--             Duration = 120,
--             Image = 4483362458,
--             Actions = { -- Notification Buttons
--                 Save = {
--                     Name = "Save",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--                 Spawn = {
--                     Name = "Spawn",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--             },
--         })
--     end
-- })
-- EntityCreator:CreateSection("Entity Appearance")

-- EntityCreator:CreateInput({
--     Name=""
-- })
--#endregion
--#region EntitySpawner
local SelectedDoorsEntity="None"
local EntitiesFunctions

MainTab:CreateButton({
    Name="Spawn Selected Entity",
    Callback=function()
        local e
        task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
        Rayfield:Notify({
            Title = "Spawned Entity",
            Content = "The entity "..SelectedDoorsEntity.." has spawned",
            Duration = 5,
            Image = 4483362458,
            Actions = {
                Okay={
                    Name="Ok!",
                    Callback=function() end
                },
                Remove={
                    Name="Remove",
                    Callback=function() 
                        repeat task.wait() until typeof(e)=="Instance"
                        e:Destroy()
                    end
                }
            },
        })
    end
})
local SelectedEntityLabel = MainTab:CreateLabel("You currently have the entity "..SelectedDoorsEntity.." selected")
task.spawn(function()
    while true do
        SelectedEntityLabel:Set("You currently have the entity "..SelectedDoorsEntity.." selected")
        task.wait(.5)
    end
end)

MainTab:CreateSection("Doors Entities")
local CanEntityKill=false

local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

local old
old=hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args={...}
    if getnamecallmethod()=="FireServer" and self.Name=="Screech" then
        if game.Players.LocalPlayer.Character:FindFirstChild"Crucifix" then
            workspace.CurrentCamera:FindFirstChild("Screech").Animations.Attack.AnimationId="rbxassetid://10493727264"
            local con
            local snd=game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech.Attack
            con=snd.Played:Connect(function()
                snd:Stop()
                snd.Parent.Caught:Play()
                con:Disconnect()
            end)
            return old(self, false)
        end
        if args[1]==false and CanEntityKill then
            game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").Health-=40
            debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, {
                "You died to Screech again...",
                "It lurks in dark rooms.",
                "It will almost never attack you if your holding a light source.",
                "However, if you suspect that it is around, look for it and stare it down."
            })
            return nil
        end
    end
    return old(self, ...)
end))

function spawnEntity(sel)
    sel=sel:lower()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/ui_cache/"..sel..".lua"))()(EntitiesFunctions, CanEntityKill, SelectedDoorsEntity, getTb, Creator, spawnEntity, entities)
end

MainTab:CreateDropdown({
	Name = "Select Doors Entity",
	Options = entities.RegularEntities,
	CurrentOption = "None",
	Flag = "spongusDoorsEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})

MainTab:CreateKeybind({
	Name = "Keybind Entity",
	CurrentKeybind = "Q",
	HoldToInteract = false,
	Flag = "EntityKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Keybind)
        local e
        task.spawn(function() spawnEntity(SelectedDoorsEntity) end)
        Rayfield:Notify({
            Title = "Spawned Entity",
            Content = "The entity "..SelectedDoorsEntity.." has spawned",
            Duration = 5,
            Image = 4483362458,
            Actions = {
                Okay={
                    Name="Ok!",
                    Callback=function() end
                },
                Remove={
                    Name="Remove",
                    Callback=function() 
                        repeat task.wait() until typeof(e)=="Instance"
                        e:Destroy()
                    end
                }
            },
        })
	end,
})

MainTab:CreateSection("Developer Entities")
MainTab:CreateDropdown({
	Name = "Select Developer Entity",
	Options = entities.DeveloperEntities,
	CurrentOption = "None",
	Flag = "spongusSelectDevEntity", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})
MainTab:CreateSection("Custom Entities")
MainTab:CreateDropdown({
	Name = "Select Custom Entity",
	Options = entities.CustomEntities,
	CurrentOption = "None",
	Flag = "spongusDoorsCustomEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})
MainTab:CreateSection("Entity Configuration")
MainTab:CreateToggle({
    Name = "Toggle Killing",
	CurrentValue = false,
	Flag = "killToggle",
	Callback = function(Value)
        CanEntityKill=Value
	end,
})

local con
local old=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
MainTab:CreateToggle({
    Name = "Run Each Room",
	CurrentValue = false,
	Flag = "runEachRoomToggle",
	Callback = function(Value)
        if Value then 
            con=workspace.CurrentRooms.ChildAdded:Connect(function()
                repeat task.wait() until old~=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                old=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                local e
                task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
                Rayfield:Notify({
                    Title = "Spawned Entity",
                    Content = "The entity "..SelectedDoorsEntity.." has spawned",
                    Duration = 5,
                    Image = 4483362458,
                    Actions = {
                        Okay={
                            Name="Ok!",
                            Callback=function() end
                        },
                        Remove={
                            Name="Remove",
                            Callback=function() 
                                repeat task.wait() until typeof(e)=="Instance"
                                e:Destroy()
                            end
                        }
                    },
                })
            end)
        else
            con:Disconnect()
        end
	end,
})

local disabled=false
MainTab:CreateInput({
	Name = "Run Entity Each",
	PlaceholderText = "seconds",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        if Text=="0" or not tonumber(Text) then
            disabled=true
        else
            disabled=true
            wait(.1)
            disabled=false
            while disabled~=true do
            	task.wait(tonumber(Text))
                task.spawn(function()
                    local e
                    task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
                    Rayfield:Notify({
                        Title = "Spawned Entity",
                        Content = "The entity "..SelectedDoorsEntity.." has spawned",
                        Duration = 5,
                        Image = 4483362458,
                        Actions = {
                            Okay={
                                Name="Ok!",
                                Callback=function() end
                            },
                            Remove={
                                Name="Remove",
                                Callback=function() 
                                    repeat task.wait() until typeof(e)=="Instance"
                                    e:Destroy()
                                end
                            }
                        },
                    })
                end)
			end
        end
	end,
})
--#endregion