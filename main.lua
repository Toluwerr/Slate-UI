local Players = game:GetService("Players")

local SlateUI = {}
SlateUI.__index = SlateUI

local DEFAULTS = {
	Name = "SlateUI",
	Width = 620,
	Height = 420,
	CornerRadius = 16,
	Position = UDim2.fromScale(0.5, 0.5),
}

local function resolveParent(customParent)
	if customParent then
		return customParent
	end

	local player = Players.LocalPlayer
	if not player then
		error("SlateUI must be created from a client-side LocalScript.")
	end

	return player:WaitForChild("PlayerGui")
end

function SlateUI:CreateWindow(options)
	options = options or {}

	local guiName = options.Name or DEFAULTS.Name
	local parent = resolveParent(options.Parent)

	local existing = parent:FindFirstChild(guiName)
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = guiName
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parent

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = options.Position or DEFAULTS.Position
	container.Size = UDim2.fromOffset(
		options.Width or DEFAULTS.Width,
		options.Height or DEFAULTS.Height
	)
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
	}, SlateUI)
end

function SlateUI:GetContainer()
	return self.Container
end

function SlateUI:SetVisible(visible)
	self.Gui.Enabled = visible
end

function SlateUI:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return SlateUI
