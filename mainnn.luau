local function API_Check()
    if Drawing == nil then
        return "No"
    else
        return "Yes"
    end
end

local Find_Required = API_Check()

if Find_Required == "No" then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ESP Script";
        Text = "ESP script could not be loaded because your exploit is unsupported.";
        Duration = math.huge;
        Button1 = "OK"
    })
    return
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TestService = game:GetService("TestService")

local Typing = false
_G.SendNotifications = true
_G.DefaultSettings = false
_G.ESPVisible = true
_G.TracerColor = Color3.fromRGB(255, 80, 10)
_G.TracerThickness = 1
_G.TracerTransparency = 0.7
_G.BoxColor = Color3.fromRGB(255, 80, 10)
_G.BoxThickness = 1
_G.BoxTransparency = 0.7
_G.ArrowColor = Color3.fromRGB(255, 80, 10)
_G.ArrowThickness = 1
_G.ArrowTransparency = 0.7
_G.TextColor = Color3.fromRGB(255, 80, 10)
_G.TextSize = 14
_G.TextTransparency = 0.7
_G.TextFont = Drawing.new("Font", {Data = game:HttpGet("https://raw.githubusercontent.com/JohnnyHappens/Fonts/main/Inconsolata-Regular.json")})
_G.DisableKey = Enum.KeyCode.Q

local function CreateESP()
    for _, v in next, Players:GetPlayers() do
        if v.Name ~= Players.LocalPlayer.Name then
            local TracerLine = Drawing.new("Line")
            local Box = Drawing.new("Square")
            local Arrow = Drawing.new("Triangle")
            local NameTag = Drawing.new("Text")

            RunService.RenderStepped:Connect(function()
                if workspace:FindFirstChild(v.Name) and workspace[v.Name]:FindFirstChild("HumanoidRootPart") and workspace[v.Name]:FindFirstChild("Head") then
                    local HumanoidRootPart = workspace[v.Name].HumanoidRootPart
                    local Head = workspace[v.Name].Head
                    local HumanoidRootPart_Position = HumanoidRootPart.CFrame.p
                    local Head_Position = Head.CFrame.p
                    local Vector, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart_Position)
                    local HeadVector = Camera:WorldToViewportPoint(Head_Position)
                    local Distance = (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (Players.LocalPlayer.Character.HumanoidRootPart.Position - HumanoidRootPart_Position).Magnitude) or 0

                    -- Tracer
                    TracerLine.Thickness = _G.TracerThickness
                    TracerLine.Transparency = _G.TracerTransparency
                    TracerLine.Color = _G.TracerColor
                    TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    TracerLine.To = Vector2.new(Vector.X, Vector.Y)
                    TracerLine.Visible = OnScreen and _G.ESPVisible

                    -- Box
                    local BoxSize = Vector2.new(2000 / Vector.Z, 3000 / Vector.Z)
                    Box.Size = BoxSize
                    Box.Position = Vector2.new(Vector.X - BoxSize.X / 2, Vector.Y - BoxSize.Y / 2)
                    Box.Thickness = _G.BoxThickness
                    Box.Transparency = _G.BoxTransparency
                    Box.Color = _G.BoxColor
                    Box.Filled = false
                    Box.Visible = OnScreen and _G.ESPVisible

                    -- Arrow (for off-screen players)
                    if not OnScreen then
                        local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local Direction = (Vector2.new(Vector.X, Vector.Y) - ScreenCenter).Unit
                        local ArrowPos = ScreenCenter + Direction * math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.4
                        Arrow.PointA = ArrowPos
                        Arrow.PointB = ArrowPos + Direction * 20 + Vector2.new(-Direction.Y, Direction.X) * 10
                        Arrow.PointC = ArrowPos + Direction * 20 + Vector2.new(Direction.Y, -Direction.X) * 10
                        Arrow.Thickness = _G.ArrowThickness
                        Arrow.Transparency = _G.ArrowTransparency
                        Arrow.Color = _G.ArrowColor
                        Arrow.Filled = true
                        Arrow.Visible = _G.ESPVisible
                    else
                        Arrow.Visible = false
                    end

                    -- Name Tag with Distance
                    NameTag.Size = _G.TextSize
                    NameTag.Color = _G.TextColor
                    NameTag.Transparency = _G.TextTransparency
                    NameTag.Font = _G.TextFont
                    NameTag.Position = Vector2.new(HeadVector.X, HeadVector.Y - 25)
                    NameTag.Text = v.Name .. " [" .. math.floor(Distance) .. "]"
                    NameTag.Center = true
                    NameTag.Outline = true
                    NameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
                    NameTag.Visible = OnScreen and _G.ESPVisible
                else
                    TracerLine.Visible = false
                    Box.Visible = false
                    Arrow.Visible = false
                    NameTag.Visible = false
                end
            end)

            Players.PlayerRemoving:Connect(function()
                TracerLine:Remove()
                Box:Remove()
                Arrow:Remove()
                NameTag:Remove()
            end)
        end
    end

    Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAdded:Connect(function(Character)
            if Player.Name ~= Players.LocalPlayer.Name then
                local TracerLine = Drawing.new("Line")
                local Box = Drawing.new("Square")
                local Arrow = Drawing.new("Triangle")
                local NameTag = Drawing.new("Text")

                RunService.RenderStepped:Connect(function()
                    if workspace:FindFirstChild(Player.Name) and workspace[Player.Name]:FindFirstChild("HumanoidRootPart") and workspace[Player.Name]:FindFirstChild("Head") then
                        local HumanoidRootPart = workspace[Player.Name].HumanoidRootPart
                        local Head = workspace[Player.Name].Head
                        local HumanoidRootPart_Position = HumanoidRootPart.CFrame.p
                        local Head_Position = Head.CFrame.p
                        local Vector, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart_Position)
                        local HeadVector = Camera:WorldToViewportPoint(Head_Position)
                        local Distance = (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (Players.LocalPlayer.Character.HumanoidRootPart.Position - HumanoidRootPart_Position).Magnitude) or 0

                        -- Tracer
                        TracerLine.Thickness = _G.TracerThickness
                        TracerLine.Transparency = _G.TracerTransparency
                        TracerLine.Color = _G.TracerColor
                        TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        TracerLine.To = Vector2.new(Vector.X, Vector.Y)
                        TracerLine.Visible = OnScreen and _G.ESPVisible

                        -- Box
                        local BoxSize = Vector2.new(2000 / Vector.Z, 3000 / Vector.Z)
                        Box.Size = BoxSize
                        Box.Position = Vector2.new(Vector.X - BoxSize.X / 2, Vector.Y - BoxSize.Y / 2)
                        Box.Thickness = _G.BoxThickness
                        Box.Transparency = _G.BoxTransparency
                        Box.Color = _G.BoxColor
                        Box.Filled = false
                        Box.Visible = OnScreen and _G.ESPVisible

                        -- Arrow (for off-screen players)
                        if not OnScreen then
                            local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local Direction = (Vector2.new(Vector.X, Vector.Y) - ScreenCenter).Unit
                            local ArrowPos = ScreenCenter + Direction * math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.4
                            Arrow.PointA = ArrowPos
                            Arrow.PointB = ArrowPos + Direction * 20 + Vector2.new(-Direction.Y, Direction.X) * 10
                            Arrow.PointC = ArrowPos + Direction * 20 + Vector2.new(Direction.Y, -Direction.X) * 10
                            Arrow.Thickness = _G.ArrowThickness
                            Arrow.Transparency = _G.ArrowTransparency
                            Arrow.Color = _G.ArrowColor
                            Arrow.Filled = true
                            Arrow.Visible = _G.ESPVisible
                        else
                            Arrow.Visible = false
                        end

                        -- Name Tag with Distance
                        NameTag.Size = _G.TextSize
                        NameTag.Color = _G.TextColor
                        NameTag.Transparency = _G.TextTransparency
                        NameTag.Font = _G.TextFont
                        NameTag.Position = Vector2.new(HeadVector.X, HeadVector.Y - 25)
                        NameTag.Text = Player.Name .. " [" .. math.floor(Distance) .. "]"
                        NameTag.Center = true
                        NameTag.Outline = true
                        NameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
                        NameTag.Visible = OnScreen and _G.ESPVisible
                    else
                        TracerLine.Visible = false
                        Box.Visible = false
                        Arrow.Visible = false
                        NameTag.Visible = false
                    end
                end)

                Players.PlayerRemoving:Connect(function()
                    TracerLine:Remove()
                    Box:Remove()
                    Arrow:Remove()
                    NameTag:Remove()
                end)
            end
        end)
    end)
end

UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == _G.DisableKey and Typing == false then
        _G.ESPVisible = not _G.ESPVisible
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ESP Script";
                Text = "ESP visibility is now set to " .. tostring(_G.ESPVisible) .. ".";
                Duration = 5;
            })
        end
    end
end)

if _G.DefaultSettings then
    _G.ESPVisible = true
    _G.TracerColor = Color3.fromRGB(40, 90, 255)
    _G.TracerThickness = 1
    _G.TracerTransparency = 0.5
    _G.BoxColor = Color3.fromRGB(40, 90, 255)
    _G.BoxThickness = 1
    _G.BoxTransparency = 0.5
    _G.ArrowColor = Color3.fromRGB(40, 90, 255)
    _G.ArrowThickness = 1
    _G.ArrowTransparency = 0.5
    _G.TextColor = Color3.fromRGB(40, 90, 255)
    _G.TextSize = 14
    _G.TextTransparency = 0.5
    _G.DisableKey = Enum.KeyCode.Q
end

local Success, Errored = pcall(function()
    CreateESP()
end)

if Success and not Errored then
    if _G.SendNotifications then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ESP Script";
            Text = "ESP script has successfully loaded.";
            Duration = 5;
        })
    end
elseif Errored then
    if _G.SendNotifications then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ESP Script";
            Text = "ESP script has errored while loading, please check the developer console! (F9)";
            Duration = 5;
        })
    end
    TestService:Message("The ESP script has errored, please check the following information:")
    warn(Errored)
end
