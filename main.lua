local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")

local Slate = {}
Slate.__index = Slate

Slate.Services = {
	Players = Players,
	TweenService = TweenService,
	UserInputService = UserInputService,
	RunService = RunService,
	TextService = TextService,
	HttpService = HttpService,
	GuiService = GuiService,
	ContextActionService = ContextActionService,
}

local DefaultSettings = {
	Name = "Slate",
	Size = {620, 420},
	SidebarWidth = 160,
	TopBarHeight = 46,
	CornerRadius = 16,
	Position = UDim2.fromScale(0.5, 0.5),
}

local function getPlayerGui(customParent)
	if customParent then
		return customParent
	end

	local player = Players.LocalPlayer
	if not player then
		error("Slate must run from a LocalScript.")
	end

	return player:WaitForChild("PlayerGui")
end

local function getWindowSize(size)
	size = size or DefaultSettings.Size

	if type(size) ~= "table" then
		error("Use Size = {width, height}.")
	end

	local width = size[1]
	local height = size[2]

	if type(width) ~= "number" or type(height) ~= "number" or width <= 0 or height <= 0 then
		error("Size needs two positive numbers.")
	end

	return UDim2.fromOffset(width, height), width, height
end

local function setButtonHover(button)
	button.MouseEnter:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 0.9}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 1}
		):Play()
	end)
end

function Slate:CreateWindow(options)
	options = options or {}

	local playerGui = getPlayerGui(options.Parent)
	local windowName = options.Name or DefaultSettings.Name
	local sidebarWidth = options.SidebarWidth or DefaultSettings.SidebarWidth
	local topBarHeight = options.TopBarHeight or DefaultSettings.TopBarHeight
	local cornerRadius = options.CornerRadius or DefaultSettings.CornerRadius
	local windowSize, windowWidth, windowHeight = getWindowSize(options.Size)

	if type(sidebarWidth) ~= "number" or sidebarWidth <= 0 or sidebarWidth >= windowWidth then
		error("SidebarWidth must be smaller than the window width.")
	end

	if type(topBarHeight) ~= "number" or topBarHeight <= 0 or topBarHeight >= windowHeight then
		error("TopBarHeight must be a positive number smaller than the window height.")
	end

	if type(cornerRadius) ~= "number" or cornerRadius < 0 then
		error("CornerRadius must be a non-negative number.")
	end

	local existingWindow = playerGui:FindFirstChild(windowName)
	if existingWindow then
		existingWindow:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = windowName
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local window = Instance.new("Frame")
	window.Name = "Container"
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = options.Position or DefaultSettings.Position
	window.Size = windowSize
	window.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	window.BorderSizePixel = 0
	window.ClipsDescendants = true
	window.Parent = screenGui

	local windowCorner = Instance.new("UICorner")
	windowCorner.Name = "Corner"
	windowCorner.CornerRadius = UDim.new(0, cornerRadius)
	windowCorner.Parent = window

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, topBarHeight)
	topBar.BackgroundTransparency = 1
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 2
	topBar.Parent = window

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.AnchorPoint = Vector2.new(0, 1)
	divider.Position = UDim2.new(0, 0, 1, 0)
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = Color3.fromRGB(232, 232, 234)
	divider.BorderSizePixel = 0
	divider.ZIndex = 3
	divider.Parent = topBar

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "Minimize"
	minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
	minimizeButton.Position = UDim2.new(1, -46, 0.5, 0)
	minimizeButton.Size = UDim2.fromOffset(30, 30)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(221, 221, 224)
	minimizeButton.BackgroundTransparency = 1
	minimizeButton.BorderSizePixel = 0
	minimizeButton.AutoButtonColor = false
	minimizeButton.Active = true
	minimizeButton.Text = ""
	minimizeButton.ZIndex = 5
	minimizeButton.Parent = topBar

	local minimizeIcon = Instance.new("Frame")
	minimizeIcon.Name = "Icon"
	minimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	minimizeIcon.Position = UDim2.fromScale(0.5, 0.5)
	minimizeIcon.Size = UDim2.fromOffset(13, 2)
	minimizeIcon.BackgroundColor3 = Color3.fromRGB(64, 64, 68)
	minimizeIcon.BorderSizePixel = 0
	minimizeIcon.ZIndex = 6
	minimizeIcon.Parent = minimizeButton

	local minimizeIconCorner = Instance.new("UICorner")
	minimizeIconCorner.CornerRadius = UDim.new(1, 0)
	minimizeIconCorner.Parent = minimizeIcon

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "Close"
	closeButton.AnchorPoint = Vector2.new(1, 0.5)
	closeButton.Position = UDim2.new(1, -8, 0.5, 0)
	closeButton.Size = UDim2.fromOffset(30, 30)
	closeButton.BackgroundColor3 = Color3.fromRGB(221, 221, 224)
	closeButton.BackgroundTransparency = 1
	closeButton.BorderSizePixel = 0
	closeButton.AutoButtonColor = false
	closeButton.Active = true
	closeButton.Text = ""
	closeButton.ZIndex = 5
	closeButton.Parent = topBar

	local closeLineOne = Instance.new("Frame")
	closeLineOne.Name = "Line"
	closeLineOne.AnchorPoint = Vector2.new(0.5, 0.5)
	closeLineOne.Position = UDim2.fromScale(0.5, 0.5)
	closeLineOne.Size = UDim2.fromOffset(14, 2)
	closeLineOne.Rotation = 45
	closeLineOne.BackgroundColor3 = Color3.fromRGB(64, 64, 68)
	closeLineOne.BorderSizePixel = 0
	closeLineOne.ZIndex = 6
	closeLineOne.Parent = closeButton

	local closeLineOneCorner = Instance.new("UICorner")
	closeLineOneCorner.CornerRadius = UDim.new(1, 0)
	closeLineOneCorner.Parent = closeLineOne

	local closeLineTwo = Instance.new("Frame")
	closeLineTwo.Name = "Line"
	closeLineTwo.AnchorPoint = Vector2.new(0.5, 0.5)
	closeLineTwo.Position = UDim2.fromScale(0.5, 0.5)
	closeLineTwo.Size = UDim2.fromOffset(14, 2)
	closeLineTwo.Rotation = -45
	closeLineTwo.BackgroundColor3 = Color3.fromRGB(64, 64, 68)
	closeLineTwo.BorderSizePixel = 0
	closeLineTwo.ZIndex = 6
	closeLineTwo.Parent = closeButton

	local closeLineTwoCorner = Instance.new("UICorner")
	closeLineTwoCorner.CornerRadius = UDim.new(1, 0)
	closeLineTwoCorner.Parent = closeLineTwo

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Position = UDim2.fromOffset(0, topBarHeight)
	sidebar.Size = UDim2.new(0, sidebarWidth, 1, -topBarHeight)
	sidebar.BackgroundColor3 = Color3.fromRGB(247, 247, 248)
	sidebar.BorderSizePixel = 0
	sidebar.ZIndex = 1
	sidebar.Parent = window

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.Name = "Corner"
	sidebarCorner.CornerRadius = UDim.new(0, cornerRadius)
	sidebarCorner.Parent = sidebar

	local sidebarFillWidth = math.min(cornerRadius, sidebarWidth)

	local sidebarFill = Instance.new("Frame")
	sidebarFill.Name = "Fill"
	sidebarFill.Position = UDim2.fromOffset(sidebarWidth - sidebarFillWidth, 0)
	sidebarFill.Size = UDim2.new(0, sidebarFillWidth, 1, 0)
	sidebarFill.BackgroundColor3 = sidebar.BackgroundColor3
	sidebarFill.BorderSizePixel = 0
	sidebarFill.Parent = sidebar

	local sidebarTopFill = Instance.new("Frame")
	sidebarTopFill.Name = "TopFill"
	sidebarTopFill.Size = UDim2.fromOffset(math.min(cornerRadius, sidebarWidth), cornerRadius)
	sidebarTopFill.BackgroundColor3 = sidebar.BackgroundColor3
	sidebarTopFill.BorderSizePixel = 0
	sidebarTopFill.Parent = sidebar

	local windowObject = setmetatable({
		Gui = screenGui,
		Container = window,
		TopBar = topBar,
		Divider = divider,
		Sidebar = sidebar,
		MinimizeButton = minimizeButton,
		CloseButton = closeButton,
		ExpandedSize = windowSize,
		TopBarHeight = topBarHeight,
		IsMinimized = false,
	}, Slate)

	setButtonHover(minimizeButton)
	setButtonHover(closeButton)

	minimizeButton.Activated:Connect(function()
		windowObject:ToggleMinimize()
	end)

	closeButton.Activated:Connect(function()
		windowObject:Destroy()
	end)

	return windowObject
end

function Slate:SetMinimized(isMinimized)
	if self.IsMinimized == isMinimized then
		return
	end

	self.IsMinimized = isMinimized
	self.Sidebar.Visible = not isMinimized
	self.Divider.Visible = not isMinimized

	local targetSize = self.ExpandedSize

	if isMinimized then
		targetSize = UDim2.fromOffset(self.ExpandedSize.X.Offset, self.TopBarHeight)
	end

	TweenService:Create(
		self.Container,
		TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = targetSize}
	):Play()
end

function Slate:ToggleMinimize()
	self:SetMinimized(not self.IsMinimized)
end

function Slate:SetSize(size)
	local windowSize = getWindowSize(size)
	self.ExpandedSize = windowSize

	if not self.IsMinimized then
		self.Container.Size = windowSize
	end
end

function Slate:GetSidebar()
	return self.Sidebar
end

function Slate:SetVisible(isVisible)
	self.Gui.Enabled = isVisible
end

function Slate:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return Slate
