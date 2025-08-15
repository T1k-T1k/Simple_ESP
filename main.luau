local function API_Check()
    if Drawing == nil then
        return "No"
    else
        return "Yes"
    end
end

local Find_Required = API_Check()

if Find_Required == "No" then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ESP System";
        Text = "ESP system could not be loaded because your exploit is unsupported.";
        Duration = math.huge;
        Button1 = "OK"
    })
    return
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Typing = false

-- Configuration
_G.SendNotifications = true
_G.DefaultSettings = false

-- Tracers Settings
_G.TracersEnabled = true
_G.TracersVisible = true
_G.TracerColor = Color3.fromRGB(255, 80, 10)
_G.TracerThickness = 1
_G.TracerTransparency = 0.7
_G.FromBottom = true
_G.FromCenter = false
_G.FromMouse = false

-- ESP Text Settings
_G.ESPEnabled = true
_G.ESPVisible = true
_G.TextColor = Color3.fromRGB(255, 80, 10)
_G.TextSize = 14
_G.Center = true
_G.Outline = true
_G.OutlineColor = Color3.fromRGB(0, 0, 0)
_G.TextTransparency = 0.7
_G.TextFont = Drawing.Fonts.Monospace
_G.ShowDistance = true

-- Arrow Settings
_G.ArrowsEnabled = true
_G.ArrowsVisible = true
_G.ArrowColor = Color3.fromRGB(255, 80, 10)
_G.ArrowSize = 15
_G.ArrowThickness = 2
_G.ArrowTransparency = 0.7

-- Controls
_G.ModeSkipKey = Enum.KeyCode.E
_G.DisableKey = Enum.KeyCode.Q
_G.ToggleArrowKey = Enum.KeyCode.T

-- Storage for ESP elements
local ESPElements = {}

local function CreatePlayerESP(player)
    if player == Players.LocalPlayer then return end
    
    local elements = {
        tracer = nil,
        text = nil,
        distanceText = nil,
        arrow = {}
    }
    
    -- Create Tracer
    if _G.TracersEnabled then
        elements.tracer = Drawing.new("Line")
    end
    
    -- Create Text ESP
    if _G.ESPEnabled then
        elements.text = Drawing.new("Text")
        elements.text.Font = Drawing.Fonts.Monospace
    end
    
    -- Create Arrow ESP (triangle pointing to player)
    if _G.ArrowsEnabled then
        for i = 1, 3 do
            elements.arrow[i] = Drawing.new("Line")
        end
    end
    
    ESPElements[player] = elements
    
    local function UpdateESP()
        if not workspace:FindFirstChild(player.Name) then return end
        if not workspace[player.Name]:FindFirstChild("HumanoidRootPart") then return end
        if not workspace[player.Name]:FindFirstChild("Head") then return end
        
        local character = workspace[player.Name]
        local humanoidRootPart = character.HumanoidRootPart
        local head = character.Head
        local humanoid = character:FindFirstChild("Humanoid")
        
        -- Calculate positions
        local rootPosition = humanoidRootPart.Position
        local headPosition = head.Position
        local rootVector, rootOnScreen = Camera:WorldToViewportPoint(rootPosition)
        local headVector, headOnScreen = Camera:WorldToViewportPoint(headPosition)
        
        -- Calculate distance
        local localPlayer = Players.LocalPlayer
        local localCharacter = localPlayer.Character
        if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return end
        
        local distance = (rootPosition - localCharacter.HumanoidRootPart.Position).Magnitude
        
        -- Update Tracer
        if elements.tracer and _G.TracersEnabled then
            elements.tracer.Thickness = _G.TracerThickness
            elements.tracer.Transparency = _G.TracerTransparency
            elements.tracer.Color = _G.TracerColor
            
            if _G.FromMouse then
                elements.tracer.From = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            elseif _G.FromCenter then
                elements.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif _G.FromBottom then
                elements.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            end
            
            if rootOnScreen then
                elements.tracer.To = Vector2.new(rootVector.X, rootVector.Y)
                elements.tracer.Visible = _G.TracersVisible
            else
                elements.tracer.Visible = false
            end
        end
        
        -- Update Text ESP
        if elements.text and _G.ESPEnabled then
            elements.text.Size = _G.TextSize
            elements.text.Center = _G.Center
            elements.text.Outline = _G.Outline
            elements.text.OutlineColor = _G.OutlineColor
            elements.text.Color = _G.TextColor
            elements.text.Transparency = _G.TextTransparency
            elements.text.Font = _G.TextFont
            
            if headOnScreen then
                -- Show name above head and distance below
                elements.text.Position = Vector2.new(headVector.X, headVector.Y - 30)
                elements.text.Text = player.Name
                elements.text.Visible = _G.ESPVisible
            else
                elements.text.Visible = false
            end
        end
        
        -- Create distance text separately below name
        if not elements.distanceText and _G.ShowDistance then
            elements.distanceText = Drawing.new("Text")
            elements.distanceText.Font = Drawing.Fonts.Monospace
        end
        
        if elements.distanceText and _G.ShowDistance then
            elements.distanceText.Size = _G.TextSize - 2
            elements.distanceText.Center = _G.Center
            elements.distanceText.Outline = _G.Outline
            elements.distanceText.OutlineColor = _G.OutlineColor
            elements.distanceText.Color = _G.TextColor
            elements.distanceText.Transparency = _G.TextTransparency
            elements.distanceText.Font = _G.TextFont
            
            if headOnScreen then
                elements.distanceText.Position = Vector2.new(headVector.X, headVector.Y - 15)
                elements.distanceText.Text = "[" .. math.floor(distance) .. "]"
                elements.distanceText.Visible = _G.ESPVisible
            else
                elements.distanceText.Visible = false
            end
        end
        
        -- Update Arrow ESP (for off-screen players) - FIXED PROPERLY
        if elements.arrow and _G.ArrowsEnabled then
            if not rootOnScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                
                -- Get camera's look direction and right direction
                local cameraCFrame = Camera.CFrame
                local cameraLook = cameraCFrame.LookVector
                local cameraRight = cameraCFrame.RightVector
                
                -- Calculate direction from local player to target player in world space
                local localRootPart = localCharacter.HumanoidRootPart
                local worldDirection = (rootPosition - localRootPart.Position).Unit
                
                -- Project world direction onto camera's right and forward vectors
                local rightDot = worldDirection:Dot(cameraRight)
                local forwardDot = worldDirection:Dot(cameraLook)
                
                -- Create 2D direction (right = X, forward = -Y because screen Y is inverted)
                local direction2D = Vector2.new(rightDot, -forwardDot).Unit
                
                -- Position arrow on edge of screen
                local edgeDistance = math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.3
                local arrowPos = screenCenter + direction2D * edgeDistance
                
                -- Clamp to screen bounds with margin
                local margin = 50
                arrowPos = Vector2.new(
                    math.clamp(arrowPos.X, margin, Camera.ViewportSize.X - margin),
                    math.clamp(arrowPos.Y, margin, Camera.ViewportSize.Y - margin)
                )
                
                -- Create arrow triangle pointing in the correct direction
                local arrowTip = arrowPos
                local arrowBase1 = arrowPos - direction2D * _G.ArrowSize + Vector2.new(-direction2D.Y, direction2D.X) * _G.ArrowSize * 0.5
                local arrowBase2 = arrowPos - direction2D * _G.ArrowSize + Vector2.new(direction2D.Y, -direction2D.X) * _G.ArrowSize * 0.5
                
                elements.arrow[1].From = arrowTip
                elements.arrow[1].To = arrowBase1
                
                elements.arrow[2].From = arrowTip
                elements.arrow[2].To = arrowBase2
                
                elements.arrow[3].From = arrowBase1
                elements.arrow[3].To = arrowBase2
                
                for i = 1, 3 do
                    elements.arrow[i].Color = _G.ArrowColor
                    elements.arrow[i].Thickness = _G.ArrowThickness
                    elements.arrow[i].Transparency = _G.ArrowTransparency
                    elements.arrow[i].Visible = _G.ArrowsVisible
                end
            else
                for i = 1, 3 do
                    elements.arrow[i].Visible = false
                end
            end
        end
    end
    
    -- Connect update function
    local connection = RunService.RenderStepped:Connect(UpdateESP)
    
    -- Clean up when player leaves
    local function CleanUp()
        connection:Disconnect()
        if elements.tracer then elements.tracer:Remove() end
        if elements.text then elements.text:Remove() end
        if elements.distanceText then elements.distanceText:Remove() end
        for i = 1, 3 do
            if elements.arrow[i] then elements.arrow[i]:Remove() end
        end
        ESPElements[player] = nil
    end
    
    Players.PlayerRemoving:Connect(function(p)
        if p == player then
            CleanUp()
        end
    end)
    
    -- Clean up if character is removed
    if player.Character then
        player.Character.AncestryChanged:Connect(function()
            if not player.Character.Parent then
                CleanUp()
            end
        end)
    end
end

-- Create ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    CreatePlayerESP(player)
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1) -- Wait for character to fully load
        CreatePlayerESP(player)
    end)
    
    if player.Character then
        CreatePlayerESP(player)
    end
end)

-- Input handling
UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

UserInputService.InputBegan:Connect(function(Input)
    if Typing then return end
    
    if Input.KeyCode == _G.ModeSkipKey then
        -- Change tracer mode
        if _G.FromMouse then
            _G.FromMouse = false
            _G.FromCenter = false
            _G.FromBottom = true
            if _G.SendNotifications then
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title = "ESP System";
                    Text = "Tracers now coming from bottom";
                    Duration = 3;
                })
            end
        elseif _G.FromBottom then
            _G.FromMouse = false
            _G.FromCenter = true
            _G.FromBottom = false
            if _G.SendNotifications then
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title = "ESP System";
                    Text = "Tracers now coming from center";
                    Duration = 3;
                })
            end
        elseif _G.FromCenter then
            _G.FromMouse = true
            _G.FromCenter = false
            _G.FromBottom = false
            if _G.SendNotifications then
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title = "ESP System";
                    Text = "Tracers now coming from mouse";
                    Duration = 3;
                })
            end
        end
    elseif Input.KeyCode == _G.DisableKey then
        -- Toggle all ESP
        _G.TracersVisible = not _G.TracersVisible
        _G.ESPVisible = not _G.ESPVisible
        _G.ArrowsVisible = not _G.ArrowsVisible
        
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "ESP System";
                Text = "ESP visibility: " .. tostring(_G.ESPVisible);
                Duration = 3;
            })
        end
    elseif Input.KeyCode == _G.ToggleArrowKey then
        -- Toggle arrow ESP only
        _G.ArrowsVisible = not _G.ArrowsVisible
        
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "ESP System";
                Text = "Arrow ESP: " .. tostring(_G.ArrowsVisible);
                Duration = 3;
            })
        end
    end
end)

-- Load default settings if needed
if _G.DefaultSettings then
    _G.TracersVisible = true
    _G.TracerColor = Color3.fromRGB(40, 90, 255)
    _G.TracerThickness = 1
    _G.TracerTransparency = 0.5
    _G.ESPVisible = true
    _G.TextColor = Color3.fromRGB(40, 90, 255)
    _G.TextSize = 14
    _G.ArrowsVisible = true
    _G.ArrowColor = Color3.fromRGB(40, 90, 255)
end

-- Notify successful load
if _G.SendNotifications then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ESP System";
        Text = "ESP system loaded successfully!";
        Duration = 5;
    })
end

print("ESP System Controls:")
print("E - Change tracer mode")
print("Q - Toggle all ESP")
print("T - Toggle arrow ESPP")
