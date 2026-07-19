--[[
    IceLib Interface Suite
    Inspired by Rayfield UI
    Theme: Modern Arctic Blue
]]

local IceLib = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Ice Theme Palette
local Theme = {
    Background = Color3.fromRGB(10, 18, 28),
    Sidebar = Color3.fromRGB(15, 25, 40),
    Accent = Color3.fromRGB(0, 190, 255),
    AccentDark = Color3.fromRGB(0, 120, 200),
    ElementBg = Color3.fromRGB(20, 32, 50),
    ElementHover = Color3.fromRGB(28, 45, 70),
    Text = Color3.fromRGB(230, 245, 255),
    TextMuted = Color3.fromRGB(140, 170, 200),
    Stroke = Color3.fromRGB(35, 55, 85)
}

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function MakeDraggable(topbar, main)
    local dragging = false
    local dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function IceLib:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "IceLib"

    -- ScreenGui
    local IceGui = Create("ScreenGui", {
        Name = "IceLibGui",
        ResetOnSpawn = false,
        Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    })

    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 550, 0, 380),
        Position = UDim2.new(0.5, -275, 0.5, -190),
        BackgroundColor3 = Theme.Background,
        Parent = IceGui,
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = MainFrame })

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Sidebar })

    local TitleBox = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Theme.Accent,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = Sidebar
    })
    
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = TabContainer })

    -- Topbar (For Dragging)
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, -140, 0, 40),
        Position = UDim2.new(0, 140, 0, 0),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    MakeDraggable(Topbar, MainFrame)

    -- Elements Container
    local ElementsContainer = Create("Frame", {
        Name = "ElementsContainer",
        Size = UDim2.new(1, -140, 1, -40),
        Position = UDim2.new(0, 140, 0, 40),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }

    function Window:CreateTab(tabName)
        local TabButton = Create("TextButton", {
            Name = tabName.."_Btn",
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundColor3 = Theme.Sidebar,
            Text = tabName,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = TabContainer
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabButton })

        local TabPage = Create("ScrollingFrame", {
            Name = tabName.."_Page",
            Size = UDim2.new(1, -20, 1, -10),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Stroke,
            Visible = false,
            Parent = ElementsContainer
        })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = TabPage })

        table.insert(Window.Tabs, {Button = TabButton, Page = TabPage})

        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Page.Visible = false
                TweenService:Create(tab.Button, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextMuted}):Play()
            end
            TabPage.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.Accent}):Play()
        end)

        -- Select first tab automatically
        if #Window.Tabs == 1 then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Theme.ElementHover
            TabButton.TextColor3 = Theme.Accent
        end

        local Elements = {}

        function Elements:CreateButton(options)
            local btnName = options.Name or "Button"
            local callback = options.Callback or function() end

            local ButtonFrame = Create("TextButton", {
                Name = btnName,
                Size = UDim2.new(1, -10, 0, 35),
                BackgroundColor3 = Theme.ElementBg,
                Text = btnName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                AutoButtonColor = false,
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ButtonFrame })
            Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = ButtonFrame })

            ButtonFrame.MouseEnter:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
            end)
            ButtonFrame.MouseLeave:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBg}):Play()
            end)
            ButtonFrame.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentDark}):Play()
                task.wait(0.1)
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
                callback()
            end)
        end

        function Elements:CreateToggle(options)
            local tglName = options.Name or "Toggle"
            local default = options.CurrentValue or false
            local callback = options.Callback or function() end
            local toggled = default

            local ToggleFrame = Create("TextButton", {
                Name = tglName,
                Size = UDim2.new(1, -10, 0, 35),
                BackgroundColor3 = Theme.ElementBg,
                Text = "",
                AutoButtonColor = false,
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ToggleFrame })
            Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = ToggleFrame })

            local Title = Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = tglName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })

            local SwitchBg = Create("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = toggled and Theme.Accent or Theme.Stroke,
                Parent = ToggleFrame
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchBg })

            local SwitchDot = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, toggled and 22 or 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SwitchBg
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchDot })

            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                local goalBg = toggled and Theme.Accent or Theme.Stroke
                local goalDot = toggled and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

                TweenService:Create(SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = goalBg}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = goalDot}):Play()
                callback(toggled)
            end)
        end

        function Elements:CreateSlider(options)
            local sldName = options.Name or "Slider"
            local min = options.Range[1] or 0
            local max = options.Range[2] or 100
            local default = options.CurrentValue or min
            local callback = options.Callback or function() end

            local SliderFrame = Create("Frame", {
                Name = sldName,
                Size = UDim2.new(1, -10, 0, 50),
                BackgroundColor3 = Theme.ElementBg,
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SliderFrame })
            Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = SliderFrame })

            local Title = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = sldName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })

            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -60, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(default),
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame
            })

            local Track = Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 1, -15),
                BackgroundColor3 = Theme.Stroke,
                Text = "",
                AutoButtonColor = false,
                Parent = SliderFrame
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

            local Fill = Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                Parent = Track
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

            local dragging = false
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local mousePos = input.Position.X
                    local trackPos = Track.AbsolutePosition.X
                    local trackSize = Track.AbsoluteSize.X
                    
                    local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                    local value = math.floor(min + ((max - min) * percent))
                    
                    TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    ValueLabel.Text = tostring(value)
                    callback(value)
                end
            end)
        end

        return Elements
    end

    return Window
end

return IceLib
