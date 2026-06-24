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

local Tab = {}
Tab.__index = Tab

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

local function getTabName(tabOptions)
	if type(tabOptions) == "string" then
		return tabOptions
	end

	if type(tabOptions) == "table" then
		return tabOptions.Name
	end

	error('CreateTab needs a name. Example: Window:CreateTab("Main")')
end


local function getTabIcon(tabOptions)
	if type(tabOptions) == "table" then
		return tabOptions.Icon
	end

	return nil
end

local IconAliases = {
	home = "house",
	dashboard = "layoutdashboard",
	sliders = "slidershorizontal",
	slider = "slidershorizontal",
}

local LucideIcons = {}

local function addLine(parent, x1, y1, x2, y2, color, zIndex)
	local scale = 0.75
	local x = (x1 + x2) * scale * 0.5
	local y = (y1 + y2) * scale * 0.5
	local width = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) * scale

	local line = Instance.new("Frame")
	line.Name = "Stroke"
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Position = UDim2.fromOffset(x, y)
	line.Size = UDim2.fromOffset(width, 1.6)
	line.Rotation = math.deg(math.atan2(y2 - y1, x2 - x1))
	line.BackgroundColor3 = color
	line.BorderSizePixel = 0
	line.ZIndex = zIndex
	line.Parent = parent

	local lineCorner = Instance.new("UICorner")
	lineCorner.CornerRadius = UDim.new(1, 0)
	lineCorner.Parent = line
end

local function addCircle(parent, centerX, centerY, radius, color, zIndex)
	local scale = 0.75

	local circle = Instance.new("Frame")
	circle.Name = "Stroke"
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.Position = UDim2.fromOffset(centerX * scale, centerY * scale)
	circle.Size = UDim2.fromOffset(radius * 2 * scale, radius * 2 * scale)
	circle.BackgroundTransparency = 1
	circle.BorderSizePixel = 0
	circle.ZIndex = zIndex
	circle.Parent = parent

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = color
	stroke.Parent = circle
end

local function addOutline(parent, x, y, width, height, radius, color, zIndex)
	local scale = 0.75

	local outline = Instance.new("Frame")
	outline.Name = "Stroke"
	outline.Position = UDim2.fromOffset(x * scale, y * scale)
	outline.Size = UDim2.fromOffset(width * scale, height * scale)
	outline.BackgroundTransparency = 1
	outline.BorderSizePixel = 0
	outline.ZIndex = zIndex
	outline.Parent = parent

	local outlineCorner = Instance.new("UICorner")
	outlineCorner.CornerRadius = UDim.new(0, radius * scale)
	outlineCorner.Parent = outline

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = color
	stroke.Parent = outline
end

LucideIcons.house = function(parent, color, zIndex)
	addLine(parent, 3, 11, 12, 3, color, zIndex)
	addLine(parent, 12, 3, 21, 11, color, zIndex)
	addLine(parent, 5, 10, 5, 21, color, zIndex)
	addLine(parent, 5, 21, 19, 21, color, zIndex)
	addLine(parent, 19, 21, 19, 10, color, zIndex)
	addLine(parent, 9, 21, 9, 15, color, zIndex)
	addLine(parent, 9, 15, 15, 15, color, zIndex)
	addLine(parent, 15, 15, 15, 21, color, zIndex)
end

LucideIcons.search = function(parent, color, zIndex)
	addCircle(parent, 10.5, 10.5, 6.5, color, zIndex)
	addLine(parent, 15.5, 15.5, 21, 21, color, zIndex)
end

LucideIcons.settings = function(parent, color, zIndex)
	addCircle(parent, 12, 12, 3.5, color, zIndex)
	addLine(parent, 12, 2, 12, 5.5, color, zIndex)
	addLine(parent, 12, 18.5, 12, 22, color, zIndex)
	addLine(parent, 2, 12, 5.5, 12, color, zIndex)
	addLine(parent, 18.5, 12, 22, 12, color, zIndex)
	addLine(parent, 4.9, 4.9, 7.4, 7.4, color, zIndex)
	addLine(parent, 16.6, 16.6, 19.1, 19.1, color, zIndex)
	addLine(parent, 19.1, 4.9, 16.6, 7.4, color, zIndex)
	addLine(parent, 7.4, 16.6, 4.9, 19.1, color, zIndex)
end

LucideIcons.user = function(parent, color, zIndex)
	addCircle(parent, 12, 8, 4, color, zIndex)
	addLine(parent, 4, 22, 4, 20, color, zIndex)
	addLine(parent, 4, 20, 7, 16, color, zIndex)
	addLine(parent, 7, 16, 17, 16, color, zIndex)
	addLine(parent, 17, 16, 20, 20, color, zIndex)
	addLine(parent, 20, 20, 20, 22, color, zIndex)
end

LucideIcons.folder = function(parent, color, zIndex)
	addLine(parent, 2, 7, 9, 7, color, zIndex)
	addLine(parent, 9, 7, 11, 9, color, zIndex)
	addLine(parent, 11, 9, 22, 9, color, zIndex)
	addLine(parent, 22, 9, 22, 21, color, zIndex)
	addLine(parent, 22, 21, 2, 21, color, zIndex)
	addLine(parent, 2, 21, 2, 7, color, zIndex)
end

LucideIcons.code = function(parent, color, zIndex)
	addLine(parent, 8, 6, 3, 12, color, zIndex)
	addLine(parent, 3, 12, 8, 18, color, zIndex)
	addLine(parent, 16, 6, 21, 12, color, zIndex)
	addLine(parent, 21, 12, 16, 18, color, zIndex)
	addLine(parent, 14, 3, 10, 21, color, zIndex)
end

LucideIcons.info = function(parent, color, zIndex)
	addCircle(parent, 12, 12, 9, color, zIndex)
	addLine(parent, 12, 11, 12, 17, color, zIndex)
	addCircle(parent, 12, 7, 0.9, color, zIndex)
end

LucideIcons.layoutdashboard = function(parent, color, zIndex)
	addOutline(parent, 3, 3, 8, 8, 1.5, color, zIndex)
	addOutline(parent, 13, 3, 8, 5, 1.5, color, zIndex)
	addOutline(parent, 13, 10, 8, 11, 1.5, color, zIndex)
	addOutline(parent, 3, 13, 8, 8, 1.5, color, zIndex)
end

LucideIcons.slidershorizontal = function(parent, color, zIndex)
	addLine(parent, 3, 6, 21, 6, color, zIndex)
	addLine(parent, 3, 12, 21, 12, color, zIndex)
	addLine(parent, 3, 18, 21, 18, color, zIndex)
	addCircle(parent, 9, 6, 2, color, zIndex)
	addCircle(parent, 16, 12, 2, color, zIndex)
	addCircle(parent, 7, 18, 2, color, zIndex)
end

LucideIcons.terminal = function(parent, color, zIndex)
	addLine(parent, 5, 6, 10, 12, color, zIndex)
	addLine(parent, 10, 12, 5, 18, color, zIndex)
	addLine(parent, 13, 18, 20, 18, color, zIndex)
end

LucideIcons.shield = function(parent, color, zIndex)
	addLine(parent, 12, 2, 20, 6, color, zIndex)
	addLine(parent, 20, 6, 20, 12, color, zIndex)
	addLine(parent, 20, 12, 12, 22, color, zIndex)
	addLine(parent, 12, 22, 4, 12, color, zIndex)
	addLine(parent, 4, 12, 4, 6, color, zIndex)
	addLine(parent, 4, 6, 12, 2, color, zIndex)
end

LucideIcons.file = function(parent, color, zIndex)
	addLine(parent, 6, 2, 14, 2, color, zIndex)
	addLine(parent, 14, 2, 20, 8, color, zIndex)
	addLine(parent, 20, 8, 20, 22, color, zIndex)
	addLine(parent, 20, 22, 6, 22, color, zIndex)
	addLine(parent, 6, 22, 6, 2, color, zIndex)
	addLine(parent, 14, 2, 14, 8, color, zIndex)
	addLine(parent, 14, 8, 20, 8, color, zIndex)
end

LucideIcons.bell = function(parent, color, zIndex)
	addLine(parent, 6, 17, 18, 17, color, zIndex)
	addLine(parent, 6, 17, 8, 14, color, zIndex)
	addLine(parent, 8, 14, 8, 10, color, zIndex)
	addLine(parent, 8, 10, 12, 5, color, zIndex)
	addLine(parent, 12, 5, 16, 10, color, zIndex)
	addLine(parent, 16, 10, 16, 14, color, zIndex)
	addLine(parent, 16, 14, 18, 17, color, zIndex)
	addLine(parent, 10, 20, 14, 20, color, zIndex)
end

LucideIcons.bookmark = function(parent, color, zIndex)
	addLine(parent, 6, 3, 18, 3, color, zIndex)
	addLine(parent, 18, 3, 18, 21, color, zIndex)
	addLine(parent, 18, 21, 12, 17, color, zIndex)
	addLine(parent, 12, 17, 6, 21, color, zIndex)
	addLine(parent, 6, 21, 6, 3, color, zIndex)
end

LucideIcons.menu = function(parent, color, zIndex)
	addLine(parent, 4, 6, 20, 6, color, zIndex)
	addLine(parent, 4, 12, 20, 12, color, zIndex)
	addLine(parent, 4, 18, 20, 18, color, zIndex)
end

local function getIconRenderer(iconName)
	if type(iconName) ~= "string" then
		error("Icon must be a Lucide icon name.")
	end

	local normalizedName = string.lower(iconName):gsub("[%s_%-]", "")
	normalizedName = IconAliases[normalizedName] or normalizedName

	local renderer = LucideIcons[normalizedName]
	if not renderer then
		error('Unsupported Lucide icon "' .. iconName .. '".')
	end

	return renderer, normalizedName
end

local function createLucideIcon(parent, iconName)
	local renderer, normalizedName = getIconRenderer(iconName)

	local icon = Instance.new("Frame")
	icon.Name = normalizedName
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.Position = UDim2.new(0, 11, 0.5, 0)
	icon.Size = UDim2.fromOffset(18, 18)
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.ZIndex = 5
	icon.Parent = parent

	renderer(icon, Color3.fromRGB(96, 96, 101), 6)

	return icon, normalizedName
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

local function updateTabStyle(tab)
	if not tab.Button or not tab.Button.Parent then
		return
	end

	if tab.Selected then
		tab.Button.BackgroundTransparency = 0
		tab.Button.TextColor3 = Color3.fromRGB(42, 42, 45)
	else
		tab.Button.BackgroundTransparency = 1
		tab.Button.TextColor3 = Color3.fromRGB(116, 116, 121)
	end
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
	sidebar.ClipsDescendants = true
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

	local tabList = Instance.new("ScrollingFrame")
	tabList.Name = "Tabs"
	tabList.Size = UDim2.fromScale(1, 1)
	tabList.BackgroundTransparency = 1
	tabList.BorderSizePixel = 0
	tabList.CanvasSize = UDim2.fromOffset(0, 0)
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.ScrollBarThickness = 0
	tabList.ZIndex = 3
	tabList.Parent = sidebar

	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 10)
	tabPadding.PaddingBottom = UDim.new(0, 10)
	tabPadding.PaddingLeft = UDim.new(0, 8)
	tabPadding.PaddingRight = UDim.new(0, 8)
	tabPadding.Parent = tabList

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabList

	local mainArea = Instance.new("Frame")
	mainArea.Name = "MainArea"
	mainArea.Position = UDim2.fromOffset(sidebarWidth, topBarHeight)
	mainArea.Size = UDim2.new(1, -sidebarWidth, 1, -topBarHeight)
	mainArea.BackgroundTransparency = 1
	mainArea.BorderSizePixel = 0
	mainArea.ClipsDescendants = true
	mainArea.ZIndex = 1
	mainArea.Parent = window

	local windowObject = setmetatable({
		Gui = screenGui,
		Container = window,
		TopBar = topBar,
		Divider = divider,
		Sidebar = sidebar,
		TabList = tabList,
		MainArea = mainArea,
		Tabs = {},
		SelectedTab = nil,
		MinimizeButton = minimizeButton,
		CloseButton = closeButton,
		ExpandedSize = windowSize,
		TopBarHeight = topBarHeight,
		IsMinimized = false,
		IsTransitioning = false,
		ResizeTween = nil,
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

function Slate:CreateTab(tabOptions)
	local tabName = getTabName(tabOptions)
	local tabIcon = getTabIcon(tabOptions)

	if type(tabName) ~= "string" or tabName == "" then
		error("Tab names must be non-empty strings.")
	end

	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabName
	tabButton.Size = UDim2.new(1, 0, 0, 36)
	tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tabButton.BackgroundTransparency = 1
	tabButton.BorderSizePixel = 0
	tabButton.AutoButtonColor = false
	tabButton.Text = tabName
	tabButton.TextColor3 = Color3.fromRGB(116, 116, 121)
	tabButton.Font = Enum.Font.GothamMedium
	tabButton.TextSize = 13
	tabButton.TextXAlignment = Enum.TextXAlignment.Left
	tabButton.ZIndex = 4
	tabButton.Parent = self.TabList

	local tabTextPadding = Instance.new("UIPadding")
	tabTextPadding.PaddingLeft = UDim.new(0, 12)
	tabTextPadding.PaddingRight = UDim.new(0, 12)
	tabTextPadding.Parent = tabButton

	local iconFrame
	local iconName

	if tabIcon ~= nil then
		iconFrame, iconName = createLucideIcon(tabButton, tabIcon)
		tabTextPadding.PaddingLeft = UDim.new(0, 38)
	end

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 8)
	tabCorner.Parent = tabButton

	local page = Instance.new("Frame")
	page.Name = tabName .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.ZIndex = 2
	page.Parent = self.MainArea

	local tabObject = setmetatable({
		Name = tabName,
		Icon = iconName,
		IconFrame = iconFrame,
		Button = tabButton,
		TextPadding = tabTextPadding,
		Page = page,
		Window = self,
		Selected = false,
	}, Tab)

	tabButton.MouseEnter:Connect(function()
		if not tabObject.Selected then
			TweenService:Create(
				tabButton,
				TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundTransparency = 0.94}
			):Play()
		end
	end)

	tabButton.MouseLeave:Connect(function()
		if not tabObject.Selected then
			TweenService:Create(
				tabButton,
				TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundTransparency = 1}
			):Play()
		end
	end)

	tabButton.Activated:Connect(function()
		self:SelectTab(tabObject)
	end)

	table.insert(self.Tabs, tabObject)

	if #self.Tabs == 1 then
		self:SelectTab(tabObject)
	end

	return tabObject
end

function Slate:SelectTab(tab)
	if not tab or tab.Window ~= self then
		error("SelectTab expects a tab created by this window.")
	end

	if self.SelectedTab == tab then
		return
	end

	for _, currentTab in ipairs(self.Tabs) do
		currentTab.Selected = currentTab == tab
		currentTab.Page.Visible = currentTab == tab
		updateTabStyle(currentTab)
	end

	self.SelectedTab = tab
end

function Tab:Select()
	self.Window:SelectTab(self)
end

function Tab:GetPage()
	return self.Page
end

function Tab:SetName(name)
	if type(name) ~= "string" or name == "" then
		error("Tab names must be non-empty strings.")
	end

	self.Name = name
	self.Button.Name = name
	self.Button.Text = name
	self.Page.Name = name .. "Page"
end

function Tab:SetIcon(iconName)
	if iconName ~= nil and type(iconName) ~= "string" then
		error("Icon must be a Lucide icon name or nil.")
	end

	if self.IconFrame then
		self.IconFrame:Destroy()
		self.IconFrame = nil
	end

	self.Icon = nil
	self.TextPadding.PaddingLeft = UDim.new(0, 12)

	if iconName ~= nil then
		self.IconFrame, self.Icon = createLucideIcon(self.Button, iconName)
		self.TextPadding.PaddingLeft = UDim.new(0, 38)
	end
end

function Tab:Destroy()
	local window = self.Window

	for index, currentTab in ipairs(window.Tabs) do
		if currentTab == self then
			table.remove(window.Tabs, index)
			break
		end
	end

	if self.Button then
		self.Button:Destroy()
	end

	if self.Page then
		self.Page:Destroy()
	end

	if window.SelectedTab == self then
		window.SelectedTab = nil

		if window.Tabs[1] then
			window:SelectTab(window.Tabs[1])
		end
	end
end

function Slate:SetMinimized(isMinimized)
	if type(isMinimized) ~= "boolean" then
		error("SetMinimized expects a boolean.")
	end

	if self.IsTransitioning or self.IsMinimized == isMinimized then
		return
	end

	self.IsTransitioning = true
	self.MinimizeButton.Active = false

	if not isMinimized then
		self.Sidebar.Visible = true
		self.MainArea.Visible = true
		self.Divider.Visible = true
	end

	local targetSize = self.ExpandedSize

	if isMinimized then
		targetSize = UDim2.fromOffset(self.ExpandedSize.X.Offset, self.TopBarHeight)
	end

	local resizeTween = TweenService:Create(
		self.Container,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = targetSize}
	)

	self.ResizeTween = resizeTween

	resizeTween.Completed:Connect(function(playbackState)
		if self.ResizeTween ~= resizeTween then
			return
		end

		self.ResizeTween = nil
		self.IsTransitioning = false

		if playbackState ~= Enum.PlaybackState.Completed then
			if self.MinimizeButton and self.MinimizeButton.Parent then
				self.MinimizeButton.Active = true
			end
			return
		end

		self.IsMinimized = isMinimized

		if isMinimized then
			self.Sidebar.Visible = false
			self.MainArea.Visible = false
			self.Divider.Visible = false
		end

		if self.MinimizeButton and self.MinimizeButton.Parent then
			self.MinimizeButton.Active = true
		end
	end)

	resizeTween:Play()
end

function Slate:ToggleMinimize()
	if self.IsTransitioning then
		return
	end

	self:SetMinimized(not self.IsMinimized)
end

function Slate:SetSize(size)
	local windowSize = getWindowSize(size)
	self.ExpandedSize = windowSize

	if not self.IsMinimized and not self.IsTransitioning then
		self.Container.Size = windowSize
	end
end

function Slate:GetSidebar()
	return self.Sidebar
end

function Slate:GetMainArea()
	return self.MainArea
end

function Slate:GetTabs()
	return self.Tabs
end

function Slate:SetVisible(isVisible)
	self.Gui.Enabled = isVisible
end

function Slate:Destroy()
	if self.ResizeTween then
		self.ResizeTween:Cancel()
		self.ResizeTween = nil
	end

	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
end

return Slate
