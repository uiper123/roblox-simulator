-- Candy Panel Component (Vibrant Toy-Like Mobile UI Style)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)
local CurrencyChip = require(script.Parent.Parent.components.CurrencyChip)
local Button = require(script.Parent.Parent.components.Button)

local function Panel(props)
	local size = props.Size or UDim2.new(0, 400, 0, 300)
	local position = props.Position or UDim2.new(0.5, 0, 0.5, 0)
	local anchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
	local title = props.Title or "WINDOW"
	local onClose = props.OnClose
	local visible = props.Visible
	local children = props[React.Children]

	if visible == false then return nil end

	return React.createElement("Frame", {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundColor3 = Theme.Colors.Panel,
		BackgroundTransparency = 0.05, -- Rich fully-colored backing
		BorderSizePixel = 0,
	}, {
		-- Heavy Rounded corners & outlines for Toy design
		UICorner = React.createElement("UICorner", {
			CornerRadius = Theme.Sizes.CornerRadius,
		}),
		UIStroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = Theme.Sizes.StrokeThickness,
			ApplyStrokeToMode = Enum.ApplyStrokeToMode.Border,
		}),

		-- Window Header Container
		Header = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 55),
			Position = UDim2.new(0, 0, 0, -25), -- Slightly floating banner style
			BackgroundTransparency = 1,
			ZIndex = 3,
		}, {
			-- Toy Banner Background
			Banner = React.createElement("Frame", {
				Size = UDim2.new(0.7, 0, 1, 0),
				Position = UDim2.new(0.15, 0, 0, 0),
				BackgroundColor3 = Color3.fromHex("F1C40F"), -- Sunny yellow banner
				BorderSizePixel = 0,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = Theme.Sizes.CornerRadius,
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Theme.Colors.Stroke,
					Thickness = Theme.Sizes.StrokeThickness,
					ApplyStrokeToMode = Enum.ApplyStrokeToMode.Border,
				}),
				
				-- Title Text
				Label = React.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = string.upper(title),
					TextColor3 = Theme.Colors.Text,
					Font = Theme.Fonts.Title,
					TextSize = 22,
					TextStrokeColor3 = Theme.Colors.Stroke,
					TextStrokeTransparency = 0,
				})
			}),

			-- Toy close button
			CloseBtn = onClose and React.createElement("Frame", {
				Size = UDim2.new(0, 45, 0, 45),
				Position = UDim2.new(1, -25, 0, 5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
			}, {
				Btn = React.createElement(Button, {
					Text = "❌",
					Size = UDim2.new(1, 0, 1, 0),
					Color = Color3.fromHex("E74C3C"), -- Red toy close
					OnClick = onClose,
				})
			}) or nil,
		}),

		-- Content Area
		Content = React.createElement("Frame", {
			Size = UDim2.new(1, -30, 1, -65),
			Position = UDim2.new(0, 15, 0, 45),
			BackgroundTransparency = 1,
		}, children)
	})
end

return Panel
