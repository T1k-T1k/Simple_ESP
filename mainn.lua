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
_G.ShowHealth = true

-- Box ESP Settings
_G.BoxESPEnabled = true
_G.BoxESPVisible = true
_G.BoxColor = Color3.fromRGB(255, 80, 10)
_G.BoxThickness = 1
_G.BoxTransparency = 0.7
_G.BoxFilled = false
_G.BoxFillColor = Color3.fromRGB(255, 80, 10)
_G.BoxFillTransparency = 0.9

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
_G.ToggleBoxKey = Enum.KeyCode.R
_G.ToggleArrowKey = Enum.KeyCode.T

-- Storage for ESP elements
local ESPElements = {}

local function CreatePlayerESP(player)
    if player == Players.LocalPlayer then return end
    
    local elements = {
        tracer = nil,
        text = nil,
        box = {},
        arrow = {}
    }
    
    -- Create Tracer
    if _G.TracersEnabled then
        elements.tracer = Drawing.new("Line")
    end
    
    -- Create Text ESP
    if _G.ESPEnabled then
        elements.text = Drawing.new("Text")
        elements.text.Font = Drawing.Fonts.Monospace -- Using Inconsolata-like font
    end
    
    -- Create Box ESP
    if _G.BoxESPEnabled then
        for i = 1, 4 do
            elements.box[i] = Drawing.new("Line")
        end
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
                elements.text.Position = Vector2.new(headVector.X, headVector.Y - 30)
                
                local displayText = player.Name
                if _G.ShowDistance then
                    displayText = "[" .. math.floor(distance) .. "] " .. displayText
                end
                if _G.ShowHealth and humanoid then
                    displayText = displayText .. " [" .. math.floor(humanoid.Health) .. "]"
                end
                
                elements.text.Text = displayText
                elements.text.Visible = _G.ESPVisible
            else
                elements.text.Visible = false
            end
        end
        
        -- Update Box ESP
        if elements.box and _G.BoxESPEnabled then
            if rootOnScreen and headOnScreen then
                local boxHeight = math.abs(headVector.Y - rootVector.Y)
                local boxWidth = boxHeight * 0.6
                
                local topLeft = Vector2.new(rootVector.X - boxWidth/2, headVector.Y)
                local topRight = Vector2.new(rootVector.X + boxWidth/2, headVector.Y)
                local bottomLeft = Vector2.new(rootVector.X - boxWidth/2, rootVector.Y)
                local bottomRight = Vector2.new(rootVector.X + boxWidth/2, rootVector.Y)
                
                -- Top line
                elements.box[1].From = topLeft
                elements.box[1].To = topRight
                
                -- Right line
                elements.box[2].From = topRight
                elements.box[2].To = bottomRight
                
                -- Bottom line
                elements.box[3].From = bottomRight
                elements.box[3].To = bottomLeft
                
                -- Left line
                elements.box[4].From = bottomLeft
                elements.box[4].To = topLeft
                
                for i = 1, 4 do
                    elements.box[i].Color = _G.BoxColor
                    elements.box[i].Thickness = _G.BoxThickness
                    elements.box[i].Transparency = _G.BoxTransparency
                    elements.box[i].Visible = _G.BoxESPVisible
                end
            else
                for i = 1, 4 do
                    elements.box[i].Visible = false
                end
            end
        end
        
        -- Update Arrow ESP (for off-screen players)
        if elements.arrow and _G.ArrowsEnabled then
            if not rootOnScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local direction = (Vector2.new(rootVector.X, rootVector.Y) - screenCenter).Unit
                local arrowPos = screenCenter + direction * 100
                
                -- Create arrow triangle
                local arrowTip = arrowPos
                local arrowBase1 = arrowPos - direction * _G.ArrowSize + Vector2.new(-direction.Y, direction.X) * _G.ArrowSize * 0.5
                local arrowBase2 = arrowPos - direction * _G.ArrowSize + Vector2.new(direction.Y, -direction.X) * _G.ArrowSize * 0.5
                
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
        for i = 1, 4 do
            if elements.box[i] then elements.box[i]:Remove() end
        end
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
        _G.BoxESPVisible = not _G.BoxESPVisible
        _G.ArrowsVisible = not _G.ArrowsVisible
        
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "ESP System";
                Text = "ESP visibility: " .. tostring(_G.ESPVisible);
                Duration = 3;
            })
        end
    elseif Input.KeyCode == _G.ToggleBoxKey then
        -- Toggle box ESP only
        _G.BoxESPVisible = not _G.BoxESPVisible
        
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "ESP System";
                Text = "Box ESP: " .. tostring(_G.BoxESPVisible);
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
    _G.BoxESPVisible = true
    _G.BoxColor = Color3.fromRGB(40, 90, 255)
    _G.ArrowsVisible = true
    _G.ArrowColor = Color3.fromRGB(40, 90, 255)
end

-- Notify successful load
if _G.SendNotifications then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ESP System";
        Text = "Complete ESP system loaded successfully!";
        Duration = 5;
    })
end

print("ESP System Controls:")
print("E - Change tracer mode")
print("Q - Toggle all ESP")
print("R - Toggle box ESP")
print("T - Toggle arrow ESP")
