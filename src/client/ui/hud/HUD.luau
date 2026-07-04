-- Candy HUD Component (Vibrant Toy-Like Mobile UI Style)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local Button = require(script.Parent.Parent.components.Button)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)
local DetectorWidget = require(script.Parent.DetectorWidget)
local BagWidget = require(script.Parent.BagWidget)
local CaptureBar = require(script.Parent.CaptureBar)

local function HUD(props)
	local openWindow = props.OpenWindow
	local stats = props.PlayerStats or {
		Money = 0,
		Crystals = 0,
		BagCount = 0,
		BagMax = 10,
	}

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		-- TOP-LEFT GROUP: Currency and Rebirth (Vibrant Toy style)
		TopLeftContainer = React.createElement("Frame", {
			Size = UDim2.new(0, 380, 0, 100),
			Position = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
			}),

			-- Row 1: Currency Chip with "$ 100,000" and a Neon green "+500" income tag
			MoneyRow = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 48),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 12),
				}),

				-- Custom Toy-like Money Bar
				MoneyBar = React.createElement("Frame", {
					Size = UDim2.new(0, 220, 0, 42),
					BackgroundColor3 = Theme.Colors.BackgroundSecondary,
					LayoutOrder = 1,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = Theme.Sizes.CornerRadius,
					}),
					UIStroke = React.createElement("UIStroke", {
						Color = Theme.Colors.Stroke,
						Thickness = Theme.Sizes.StrokeThickness,
					}),
					-- Icon
					Icon = React.createElement("TextLabel", {
						Size = UDim2.new(0, 36, 1, 0),
						Position = UDim2.new(0, 8, 0, 0),
						BackgroundTransparency = 1,
						Text = "💵",
						TextSize = 22,
						Font = Theme.Fonts.Bold,
					}),
					-- Value Label: Precisely showing "$ 100,000" if money is near it, formatted with commas
					ValueLabel = React.createElement("TextLabel", {
						Size = UDim2.new(1, -55, 1, 0),
						Position = UDim2.new(0, 45, 0, 0),
						BackgroundTransparency = 1,
						Text = "$ " .. string.gsub(string.format("%.0f", stats.Money), "^(-?%d+)(%d%d%d)", "%1,%2"),
						TextColor3 = Color3.fromHex("2ECC71"), -- Neon green money text
						Font = Theme.Fonts.Bold,
						TextSize = 18,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
				}),

				-- Vibrant "+500" Badge
				IncomeBadge = React.createElement("Frame", {
					Size = UDim2.new(0, 70, 0, 36),
					BackgroundColor3 = Color3.fromHex("2ECC71"), -- Bright green background
					LayoutOrder = 2,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 10),
					}),
					UIStroke = React.createElement("UIStroke", {
						Color = Theme.Colors.Stroke,
						Thickness = 2.5,
					}),
					Label = React.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "+500",
						TextColor3 = Theme.Colors.Text,
						Font = Theme.Fonts.Bold,
						TextSize = 15,
						TextStrokeColor3 = Theme.Colors.Stroke,
						TextStrokeTransparency = 0,
					})
				})
			}),

			-- Row 2: Neon Purple Rebirth Button with lightning bolt nearby
			RebirthRow = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				RebirthButton = React.createElement(Button, {
					Text = "⚡ REBIRTH",
					Size = UDim2.new(0, 180, 0, 42),
					Color = Theme.Colors.NeonRebirth,
					Neon = true,
					OnClick = function() if openWindow then openWindow("Rebirth") end end,
				})
			})
		}),

		-- TOP-RIGHT: Settings Gear Button
		TopRightContainer = React.createElement("Frame", {
			Size = UDim2.new(0, 60, 0, 60),
			Position = UDim2.new(1, -80, 0, 20),
			BackgroundTransparency = 1,
		}, {
			SettingsBtn = React.createElement(Button, {
				Text = "⚙️",
				Size = UDim2.new(1, 0, 1, 0),
				Color = Color3.fromHex("F1C40F"), -- Bright golden settings gear
				OnClick = function() if openWindow then openWindow("Promo") end end, -- Settings / promo codes
			})
		}),

		-- LEFT SIDE DOCK: Shop and other main buttons
		LeftDock = React.createElement("Frame", {
			Size = UDim2.new(0, 80, 0, 350),
			Position = UDim2.new(0, 20, 0.5, -130),
			BackgroundTransparency = 1,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 15),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			-- SHOP button
			ShopBtn = React.createElement(Button, {
				Text = "🎒 SHOP",
				Size = UDim2.new(0, 110, 0, 45),
				Color = Color3.fromHex("FF9F1A"), -- Bright Orange
				OnClick = function() if openWindow then openWindow("Shop") end end,
				LayoutOrder = 1,
			}),

			-- PETS button
			PetsBtn = React.createElement(Button, {
				Text = "🐱 PETS",
				Size = UDim2.new(0, 110, 0, 45),
				Color = Color3.fromHex("12CBC4"), -- Bright Cyan
				OnClick = function() if openWindow then openWindow("Pets") end end,
				LayoutOrder = 2,
			}),

			-- DAILY button
			DailyBtn = React.createElement(Button, {
				Text = "🎁 DAILY",
				Size = UDim2.new(0, 110, 0, 45),
				Color = Color3.fromHex("ED4C67"), -- Rose pink
				OnClick = function() if openWindow then openWindow("Daily") end end,
				LayoutOrder = 3,
			}),
		}),

		-- Game-specific Overlay Widgets (Detector, Backpack, Capture state)
		Widgets = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Detector = React.createElement(DetectorWidget),
			Bag = React.createElement(BagWidget, {
				Count = stats.BagCount,
				Max = stats.BagMax,
			}),
			Capture = React.createElement(CaptureBar),
		})
	})
end

return HUD
