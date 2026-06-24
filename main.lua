local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Slate = {}
Slate.__index = Slate

local DEFAULTS = {
	Name = "Slate",
	Size = {620, 420},
	CornerRadius = 16,
	Position = UDim2.fromScale(0.5, 0.5),
}

local function getPlayerGui(customParent)
	if customParent then
		return customParent
	end

	local player = Players.LocalPlayer
	if not player then
		error("Slate must be required from a LocalScript.")
	end

	return player:WaitForChild("PlayerGui")
end

local function makeSize(size)
	if size == nil then
		size = DEFAULTS.Size
	end

	if type(size) ~= "table" then
		error("Slate Size must use {width, height}. Example: {700, 480}")
	end

	local width = size[1]
	local height = size[2]

	if type(width) ~= "number" or type(height) ~= "number" then
		error("Slate Size values must be numbers. Example: {700, 480}")
	end

	return UDim2.fromOffset(width, height)
end

function Slate:CreateWindow(options)
	options = options or {}

	local parent = getPlayerGui(options.Parent)
	local name = options.Name or DEFAULTS.Name

	local oldGui = parent:FindFirstChild(name)
	if oldGui then
		oldGui:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = options.Position or DEFAULTS.Position
	container.Size = makeSize(options.Size)
	container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
	container.Parent = gui

	local rootCorner = Instance.new("UICorner")
	rootCorner.Name = "RootCorner"
	rootCorner.CornerRadius = UDim.new(0, options.CornerRadius or DEFAULTS.CornerRadius)
	rootCorner.Parent = container

	return setmetatable({
		Gui = gui,
		Container = container,
		Services = {
			Players = Players,
			TweenService = TweenService,
			UserInputService = UserInputService,
		},
	}, Slate)
end

function Slate:SetSize(size)
	self.Container.Size = makeSize(size)
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
