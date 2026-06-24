local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Slate = {}
Slate.__index = Slate

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
			{BackgroundTransparency = 0.92}
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

	if type(topBarHeight) ~= "number" or topBarHeight <= cornerRadius or topBarHeight >= windowHeight then
		error("TopBarHeight must be larger than CornerRadius and smaller than the window height.")
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
	topBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topBar.BorderSizePixel = 0
	topBar.Parent = window

	local topBarCorner = Instance.new("UICorner")
	topBarCorner.Name = "Corner"
	topBarCorner.CornerRadius = UDim.new(0, cornerRadius)
	topBarCorner.Parent = topBar

	local topBarFill = Instance.new("Frame")
	topBarFill.Name = "Fill"
	topBarFill.Position = UDim2.fromOffset(0, cornerRadius)
	topBarFill.Size = UDim2.new(1, 0, 1, -cornerRadius)
	topBarFill.BackgroundColor3 = topBar.BackgroundColor3
	topBarFill.BorderSizePixel = 0
	topBarFill.Parent = topBar

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.AnchorPoint = Vector2.new(0, 1)
	divider.Position = UDim2.new(0, 0, 1, 0)
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = Color3.fromRGB(232, 232, 234)
	divider.BorderSizePixel = 0
	divider.Parent = topBar

	local controlArea = Instance.new("Frame")
	controlArea.Name = "Controls"
	controlArea.AnchorPoint = Vector2.new(1, 0.5)
	controlArea.Position = UDim2.new(1, -12, 0.5, 0)
	controlArea.Size = UDim2.fromOffset(62, 28)
	controlArea.BackgroundTransparency = 1
	controlArea.Parent = topBar

	local controlLayout = Instance.new("UIListLayout")
	controlLayout.FillDirection = Enum.FillDirection.Horizontal
	controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlLayout.Padding = UDim.new(0, 6)
	controlLayout.Parent = controlArea

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "Minimize"
	minimizeButton.LayoutOrder = 1
	minimizeButton.Size = UDim2.fromOffset(28, 28)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(225, 225, 228)
	minimizeButton.BackgroundTransparency = 1
	minimizeButton.BorderSizePixel = 0
	minimizeButton.AutoButtonColor = false
	minimizeButton.Text = ""
	minimizeButton.Parent = controlArea

	local minimizeIcon = Instance.new("Frame")
	minimizeIcon.Name = "Icon"
	minimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	minimizeIcon.Position = UDim2.fromScale(0.5, 0.5)
	minimizeIcon.Size = UDim2.fromOffset(12, 2)
	minimizeIcon.BackgroundColor3 = Color3.fromRGB(68, 68, 72)
	minimizeIcon.BorderSizePixel = 0
	minimizeIcon.Parent = minimizeButton

	local minimizeIconCorner = Instance.new("UICorner")
	minimizeIconCorner.CornerRadius = UDim.new(1, 0)
	minimizeIconCorner.Parent = minimizeIcon

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "Close"
	closeButton.LayoutOrder = 2
	closeButton.Size = UDim2.fromOffset(28, 28)
	closeButton.BackgroundColor3 = Color3.fromRGB(225, 225, 228)
	closeButton.BackgroundTransparency = 1
	closeButton.BorderSizePixel = 0
	closeButton.AutoButtonColor = false
	closeButton.Text = ""
	closeButton.Parent = controlArea

	local closeIconLeft = Instance.new("Frame")
	closeIconLeft.Name = "Line"
	closeIconLeft.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIconLeft.Position = UDim2.fromScale(0.5, 0.5)
	closeIconLeft.Size = UDim2.fromOffset(14, 2)
	closeIconLeft.Rotation = 45
	closeIconLeft.BackgroundColor3 = Color3.fromRGB(68, 68, 72)
	closeIconLeft.BorderSizePixel = 0
	closeIconLeft.Parent = closeButton

	local closeIconLeftCorner = Instance.new("UICorner")
	closeIconLeftCorner.CornerRadius = UDim.new(1, 0)
	closeIconLeftCorner.Parent = closeIconLeft

	local closeIconRight = Instance.new("Frame")
	closeIconRight.Name = "Line"
	closeIconRight.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIconRight.Position = UDim2.fromScale(0.5, 0.5)
	closeIconRight.Size = UDim2.fromOffset(14, 2)
	closeIconRight.Rotation = -45
	closeIconRight.BackgroundColor3 = Color3.fromRGB(68, 68, 72)
	closeIconRight.BorderSizePixel = 0
	closeIconRight.Parent = closeButton

	local closeIconRightCorner = Instance.new("UICorner")
	closeIconRightCorner.CornerRadius = UDim.new(1, 0)
	closeIconRightCorner.Parent = closeIconRight

	setButtonHover(minimizeButton)
	setButtonHover(closeButton)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Position = UDim2.fromOffset(0, topBarHeight)
	sidebar.Size = UDim2.new(0, sidebarWidth, 1, -topBarHeight)
	sidebar.BackgroundColor3 = Color3.fromRGB(247, 247, 248)
	sidebar.BorderSizePixel = 0
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

	return setmetatable({
		Gui = screenGui,
		Container = window,
		TopBar = topBar,
		Sidebar = sidebar,
		MinimizeButton = minimizeButton,
		CloseButton = closeButton,
	}, Slate)
end

function Slate:SetSize(size)
	local windowSize = getWindowSize(size)
	self.Container.Size = windowSize
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
