local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Slate = {}
Slate.__index = Slate

local cfg = {
	Name = "Slate",
	Size = {620, 420},
	Side = 160,
	Radius = 16,
	Pos = UDim2.fromScale(0.5, 0.5),
}

local function getGui(parent)
	if parent then
		return parent
	end

	local player = Players.LocalPlayer
	if not player then
		error("Slate must run from a LocalScript.")
	end

	return player:WaitForChild("PlayerGui")
end

local function toSize(value)
	value = value or cfg.Size

	if type(value) ~= "table" then
		error("Use Size = {width, height}.")
	end

	local x = value[1]
	local y = value[2]

	if type(x) ~= "number" or type(y) ~= "number" or x <= 0 or y <= 0 then
		error("Size needs two positive numbers.")
	end

	return UDim2.fromOffset(x, y)
end

function Slate:CreateWindow(data)
	data = data or {}

	local host = getGui(data.Parent)
	local title = data.Name or cfg.Name
	local sideWidth = data.SidebarWidth or cfg.Side

	if type(sideWidth) ~= "number" or sideWidth <= 0 then
		error("SidebarWidth must be a positive number.")
	end

	local old = host:FindFirstChild(title)
	if old then
		old:Destroy()
	end

	local ui = Instance.new("ScreenGui")
	ui.Name = title
	ui.IgnoreGuiInset = true
	ui.ResetOnSpawn = false
	ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ui.Parent = host

	local main = Instance.new("CanvasGroup")
	main.Name = "Container"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = data.Position or cfg.Pos
	main.Size = toSize(data.Size)
	main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	main.BorderSizePixel = 0
	main.Parent = ui

	local edge = Instance.new("UICorner")
	edge.Name = "Corner"
	edge.CornerRadius = UDim.new(0, data.CornerRadius or cfg.Radius)
	edge.Parent = main

	local rail = Instance.new("Frame")
	rail.Name = "Sidebar"
	rail.Size = UDim2.new(0, sideWidth, 1, 0)
	rail.BackgroundColor3 = Color3.fromRGB(247, 247, 248)
	rail.BorderSizePixel = 0
	rail.Parent = main

	return setmetatable({
		Gui = ui,
		Container = main,
		Sidebar = rail,
	}, Slate)
end

function Slate:SetSize(value)
	self.Container.Size = toSize(value)
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
