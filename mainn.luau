local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Settings
local ESP = {
    Enabled = true,
    BoxesEnabled = true,
    TextEnabled = true,
    HealthBarEnabled = true,
    TracersEnabled = true,
    RainbowMode = false,
    TracerOrigin = "Center, -- "Bottom", "Top", "Center"
    BoxStyle = "Full", -- "Full" или "Corner"
    ShowName = true,
    ESPColor = Color3.fromRGB(255, 255, 255),
    HealthGreenColor = Color3.fromRGB(0, 255, 0),
    HealthRedColor = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    TextFont = Drawing.Fonts.UI,
    MaxDisplayDistance = 1000,
    BoxThickness = 1,
    HealthBarThickness = 3,
    HealthBarOffset = 4,
    MinScaleFactor = 0.5,
    TracerThickness = 1,
    RainbowSpeed = 0.2
}

local ESPInstances = {}
local RainbowColor = Color3.fromRGB(255, 255, 255)

-- Create GUI
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESPGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "ESPMainFrame"
    MainFrame.Size = UDim2.new(0, 250, 0, 300)
    MainFrame.Position = UDim2.new(0.8, 0, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local DragHitbox = Instance.new("TextButton")
    DragHitbox.Name = "DragHitbox"
    DragHitbox.Size = UDim2.new(1, 0, 0, 30)
    DragHitbox.Position = UDim2.new(0, 0, 0, 0)
    DragHitbox.BackgroundTransparency = 1
    DragHitbox.Text = ""
    DragHitbox.Parent = MainFrame
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    DragHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    DragHitbox.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Additional touch support
    UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
        if not gameProcessed and MainFrame and MainFrame.AbsolutePosition then
            local touchPos = Vector2.new(touch.Position.X, touch.Position.Y)
            local framePos = MainFrame.AbsolutePosition
            local frameSize = MainFrame.AbsoluteSize
            
            -- Check if touch is within the title bar area
            if touchPos.X >= framePos.X and touchPos.X <= framePos.X + frameSize.X and
               touchPos.Y >= framePos.Y and touchPos.Y <= framePos.Y + 30 then
                dragging = true
                dragStart = touch.Position
                startPos = MainFrame.Position
            end
        end
    end)
    
    UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
        if dragging and not gameProcessed then
            local delta = touch.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
        dragging = false
    end)
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -30, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.SourceSansBold
    TitleText.Text = "ESP Settings"
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "X"
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Touch support for close button
    CloseButton.TouchTap:Connect(function()
        ScreenGui:Destroy()
    end)
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Text = "-"
    MinimizeButton.Parent = TitleBar
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 8)
    MinimizeCorner.Parent = MinimizeButton
    
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 250, 0, 30)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 250, 0, 300)}):Play()
        end
    end)
    
    -- Touch support for minimize button
    MinimizeButton.TouchTap:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 250, 0, 30)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 250, 0, 300)}):Play()
        end
    end)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -30)
    ContentFrame.Position = UDim2.new(0, 0, 0, 30)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "SettingsFrame"
    ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
    ScrollingFrame.Parent = ContentFrame
    
    local function CreateToggle(name, setting, yPos)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name.."Frame"
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.Position = UDim2.new(0, 0, 0, yPos)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = ScrollingFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "Label"
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 16
        ToggleLabel.Font = Enum.Font.SourceSans
        ToggleLabel.Text = name
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("Frame")
        ToggleButton.Name = "Button"
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(0.8, 0, 0.5, -10)
        ToggleButton.BackgroundColor3 = ESP[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 10)
        ToggleCorner.Parent = ToggleButton
        
        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.Name = "Circle"
        ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
        ToggleCircle.Position = UDim2.new(ESP[setting] and 0.6 or 0, 2, 0, 2)
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleCircle.BorderSizePixel = 0
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = ToggleCircle
        ToggleCircle.Parent = ToggleButton
        
        local ToggleHitbox = Instance.new("TextButton")
        ToggleHitbox.Name = "Hitbox"
        ToggleHitbox.Size = UDim2.new(1, 0, 1, 0)
        ToggleHitbox.BackgroundTransparency = 1
        ToggleHitbox.Text = ""
        ToggleHitbox.Parent = ToggleButton
        
        ToggleHitbox.MouseButton1Click:Connect(function()
            ESP[setting] = not ESP[setting]
            ToggleButton.BackgroundColor3 = ESP[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = ESP[setting] and UDim2.new(0.6, 0, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        end)
        
        -- Touch support for toggles
        ToggleHitbox.TouchTap:Connect(function()
            ESP[setting] = not ESP[setting]
            ToggleButton.BackgroundColor3 = ESP[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = ESP[setting] and UDim2.new(0.6, 0, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        end)
        
        return ToggleFrame
    end
    
    local toggles = {
        {name = "ESP Enabled", setting = "Enabled", yPos = 0},
        {name = "Show Boxes", setting = "BoxesEnabled", yPos = 35},
        {name = "Show Names", setting = "ShowName", yPos = 70},
        {name = "Show Tracers", setting = "TracersEnabled", yPos = 105},
        {name = "Rainbow Mode", setting = "RainbowMode", yPos = 140}
    }
    
    for _, toggle in ipairs(toggles) do
        CreateToggle(toggle.name, toggle.setting, toggle.yPos)
    end
    
    local function CreateDropdown(name, setting, options, yPos, zIndex)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = name.."Frame"
        DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
        DropdownFrame.Position = UDim2.new(0, 0, 0, yPos)
        DropdownFrame.BackgroundTransparency = 1
        DropdownFrame.ZIndex = zIndex
        DropdownFrame.Parent = ScrollingFrame
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Name = "Label"
        DropdownLabel.Size = UDim2.new(0.7, 0, 1, 0)
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownLabel.TextSize = 16
        DropdownLabel.Font = Enum.Font.SourceSans
        DropdownLabel.Text = name
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropdownLabel.ZIndex = zIndex
        DropdownLabel.Parent = DropdownFrame
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Name = "Button"
        DropdownButton.Size = UDim2.new(0, 60, 0, 20)
        DropdownButton.Position = UDim2.new(0.73, 0, 0.5, -10)
        DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownButton.TextSize = 14
        DropdownButton.Font = Enum.Font.SourceSans
        DropdownButton.Text = ESP[setting]
        DropdownButton.ZIndex = zIndex
        DropdownButton.Parent = DropdownFrame
        
        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 5)
        DropdownCorner.Parent = DropdownButton
        
        local DropdownList = Instance.new("Frame")
        DropdownList.Name = "List"
        DropdownList.Size = UDim2.new(0, 60, 0, #options * 20)
        DropdownList.Position = UDim2.new(0.73, 0, 0.5, 10)
        DropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        DropdownList.BorderSizePixel = 0
        DropdownList.Visible = false
        DropdownList.ZIndex = zIndex + 1
        DropdownList.Parent = DropdownFrame
        
        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 5)
        ListCorner.Parent = DropdownList
        
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Size = UDim2.new(1, 0, 0, 20)
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 20)
            OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            OptionButton.BorderSizePixel = 0
            OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.TextSize = 14
            OptionButton.Font = Enum.Font.SourceSans
            OptionButton.Text = option
            OptionButton.ZIndex = zIndex + 1
            OptionButton.Parent = DropdownList
            
            OptionButton.MouseButton1Click:Connect(function()
                ESP[setting] = option
                DropdownButton.Text = option
                DropdownList.Visible = false
            end)
            
            -- Touch support for dropdown options
            OptionButton.TouchTap:Connect(function()
                ESP[setting] = option
                DropdownButton.Text = option
                DropdownList.Visible = false
            end)
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            DropdownList.Visible = not DropdownList.Visible
        end)
        
        -- Touch support for dropdown button
        DropdownButton.TouchTap:Connect(function()
            DropdownList.Visible = not DropdownList.Visible
        end)
        
        return DropdownFrame
    end
    
    CreateDropdown("Tracer Origin", "TracerOrigin", {"Bottom", "Top", "Center"}, 175, 10)
    CreateDropdown("Box Style", "BoxStyle", {"Full", "Corner"}, 210, 1)
    
    local function CreateSlider(name, setting, min, max, yPos)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name.."Frame"
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.Position = UDim2.new(0, 0, 0, yPos)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ScrollingFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = "Label"
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 16
        SliderLabel.Font = Enum.Font.SourceSans
        SliderLabel.Text = name..": "..ESP[setting]
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Name = "Bar"
        SliderBar.Size = UDim2.new(0.9, 0, 0, 6)
        SliderBar.Position = UDim2.new(0.05, 0, 0.6, 0)
        SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderBar.BorderSizePixel = 0
        SliderBar.Parent = SliderFrame
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 3)
        BarCorner.Parent = SliderBar
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "Fill"
        local fillRatio = (ESP[setting] - min) / (max - min)
        SliderFill.Size = UDim2.new(fillRatio, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBar
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 3)
        FillCorner.Parent = SliderFill
        
        local SliderKnob = Instance.new("Frame")
        SliderKnob.Name = "Knob"
        SliderKnob.Size = UDim2.new(0, 16, 0, 16)
        SliderKnob.Position = UDim2.new(fillRatio, -8, 0.5, -8)
        SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderKnob.BorderSizePixel = 0
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = SliderKnob
        SliderKnob.Parent = SliderBar
        
        local SliderHitbox = Instance.new("TextButton")
        SliderHitbox.Name = "Hitbox"
        SliderHitbox.Size = UDim2.new(1, 0, 1, 0)
        SliderHitbox.BackgroundTransparency = 1
        SliderHitbox.Text = ""
        SliderHitbox.Parent = SliderBar
        
        local isDragging = false
        local barAbsPos, barAbsSize
        
        SliderHitbox.MouseButton1Down:Connect(function()
            isDragging = true
            barAbsPos = SliderBar.AbsolutePosition.X
            barAbsSize = SliderBar.AbsoluteSize.X
            
            local mousePos = UserInputService:GetMouseLocation().X
            local position = (mousePos - barAbsPos) / barAbsSize
            position = math.clamp(position, 0, 1)
            
            SliderFill.Size = UDim2.new(position, 0, 1, 0)
            SliderKnob.Position = UDim2.new(position, -8, 0.5, -8)
            
            local value = min + (max - min) * position
            value = math.floor(value)
            ESP[setting] = value
            SliderLabel.Text = name..": "..value
        end)
        
        -- Touch support for slider
        UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
            if not gameProcessed and SliderBar then
                local touchPos = Vector2.new(touch.Position.X, touch.Position.Y)
                local barPos = SliderBar.AbsolutePosition
                local barSize = SliderBar.AbsoluteSize
                
                -- Check if touch is within slider area
                if touchPos.X >= barPos.X and touchPos.X <= barPos.X + barSize.X and
                   touchPos.Y >= barPos.Y and touchPos.Y <= barPos.Y + barSize.Y then
                    isDragging = true
                    barAbsPos = barPos.X
                    barAbsSize = barSize.X
                    
                    local position = (touchPos.X - barAbsPos) / barAbsSize
                    position = math.clamp(position, 0, 1)
                    
                    SliderFill.Size = UDim2.new(position, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(position, -8, 0.5, -8)
                    
                    local value = min + (max - min) * position
                    value = math.floor(value)
                    ESP[setting] = value
                    SliderLabel.Text = name..": "..value
                end
            end
        end)
        
        UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
            if isDragging and not gameProcessed then
                local position = (touch.Position.X - barAbsPos) / barAbsSize
                position = math.clamp(position, 0, 1)
                
                SliderFill.Size = UDim2.new(position, 0, 1, 0)
                SliderKnob.Position = UDim2.new(position, -8, 0.5, -8)
                
                local value = min + (max - min) * position
                value = math.floor(value)
                ESP[setting] = value
                SliderLabel.Text = name..": "..value
            end
        end)
        
        UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
            isDragging = false
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation().X
                local position = (mousePos - barAbsPos) / barAbsSize
                position = math.clamp(position, 0, 1)
                
                SliderFill.Size = UDim2.new(position, 0, 1, 0)
                SliderKnob.Position = UDim2.new(position, -8, 0.5, -8)
                
                local value = min + (max - min) * position
                value = math.floor(value)
                ESP[setting] = value
                SliderLabel.Text = name..": "..value
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        return SliderFrame
    end
    
    CreateSlider("Max Display Distance", "MaxDisplayDistance", 100, 2000, 245)
    
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame
    }
end

-- Function to check if a player is valid for ESP
local function IsPlayerValid(player)
    if not player then return false end
    if not player.Name then return false end
    
    -- Проверяем, что это не NPC или bot
    if player.Name:sub(1, 1) == "(" or player.Name:sub(1, 9) == "Humanoid_" then
        return false
    end
    
    -- Проверяем, что это не наш персонаж
    if LocalPlayer and LocalPlayer.Character and player == LocalPlayer.Character then
        return false
    end
    
    -- Проверяем имя игрока
    local playerName = LocalPlayer and LocalPlayer.Name
    if player.Name == playerName then
        return false
    end
    
    return true
end

-- Function to create ESP objects for a player
local function CreateESP(player)
    local ESP_Data = {
        Box = {
            TopLeft = Drawing.new("Line"),
            TopRight = Drawing.new("Line"),
            BottomLeft = Drawing.new("Line"),
            BottomRight = Drawing.new("Line"),
            Left = Drawing.new("Line"),
            Right = Drawing.new("Line"),
            Top = Drawing.new("Line"),
            Bottom = Drawing.new("Line")
        },
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    for _, line in pairs(ESP_Data.Box) do
        line.Visible = false
        line.Color = ESP.ESPColor
        line.Thickness = ESP.BoxThickness
    end
    
    ESP_Data.Name.Visible = false
    ESP_Data.Name.Size = ESP.TextSize
    ESP_Data.Name.Color = ESP.TextColor
    ESP_Data.Name.Center = true
    ESP_Data.Name.Outline = true
    ESP_Data.Name.Font = ESP.TextFont
    
    ESP_Data.Tracer.Visible = false
    ESP_Data.Tracer.Color = ESP.ESPColor
    ESP_Data.Tracer.Thickness = ESP.TracerThickness
    
    return ESP_Data
end

local function GetHealth(player)
    local health = 100
    local maxHealth = 100
    
    -- Ищем Humanoid в персонаже
    local humanoid = player:FindFirstChildOfClass("Humanoid")
    if humanoid then
        health = humanoid.Health
        maxHealth = humanoid.MaxHealth
    end
    
    -- Проверяем атрибуты здоровья
    if player:GetAttribute("Health") then
        health = player:GetAttribute("Health")
    end
    if player:GetAttribute("MaxHealth") then
        maxHealth = player:GetAttribute("MaxHealth")
    end
    
    return health, maxHealth
end

local function GetTracerOrigin()
    if ESP.TracerOrigin == "Bottom" then
        return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    elseif ESP.TracerOrigin == "Top" then
        return Vector2.new(Camera.ViewportSize.X/2, 0)
    else -- Center
        return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end

-- Update ESP function
local function UpdateESP()
    -- Проверяем workspace.Entities или Players
    local entitiesToCheck = {}
    if workspace:FindFirstChild("Entities") then
        for _, entity in pairs(workspace.Entities:GetChildren()) do
            table.insert(entitiesToCheck, entity)
        end
    end
    
    -- Также проверяем обычных игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            table.insert(entitiesToCheck, player.Character)
        end
    end
    
    for _, player in pairs(entitiesToCheck) do
        if not IsPlayerValid(player) then continue end
        
        if not ESPInstances[player] then
            ESPInstances[player] = CreateESP(player)
        end
        
        local ESP_Data = ESPInstances[player]
        
        local OnScreen = false
        local Distance = 0
        local Position, Health, MaxHealth
        local ScreenPosition, ScreenSize
        
        -- Находим PrimaryPart или HumanoidRootPart
        local rootPart = player.PrimaryPart or player:FindFirstChild("HumanoidRootPart") or player:FindFirstChild("Torso") or player:FindFirstChild("UpperTorso")
        
        if rootPart then
            local Vector, OnScreenCheck = Camera:WorldToViewportPoint(rootPart.Position)
            OnScreen = OnScreenCheck
            
            local LocalPosition = LocalPlayer.Character and (LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
            if LocalPosition then
                Distance = (rootPart.Position - LocalPosition.Position).Magnitude
            end
            
            Health, MaxHealth = GetHealth(player)
            
            if OnScreen and Distance < ESP.MaxDisplayDistance then
                local BoundingBoxSize = player:GetExtentsSize()
                local top = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, BoundingBoxSize.Y/2, 0))
                local bottom = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, -BoundingBoxSize.Y/2, 0))
                
                ScreenPosition = Vector2.new(top.X, top.Y)
                local screenSize = bottom.Y - top.Y
                local boxWidth = screenSize * 0.65
                ScreenSize = Vector2.new(boxWidth, screenSize)
                ScreenPosition = Vector2.new(top.X - boxWidth/2, top.Y)
                
                Position = Vector
            end
        end
        
        if OnScreen and Distance < ESP.MaxDisplayDistance and ESP.Enabled then
            local scaleFactor = math.clamp(1 - (Distance / ESP.MaxDisplayDistance), ESP.MinScaleFactor, 1)
            
            -- ESP Boxes
            if ESP.BoxesEnabled then
                local color = ESP.RainbowMode and RainbowColor or ESP.ESPColor
                
                if ESP.BoxStyle == "Full" then
                    -- Full box
                    ESP_Data.Box.Left.From = ScreenPosition
                    ESP_Data.Box.Left.To = ScreenPosition + Vector2.new(0, ScreenSize.Y)
                    ESP_Data.Box.Left.Color = color
                    ESP_Data.Box.Left.Visible = true
                    
                    ESP_Data.Box.Right.From = ScreenPosition + Vector2.new(ScreenSize.X, 0)
                    ESP_Data.Box.Right.To = ScreenPosition + Vector2.new(ScreenSize.X, ScreenSize.Y)
                    ESP_Data.Box.Right.Color = color
                    ESP_Data.Box.Right.Visible = true
                    
                    ESP_Data.Box.Top.From = ScreenPosition
                    ESP_Data.Box.Top.To = ScreenPosition + Vector2.new(ScreenSize.X, 0)
                    ESP_Data.Box.Top.Color = color
                    ESP_Data.Box.Top.Visible = true
                    
                    ESP_Data.Box.Bottom.From = ScreenPosition + Vector2.new(0, ScreenSize.Y)
                    ESP_Data.Box.Bottom.To = ScreenPosition + Vector2.new(ScreenSize.X, ScreenSize.Y)
                    ESP_Data.Box.Bottom.Color = color
                    ESP_Data.Box.Bottom.Visible = true
                    
                    -- Hide corner lines
                    ESP_Data.Box.TopLeft.Visible = false
                    ESP_Data.Box.TopRight.Visible = false
                    ESP_Data.Box.BottomLeft.Visible = false
                    ESP_Data.Box.BottomRight.Visible = false
                else -- Corner
                    local cornerSize = ScreenSize.X * 0.2
                    
                    -- Corner lines
                    ESP_Data.Box.TopLeft.From = ScreenPosition
                    ESP_Data.Box.TopLeft.To = ScreenPosition + Vector2.new(cornerSize, 0)
                    ESP_Data.Box.TopLeft.Color = color
                    ESP_Data.Box.TopLeft.Visible = true
                    
                    ESP_Data.Box.TopRight.From = ScreenPosition + Vector2.new(ScreenSize.X, 0)
                    ESP_Data.Box.TopRight.To = ScreenPosition + Vector2.new(ScreenSize.X - cornerSize, 0)
                    ESP_Data.Box.TopRight.Color = color
                    ESP_Data.Box.TopRight.Visible = true
                    
                    ESP_Data.Box.BottomLeft.From = ScreenPosition + Vector2.new(0, ScreenSize.Y)
                    ESP_Data.Box.BottomLeft.To = ScreenPosition + Vector2.new(cornerSize, ScreenSize.Y)
                    ESP_Data.Box.BottomLeft.Color = color
                    ESP_Data.Box.BottomLeft.Visible = true
                    
                    ESP_Data.Box.BottomRight.From = ScreenPosition + Vector2.new(ScreenSize.X, ScreenSize.Y)
                    ESP_Data.Box.BottomRight.To = ScreenPosition + Vector2.new(ScreenSize.X - cornerSize, ScreenSize.Y)
                    ESP_Data.Box.BottomRight.Color = color
                    ESP_Data.Box.BottomRight.Visible = true
                    
                    -- Vertical corner lines
                    ESP_Data.Box.Left.From = ScreenPosition
                    ESP_Data.Box.Left.To = ScreenPosition + Vector2.new(0, cornerSize)
                    ESP_Data.Box.Left.Color = color
                    ESP_Data.Box.Left.Visible = true
                    
                    ESP_Data.Box.Right.From = ScreenPosition + Vector2.new(ScreenSize.X, 0)
                    ESP_Data.Box.Right.To = ScreenPosition + Vector2.new(ScreenSize.X, cornerSize)
                    ESP_Data.Box.Right.Color = color
                    ESP_Data.Box.Right.Visible = true
                    
                    ESP_Data.Box.Top.From = ScreenPosition + Vector2.new(0, ScreenSize.Y)
                    ESP_Data.Box.Top.To = ScreenPosition + Vector2.new(0, ScreenSize.Y - cornerSize)
                    ESP_Data.Box.Top.Color = color
                    ESP_Data.Box.Top.Visible = true
                    
                    ESP_Data.Box.Bottom.From = ScreenPosition + Vector2.new(ScreenSize.X, ScreenSize.Y)
                    ESP_Data.Box.Bottom.To = ScreenPosition + Vector2.new(ScreenSize.X, ScreenSize.Y - cornerSize)
                    ESP_Data.Box.Bottom.Color = color
                    ESP_Data.Box.Bottom.Visible = true
                end
            else
                for _, line in pairs(ESP_Data.Box) do
                    line.Visible = false
                end
            end
            
            -- Name display
            if ESP.ShowName then
                ESP_Data.Name.Visible = true
                ESP_Data.Name.Position = Vector2.new(Position.X, ScreenPosition.Y - ESP.TextSize - 5)
                ESP_Data.Name.Text = player.Name
                ESP_Data.Name.Size = ESP.TextSize
                ESP_Data.Name.Color = ESP.RainbowMode and RainbowColor or ESP.TextColor
            else
                ESP_Data.Name.Visible = false
            end
            
            -- Tracers
            if ESP.TracersEnabled then
                ESP_Data.Tracer.From = GetTracerOrigin()
                ESP_Data.Tracer.To = Vector2.new(Position.X, Position.Y)
                ESP_Data.Tracer.Color = ESP.RainbowMode and RainbowColor or ESP.ESPColor
                ESP_Data.Tracer.Visible = true
            else
                ESP_Data.Tracer.Visible = false
            end
        else
            -- Hide all ESP elements
            for _, line in pairs(ESP_Data.Box) do
                line.Visible = false
            end
            ESP_Data.Name.Visible = false
            ESP_Data.Tracer.Visible = false
        end
    end
    
    -- Clean up removed players
    for player, espData in pairs(ESPInstances) do
        local stillExists = false
        for _, entity in pairs(entitiesToCheck) do
            if entity == player then
                stillExists = true
                break
            end
        end
        
        if not stillExists then
            HandlePlayerRemoval(player)
        end
    end
end

local function HandlePlayerRemoval(player)
    if ESPInstances[player] then
        for _, line in pairs(ESPInstances[player].Box) do
            line:Remove()
        end
        ESPInstances[player].Name:Remove()
        ESPInstances[player].Tracer:Remove()
        ESPInstances[player] = nil
    end
end

-- Rainbow effect
task.spawn(function()
    while task.wait(0.1) do
        if ESP.RainbowMode then
            RainbowColor = Color3.fromHSV(tick() * ESP.RainbowSpeed % 1, 1, 1)
        end
    end
end)

-- Initialize GUI and ESP
local GUI = CreateGUI()

-- Modern Notification Function
local function ShowNotification(message, duration)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "ESPNotification"
    notificationGui.Parent = game:GetService("CoreGui")

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 300, 0, 50)
    notificationFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = notificationGui

    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 8)
    notificationCorner.Parent = notificationFrame

    local notificationLabel = Instance.new("TextLabel")
    notificationLabel.Size = UDim2.new(1, 0, 1, 0)
    notificationLabel.BackgroundTransparency = 1
    notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationLabel.Font = Enum.Font.SourceSansBold
    notificationLabel.TextSize = 18
    notificationLabel.Text = message
    notificationLabel.Parent = notificationFrame

    -- Fade-in animation
    notificationFrame.BackgroundTransparency = 1
    notificationLabel.TextTransparency = 1
    TweenService:Create(notificationFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(notificationLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

    -- Wait for duration
    task.wait(duration)

    -- Fade-out animation
    TweenService:Create(notificationFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(notificationLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)

    notificationGui:Destroy()
end

-- Track nearby players
local nearbyPlayers = {}
local notificationCooldown = false

-- Check for nearby players
local function CheckNearbyPlayers()
    local entitiesToCheck = {}
    if workspace:FindFirstChild("Entities") then
        for _, entity in pairs(workspace.Entities:GetChildren()) do
            table.insert(entitiesToCheck, entity)
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            table.insert(entitiesToCheck, player.Character)
        end
    end

    for _, player in pairs(entitiesToCheck) do
        if not IsPlayerValid(player) then continue end

        local rootPart = player.PrimaryPart or player:FindFirstChild("HumanoidRootPart")
        local localRoot = LocalPlayer.Character and (LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        
        if rootPart and localRoot then
            local distance = (rootPart.Position - localRoot.Position).Magnitude
            if distance <= 70 then
                if not nearbyPlayers[player] then
                    nearbyPlayers[player] = true
                    if not notificationCooldown then
                        task.spawn(function()
                            ShowNotification("ATTENTION :// PLAYER FOUND NEARBY", 2)
                        end)
                        notificationCooldown = true
                        task.delay(5, function()
                            notificationCooldown = false
                        end)
                    end
                end
            else
                nearbyPlayers[player] = nil
            end
        end
    end
end

-- Main loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    CheckNearbyPlayers()
end)

-- Initialize ESP for existing entities
local function InitializeESP()
    if workspace:FindFirstChild("Entities") then
        for _, player in pairs(workspace.Entities:GetChildren()) do
            if IsPlayerValid(player) then
                ESPInstances[player] = CreateESP(player)
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and IsPlayerValid(player.Character) then
            ESPInstances[player.Character] = CreateESP(player.Character)
        end
    end
end

InitializeESP()

-- Event listeners
if workspace:FindFirstChild("Entities") then
    workspace.Entities.ChildAdded:Connect(function(player)
        if IsPlayerValid(player) then
            ESPInstances[player] = CreateESP(player)
        end
    end)

    workspace.Entities.ChildRemoved:Connect(function(player)
        HandlePlayerRemoval(player)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if IsPlayerValid(character) then
            ESPInstances[character] = CreateESP(character)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        HandlePlayerRemoval(player.Character)
    end
end)

-- Cleanup on game close
game:BindToClose(function()
    for _, esp in pairs(ESPInstances) do
        for _, line in pairs(esp.Box) do
            line:Remove()
        end
        esp.Name:Remove()
        esp.Tracer:Remove()
    end
    if GUI and GUI.ScreenGui then
        GUI.ScreenGui:Destroy()
    end
end)

-- Show the initial notification
task.spawn(function()
    ShowNotification("Simplified ESP Loaded!!!", 3)
end)
