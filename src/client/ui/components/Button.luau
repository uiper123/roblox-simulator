-- Candy 3D Button Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function playSound(id)
	if not id or id == "" then return end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
end

local function Button(props)
	local text = props.Text or "BUTTON"
	local size = props.Size or UDim2.new(0, 200, 0, 50)
	local position = props.Position or UDim2.new(0, 0, 0, 0)
	local anchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	local onClick = props.OnClick
	local color = props.Color or Theme.Colors.Accent
	local layoutOrder = props.LayoutOrder
	local neon = props.Neon or false

	local isHovered, setHovered = React.useState(false)
	local isPressed, setPressed = React.useState(false)

	-- Multi-layered "Plastic 3D Button" style
	-- Shadow layer (dark base) & face layer (slid down on press)
	local faceColor = color
	if isPressed then
		faceColor = color:Lerp(Color3.new(0, 0, 0), 0.15)
	elseif isHovered then
		faceColor = color:Lerp(Color3.new(1, 1, 1), 0.1)
	end

	local shadowColor = color:Lerp(Color3.new(0, 0, 0), 0.4)
	local strokeColor = Theme.Colors.Stroke

	-- Bright pinkish/purple neon glow if neon = true
	local neonColorSeq = nil
	if neon then
		faceColor = Color3.fromHex("B900FF") -- Purple-neon base
		shadowColor = Color3.fromHex("540080")
		neonColorSeq = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("D800FF")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("FF0077"))
		})
	end

	return React.createElement("Frame", {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
	}, {
		-- Shadow base
		Shadow = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -4),
			Position = UDim2.new(0, 0, 0, 4),
			BackgroundColor3 = shadowColor,
			BorderSizePixel = 0,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			}),
			UIStroke = React.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = Theme.Sizes.StrokeThickness,
				ApplyStrokeToMode = Enum.ApplyStrokeToMode.Border,
			})
		}),

		-- Sliding Face
		Face = React.createElement("ImageButton", {
			Size = UDim2.new(1, 0, 1, -4),
			Position = isPressed and UDim2.new(0, 0, 0, 4) or UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = neon and Color3.new(1, 1, 1) or faceColor,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			
			[React.Event.MouseEnter] = function()
				setHovered(true)
				playSound("rbxassetid://6894541724") -- Pop hover sound
			end,
			[React.Event.MouseLeave] = function()
				setHovered(false)
				setPressed(false)
			end,
			[React.Event.MouseButton1Down] = function()
				setPressed(true)
				playSound("rbxassetid://6894541460") -- Click down sound
			end,
			[React.Event.MouseButton1Up] = function()
				if isPressed then
					setPressed(false)
					if onClick then onClick() end
				end
			end,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = Theme.Sizes.CornerRadius,
			}),
			UIStroke = React.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = Theme.Sizes.StrokeThickness,
				ApplyStrokeToMode = Enum.ApplyStrokeToMode.Border,
			}),
			-- Neon gradient if true
			Gradient = neon and React.createElement("UIGradient", {
				Color = neonColorSeq,
				Rotation = 45,
			}) or nil,
			-- Label
			Label = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Colors.Text,
				Font = Theme.Fonts.Bold,
				TextSize = 18,
				TextStrokeColor3 = strokeColor,
				TextStrokeTransparency = 0.1,
			})
		})
	})
end

return Button
