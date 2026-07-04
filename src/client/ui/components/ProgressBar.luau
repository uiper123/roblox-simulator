-- Candy Progress Bar Component (React version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Parent.theme.Theme)

local function ProgressBar(props)
	local size = props.Size or UDim2.new(1, 0, 0, 24)
	local position = props.Position or UDim2.new(0, 0, 0, 0)
	local progress = math.clamp(props.Progress or 0, 0, 1)
	local layoutOrder = props.LayoutOrder

	-- Smooth transition for progress bar fill using standard React.useRef
	local fillRef = React.useRef(nil)

	React.useEffect(function()
		local fill = fillRef.current
		if fill then
			local tween = TweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(progress, 0, 1, 0)
			})
			tween:Play()
			return function()
				tween:Cancel()
			end
		end
		return
	end, {progress})

	return React.createElement("Frame", {
		Size = size,
		Position = position,
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		LayoutOrder = layoutOrder,
	}, {
		UICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.5, 0), -- fully pill-shaped
		}),
		UIStroke = React.createElement("UIStroke", {
			Color = Theme.Colors.Stroke,
			Thickness = Theme.Sizes.StrokeThickness or 2,
		}),

		-- Active Fill Layer
		Fill = React.createElement("Frame", {
			ref = fillRef,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.fromHex("3AE374"), -- Vibrant bright green fill
			BorderSizePixel = 0,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			})
		})
	})
end

return ProgressBar
