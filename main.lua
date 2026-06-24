local Players = game:GetService("Players")

local Slate = {}
Slate.__index = Slate

local DEFAULTS = {
	Name = "Slate",
	Size = {620, 420},
	CornerRadius = 16,
	Position = UDim2.fromScale(0.5, 0.5),
}

local function getParent(parent)
	if parent then
		return parent
	end

	local player = Players.LocalPlayer
	if not player then
		error("Slate must be required from a LocalScript.")
	end

	return player:WaitForChild("PlayerGui")
end

local function getSize(size)
	if size == nil then
		return UDim2.fromOffset(DEFAULTS.Size[1], DEFAULTS.Size[2])
	end

	if type(size) ~= "table" then
		error("Slate Size must use {width, height}, for example: {700, 480}")
	end

	local width = size[1]
	local height = size[2]

	if type(width) ~= "number" or type(height) ~= "number" or width <= 0 or height <= 0 then
		error("Slate Size values must be positive numbers, for example: {700, 480}")
	end

	return UDim2.fromOffset(width, height)
end

function Slate:CreateWindow(options)
	options = options or {}

	local name = options.Name or DEFAULTS.Name
	local parent = getParent(options.Parent)

	local existing = parent:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parent

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = options.Position or DEFAULTS.Position
	container.Size = getSize(options.Size)
	container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
	container.Parent = screenGui

	local rootCorner = Instance.new("UICorner")
	rootCorner.Name = "RootCorner"
	rootCorner.CornerRadius = UDim.new(0, options.CornerRadius or DEFAULTS.CornerRadius)
	rootCorner.Parent = container

	return setmetatable({
		Gui = screenGui,
		Container = container,
	}, Slate)
end

function Slate:SetSize(size)
	self.Container.Size = getSize(size)
end

function Slate:SetVisible(visible)
	self.Gui.Enabled = visible
end

function Slate:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return Slate
