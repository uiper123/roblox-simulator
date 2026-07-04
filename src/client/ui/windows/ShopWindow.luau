-- ShopWindow (React version) - Vibrant Toy-Like Style
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Panel = require(script.Parent.Parent.components.Panel)
local Button = require(script.Parent.Parent.components.Button)
local ProgressBar = require(script.Parent.Parent.components.ProgressBar)
local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local function ShopWindow(props)
	local visible = props.Visible
	local onClose = props.OnClose

	local player = Players.LocalPlayer

	-- State for current upgrade levels
	local [upgrades, setUpgrades] = React.useState({
		BagCapacity = 1,
		WalkSpeed = 1,
		DetectorRadius = 1,
		TrapPower = 1,
	})

	-- Listen for changes in player's upgrade levels (stored as attributes)
	React.useEffect(function()
		local function updateLevels()
			setUpgrades({
				BagCapacity = player:GetAttribute("Upgrade_BagCapacity") or 1,
				WalkSpeed = player:GetAttribute("Upgrade_WalkSpeed") or 1,
				DetectorRadius = player:GetAttribute("Upgrade_DetectorRadius") or 1,
				TrapPower = player:GetAttribute("Upgrade_TrapPower") or 1,
			})
		end

		local connections = {}
		for key, _ in pairs(upgrades) do
			local sig = player:GetAttributeChangedSignal("Upgrade_" .. key):Connect(updateLevels)
			table.insert(connections, sig)
		end

		updateLevels()

		return function()
			for _, conn in ipairs(connections) do
				conn:Disconnect()
			end
		end
	end, {})

	-- Buy trigger handler
	local handleUpgrade = function(upgradeName)
		local remote = Remotes.Client:Get("UpgradeStat")
		if remote then
			remote:SendToServer(upgradeName)
		end
	end

	if visible == false then return nil end

	-- Build individual toy cards
	local items = {
		UIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 14),
		}),
		UIPadding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		})
	}

	-- Map internal names to сочные emojis / icons
	local iconMap = {
		BagCapacity = "🎒",
		WalkSpeed = "⚡",
		DetectorRadius = "📡",
		TrapPower = "🪤",
	}

	-- Create card components
	local layoutOrder = 1
	for upgradeName, config in pairs(UpgradeConfig) do
		local currentLevel = upgrades[upgradeName] or 1
		local nextLevel = currentLevel + 1
		local isMax = currentLevel >= config.MaxLevel

		local currentLevelData = config.Levels[currentLevel]
		local nextLevelData = not isMax and config.Levels[nextLevel] or nil
		local cost = nextLevelData and nextLevelData.Cost or 0
		local progress = currentLevel / config.MaxLevel

		-- Display text
		local statValueText = tostring(currentLevelData.Value)
		if upgradeName == "WalkSpeed" then
			statValueText = statValueText .. " Spd"
		elseif upgradeName == "DetectorRadius" then
			statValueText = statValueText .. " Studs"
		elseif upgradeName == "TrapPower" then
			statValueText = statValueText .. " Pwr"
		end

		local itemCard = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 75),
			BackgroundColor3 = Theme.Colors.BackgroundSecondary,
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder,
		}, {
			-- Toy Rounded Outline
			UICorner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			}),
			UIStroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 2.5,
			}),

			-- Left side emoji icon
			EmojiIcon = React.createElement("TextLabel", {
				Size = UDim2.new(0, 50, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				Text = iconMap[upgradeName] or "❓",
				TextSize = 28,
				Font = Theme.Fonts.Bold,
				ZIndex = 2,
			}),

			-- Title, description and level tracker
			InfoFrame = React.createElement("Frame", {
				Size = UDim2.new(0.5, -20, 1, 0),
				Position = UDim2.new(0, 70, 0, 0),
				BackgroundTransparency = 1,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2),
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				
				-- Title + Current value label
				TitleRow = React.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					LayoutOrder = 1,
				}, {
					UIListLayout = React.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 8),
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					Name = React.createElement("TextLabel", {
						Size = UDim2.new(0, 110, 1, 0),
						BackgroundTransparency = 1,
						Text = config.DisplayName or upgradeName,
						TextColor3 = Theme.Colors.Text,
						Font = Theme.Fonts.Bold,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					ValText = React.createElement("TextLabel", {
						Size = UDim2.new(0, 80, 1, 0),
						BackgroundTransparency = 1,
						Text = statValueText,
						TextColor3 = Color3.fromHex("00D5FF"), -- bright cyan active value
						Font = Theme.Fonts.Bold,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
				}),

				-- Description
				Desc = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					Text = config.Description or "",
					TextColor3 = Theme.Colors.TextSecondary,
					Font = Theme.Fonts.Regular,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2,
				}),

				-- Progress scale (lvl x of y)
				ProgressTracker = React.createElement("Frame", {
					Size = UDim2.new(1, -20, 0, 22),
					BackgroundTransparency = 1,
					LayoutOrder = 3,
				}, {
					ProgressBarComp = React.createElement(ProgressBar, {
						Size = UDim2.new(1, 0, 0, 12),
						Progress = progress,
					}),
					LvlText = React.createElement("TextLabel", {
						Size = UDim2.new(0, 50, 0, 12),
						Position = UDim2.new(1, 5, 0, 0),
						BackgroundTransparency = 1,
						Text = "Lvl " .. currentLevel .. "/" .. config.MaxLevel,
						TextColor3 = Theme.Colors.TextSecondary,
						Font = Theme.Fonts.Bold,
						TextSize = 10,
					})
				})
			}),

			-- Purchase button on the right
			PurchaseFrame = React.createElement("Frame", {
				Size = UDim2.new(0, 120, 0, 42),
				Position = UDim2.new(1, -135, 0.5, -21),
				BackgroundTransparency = 1,
			}, {
				Btn = React.createElement(Button, {
					Text = isMax and "MAX" or ("$ " .. string.gsub(string.format("%.0f", cost), "^(-?%d+)(%d%d%d)", "%1,%2")),
					Size = UDim2.new(1, 0, 1, 0),
					Color = isMax and Color3.fromHex("7F8C8D") or Color3.fromHex("2ECC71"), -- Green for buy, grey for max
					OnClick = function()
						if not isMax then
							handleUpgrade(upgradeName)
						end
					end
				})
			})
		})

		items[upgradeName] = itemCard
		layoutOrder = layoutOrder + 1
	end

	-- Return full themed shop window
	return React.createElement(Panel, {
		Size = UDim2.new(0, 520, 0, 420),
		Title = "UPGRADE SHOP",
		Visible = visible,
		OnClose = onClose,
	}, {
		ScrollingFrame = React.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Theme.Colors.Stroke,
			CanvasSize = UDim2.new(0, 0, 0, (layoutOrder - 1) * 90),
			BorderSizePixel = 0,
		}, items)
	})
end

return ShopWindow
