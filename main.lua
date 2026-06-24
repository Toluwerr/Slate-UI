local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Slate = {}
Slate.__index = Slate

local DefaultSettings = {
	Name = "Slate",
	Size = {620, 420},
	SidebarWidth = 160,
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

	return UDim2.fromOffset(width, height), width
end

function Slate:CreateWindow(options)
	options = options or {}

	local playerGui = getPlayerGui(options.Parent)
	local windowName = options.Name or DefaultSettings.Name
	local sidebarWidth = options.SidebarWidth or DefaultSettings.SidebarWidth
	local cornerRadius = options.CornerRadius or DefaultSettings.CornerRadius
	local windowSize, windowWidth = getWindowSize(options.Size)

	if type(sidebarWidth) ~= "number" or sidebarWidth <= 0 or sidebarWidth >= windowWidth then
		error("SidebarWidth must be smaller than the window width.")
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

	local corner = Instance.new("UICorner")
	corner.Name = "Corner"
	corner.CornerRadius = UDim.new(0, cornerRadius)
	corner.Parent = window

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
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

	return setmetatable({
		Gui = screenGui,
		Container = window,
		Sidebar = sidebar,
		Services = {
			Players = Players,
			TweenService = TweenService,
			UserInputService = UserInputService,
		},
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
