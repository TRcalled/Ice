--[[
    IceLib Interface Suite V2 (Modern)
    Inspired by Rayfield Gen2
]]

local IceLib = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Modern Ice Theme Palette
local Theme = {
    Background = Color3.fromRGB(13, 17, 23),
    Sidebar = Color3.fromRGB(20, 25, 34),
    Accent = Color3.fromRGB(0, 210, 255),
    AccentDark = Color3.fromRGB(0, 140, 200),
    ElementBg = Color3.fromRGB(24, 30, 40),
    ElementHover = Color3.fromRGB(32, 40, 52),
    Text = Color3.fromRGB(240, 245, 255),
    TextMuted = Color3.fromRGB(130, 150, 170),
    Stroke = Color3.fromRGB(45, 55, 70),
    Shadow = Color3.fromRGB(0, 0, 0)
}

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function Tween(instance, properties, duration, style)
    style = style or Enum.EasingStyle.Quart
    local info = TweenInfo.new(duration or 0.3, style, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            Tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end

function IceLib:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "IceLib Suite"

    local IceGui = Create("ScreenGui", {
        Name = "IceLibGui",
        ResetOnSpawn = false,
        Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    })

    -- Shadow Backdrop
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 580, 0, 400),
        Position = UDim2.new(0.5, -290, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        Parent = IceGui,
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
    Create("UIStroke", { Color = Theme.Stroke, Thickness = 1.5, Transparency = 0.5, Parent = MainFrame })

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Transparency = 0.7, Parent = Sidebar })

    local TitleBox = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Theme.Accent,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Sidebar
    })
    
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -16, 1, -60),
        Position = UDim2.new(0, 8, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = TabContainer })

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, -160, 0, 50),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    MakeDraggable(Topbar, MainFrame)

    local ElementsContainer = Create("Frame", {
        Name = "ElementsContainer",
        Size = UDim2.new(1, -170, 1, -60),
        Position = UDim2.new(0, 165, 0, 50),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local NotificationArea = Create("Frame", {
        Name = "NotificationArea",
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        Parent = IceGui
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = NotificationArea })

    local Window = { Tabs = {} }

    function Window:Notify(options)
        options = options or {}
        local title = options.Title or "Notification"
        local content = options.Content or "Something happened."
        local duration = options.Duration or 3

        local NotifFrame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 65),
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Parent = NotificationArea
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = NotifFrame })
        local NotifStroke = Create("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 1, Parent = NotifFrame })

        local NTitle = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Theme.Accent,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifFrame
        })

        local NContent = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundTransparency = 1,
            Text = content,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifFrame
        })

        -- Animate In
        Tween(NotifFrame, {BackgroundTransparency = 0.1}, 0.4)
        Tween(NotifStroke, {Transparency = 0.5}, 0.4)
        Tween(NTitle, {TextTransparency = 0}, 0.4)
        Tween(NContent, {TextTransparency = 0}, 0.4)

        task.delay(duration, function()
            Tween(NotifFrame, {BackgroundTransparency = 1}, 0.4)
            Tween(NotifStroke, {Transparency = 1}, 0.4)
            Tween(NTitle, {TextTransparency = 1}, 0.4)
            Tween(NContent, {TextTransparency = 1}, 0.4)
            task.wait(0.4)
            NotifFrame:Destroy()
        end)
    end

    function Window:CreateTab(tabName)
        local TabButton = Create("TextButton", {
            Name = tabName.."_Btn",
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Text = "  "..tabName,
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = TabContainer
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabButton })

        local TabPage = Create("ScrollingFrame", {
            Name = tabName.."_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Stroke,
            Visible = false,
            Parent = ElementsContainer
        })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = TabPage })

        table.insert(Window.Tabs, {Button = TabButton, Page = TabPage})

        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Page.Visible = false
                Tween(tab.Button, {BackgroundTransparency = 1, TextColor3 = Theme.TextMuted}, 0.2)
            end
            TabPage.Visible = true
            Tween(TabButton, {BackgroundTransparency = 0, BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.Accent}, 0.3)
        end)

        if #Window.Tabs == 1 then
            TabPage.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Theme.ElementHover
            TabButton.TextColor3 = Theme.Accent
        end

        local Elements = {}

        function Elements:CreateButton(options)
            local btnName = options.Name or "Button"
            local callback = options.Callback or function() end

            local ButtonFrame = Create("TextButton", {
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Theme.ElementBg,
                Text = "",
                AutoButtonColor = false,
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ButtonFrame })
            Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = ButtonFrame })

            local Title = Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = btnName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ButtonFrame
            })

            local Icon = Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Text = "›",
                TextColor3 = Theme.TextMuted,
                Font = Enum.Font.GothamMedium,
                TextSize = 18,
                Parent = ButtonFrame
            })

            ButtonFrame.MouseEnter:Connect(function() Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2) end)
            ButtonFrame.MouseLeave:Connect(function() Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBg}, 0.2) end)
            ButtonFrame.MouseButton1Click:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                task.wait(0.1)
                Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2)
                callback()
            end)
        end

        function Elements:CreateToggle(options)
            local tglName = options.Name or "Toggle"
            local default = options.CurrentValue or false
            local callback = options.Callback or function() end
            local toggled = default

            local ToggleFrame = Create("TextButton", {
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Theme.ElementBg,
                Text = "",
                AutoButtonColor = false,
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ToggleFrame })
            Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = ToggleFrame })

            local Title = Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = tglName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })

            local SwitchBg = Create("Frame", {
                Size = UDim2.new(0, 36, 0, 18),
                Position = UDim2.new(1, -45, 0.5, -9),
                BackgroundColor3 = toggled and Theme.Accent or Theme.Background,
                Parent = ToggleFrame
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchBg })
            local SwitchStroke = Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = SwitchBg })

            local SwitchDot = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, toggled and 20 or 2, 0.5, -7),
                BackgroundColor3 = Theme.Text,
                Parent = SwitchBg
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchDot })

            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                Tween(SwitchBg, {BackgroundColor3 = toggled and Theme.Accent or Theme.Background}, 0.3, Enum.EasingStyle.Exponential)
                Tween(SwitchDot, {Position = toggled and UDim2.new(0, 20, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.3, Enum.EasingStyle.Exponential)
                SwitchStroke.Transparency = toggled and 1 or 0
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
                Size = UDim2.new(1, -10, 0, 50),
                BackgroundColor3 = Theme.ElementBg,
                Parent = TabPage
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SliderFrame })
            Create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = SliderFrame })

            local Title = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 15, 0, 8),
                BackgroundTransparency = 1,
                Text = sldName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })

            local ValueBg = Create("Frame", {
                Size = UDim2.new(0, 30, 0, 18),
                Position = UDim2.new(1, -45, 0, 8),
                BackgroundColor3 = Theme.Background,
                Parent = SliderFrame
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ValueBg })

            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = tostring(default),
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                Parent = ValueBg
            })

            local Track = Create("TextButton", {
                Size = UDim2.new(1, -30, 0, 4),
                Position = UDim2.new(0, 15, 1, -14),
                BackgroundColor3 = Theme.Background,
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
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + ((max - min) * percent))
                    Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
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
