local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Slate = {}
Slate.__index = Slate

local defaults = {
	Name = "Slate",
	Size = {620, 420},
	SidebarWidth = 160,
	Radius = 16,
	Position = UDim2.fromScale(0.5, 0.5),
}

local function playerGui(parent)
	if parent then
		return parent
	end

	local player = Players.LocalPlayer
	if not player then
		error("Slate must run from a LocalScript.")
	end

	return player:WaitForChild("PlayerGui")
end

local function sizeOf(value)
	value = value or defaults.Size

	if type(value) ~= "table" then
		error("Use Size = {width, height}.")
	end

	local width = value[1]
	local height = value[2]

	if type(width) ~= "number" or type(height) ~= "number" or width <= 0 or height <= 0 then
		error("Size needs two positive numbers.")
	end

	return UDim2.fromOffset(width, height), width
end

function Slate:CreateWindow(options)
	options = options or {}

	local host = playerGui(options.Parent)
	local name = options.Name or defaults.Name
	local sideWidth = options.SidebarWidth or defaults.SidebarWidth
	local radius = options.CornerRadius or defaults.Radius
	local windowSize, windowWidth = sizeOf(options.Size)

	if type(sideWidth) ~= "number" or sideWidth <= 0 or sideWidth >= windowWidth then
		error("SidebarWidth must be smaller than the window width.")
	end

	if type(radius) ~= "number" or radius < 0 then
		error("CornerRadius must be a non-negative number.")
	end

	local previous = host:FindFirstChild(name)
	if previous then
		previous:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = host

	local body = Instance.new("Frame")
	body.Name = "Container"
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.Position = options.Position or defaults.Position
	body.Size = windowSize
	body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	body.BorderSizePixel = 0
	body.ClipsDescendants = true
	body.Parent = gui

	local edge = Instance.new("UICorner")
	edge.Name = "Corner"
	edge.CornerRadius = UDim.new(0, radius)
	edge.Parent = body

	local side = Instance.new("Frame")
	side.Name = "Sidebar"
	side.Size = UDim2.new(0, sideWidth, 1, 0)
	side.BackgroundColor3 = Color3.fromRGB(247, 247, 248)
	side.BorderSizePixel = 0
	side.Parent = body

	local sideEdge = Instance.new("UICorner")
	sideEdge.Name = "Corner"
	sideEdge.CornerRadius = UDim.new(0, radius)
	sideEdge.Parent = side

	local joinWidth = math.min(radius, sideWidth)

	local join = Instance.new("Frame")
	join.Name = "Fill"
	join.Position = UDim2.fromOffset(sideWidth - joinWidth, 0)
	join.Size = UDim2.new(0, joinWidth, 1, 0)
	join.BackgroundColor3 = side.BackgroundColor3
	join.BorderSizePixel = 0
	join.Parent = side

	return setmetatable({
		Gui = gui,
		Container = body,
		Sidebar = side,
		Services = {
			Players = Players,
			TweenService = TweenService,
			UserInputService = UserInputService,
		},
	}, Slate)
end

function Slate:SetSize(value)
	local nextSize = sizeOf(value)
	self.Container.Size = nextSize
end

function Slate:GetSidebar()
	return self.Sidebar
end

function Slate:SetVisible(state)
	self.Gui.Enabled = state
end

function Slate:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return Slate
