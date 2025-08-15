-- Ensure Drawing library is available
if not Drawing then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ESP Error",
        Text = "Drawing library not detected. Please ensure it is loaded.",
        Duration = math.huge,
        Button1 = "OK"
    })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Configuration
local Config = {
    Enabled = true,
    Notify = true,
    ToggleKey = Enum.KeyCode.Q,
    Tracer = {
        Color = Color3.fromRGB(255, 80, 10),
        Thickness = 1,
        Transparency = 0.7
    },
    Box = {
        Color = Color3.fromRGB(255, 80, 10),
        Thickness = 1,
        Transparency = 0.7
    },
    Arrow = {
        Color = Color3.fromRGB(255, 80, 10),
        Thickness = 1,
        Transparency = 0.7
    },
    NameTag = {
        Color = Color3.fromRGB(255, 80, 10),
        Size = 14,
        Transparency = 0.7,
        Font = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    }
}

local Typing = false

-- ESP Implementation
local function CreatePlayerESP(player)
    if player == Players.LocalPlayer then return end

    local visuals = {
        Tracer = Drawing.new("Line"),
        Box = Drawing.new("Square"),
        Arrow = Drawing.new("Triangle"),
        NameTag = Drawing.new("Text")
    }

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local character = player.Character
        if not (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Head")) then
            for _, visual in pairs(visuals) do
                visual.Visible = false
            end
            return
        end

        local root = character.HumanoidRootPart
        local head = character.Head
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position)
        local distance = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (Players.LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude or 0

        -- Tracer
        visuals.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        visuals.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        visuals.Tracer.Color = Config.Tracer.Color
        visuals.Tracer.Thickness = Config.Tracer.Thickness
        visuals.Tracer.Transparency = Config.Tracer.Transparency
        visuals.Tracer.Visible = Config.Enabled and onScreen

        -- Box
        local boxScale = 2000 / rootPos.Z
        visuals.Box.Size = Vector2.new(boxScale, boxScale * 1.5)
        visuals.Box.Position = Vector2.new(rootPos.X - boxScale / 2, rootPos.Y - boxScale * 0.75)
        visuals.Box.Color = Config.Box.Color
        visuals.Box.Thickness = Config.Box.Thickness
        visuals.Box.Transparency = Config.Box.Transparency
        visuals.Box.Filled = false
        visuals.Box.Visible = Config.Enabled and onScreen

        -- Arrow (for off-screen players)
        if not onScreen then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local direction = (Vector2.new(rootPos.X, rootPos.Y) - center).Unit
            local arrowPos = center + direction * math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.45
            visuals.Arrow.PointA = arrowPos
            visuals.Arrow.PointB = arrowPos + direction * 15 + Vector2.new(-direction.Y, direction.X) * 8
            visuals.Arrow.PointC = arrowPos + direction * 15 + Vector2.new(direction.Y, -direction.X) * 8
            visuals.Arrow.Color = Config.Arrow.Color
            visuals.Arrow.Thickness = Config.Arrow.Thickness
            visuals.Arrow.Transparency = Config.Arrow.Transparency
            visuals.Arrow.Filled = true
            visuals.Arrow.Visible = Config.Enabled
        else
            visuals.Arrow.Visible = false
        end

        -- Name Tag
        visuals.NameTag.Text = player.Name .. " [" .. math.floor(distance) .. "]"
        visuals.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 25)
        visuals.NameTag.Color = Config.NameTag.Color
        visuals.NameTag.Size = Config.NameTag.Size
        visuals.NameTag.Transparency = Config.NameTag.Transparency
        visuals.NameTag.Font = Config.NameTag.Font
        visuals.NameTag.Center = true
        visuals.NameTag.Outline = true
        visuals.NameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
        visuals.NameTag.Visible = Config.Enabled and onScreen
    end)

    Players.PlayerRemoving:Connect(function(removedPlayer)
        if removedPlayer == player then
            for _, visual in pairs(visuals) do
                visual:Remove()
            end
            connection:Disconnect()
        end
    end)
end

-- Initialize ESP for current players
for _, player in ipairs(Players:GetPlayers()) do
    CreatePlayerESP(player)
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreatePlayerESP(player)
    end)
end)

-- Typing detection
UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

-- Toggle ESP
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Config.ToggleKey and not Typing then
        Config.Enabled = not Config.Enabled
        if Config.Notify then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ESP Control",
                Text = "ESP " .. (Config.Enabled and "enabled" or "disabled") .. ".",
                Duration = 5
            })
        end
    end
end)

-- Startup notification
if Config.Notify then
    local success, err = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ESP Control",
            Text = "ESP script loaded successfully.",
            Duration = 5
        })
    end)
    if not success then
        warn("ESP script error: " .. tostring(err))
    end
end
