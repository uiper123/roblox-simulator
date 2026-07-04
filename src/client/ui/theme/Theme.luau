-- UI Theme & Design System (Vibrant Toy-Like Mobile UI Style)
local Theme = {}

Theme.Colors = {
	-- Spooky yet vibrant night cemetery background colors
	Background = Color3.fromHex("0E0A24"), -- Deep purple-indigo
	BackgroundSecondary = Color3.fromHex("1E1540"), -- Spooky medium indigo
	Panel = Color3.fromHex("2E205D"), -- Rich neon-indigo for window panels
	PanelOpacity = 0.95,
	
	-- Vibrant toy-like status colors
	Success = Color3.fromHex("2ECC71"), -- Bright green
	Error = Color3.fromHex("E74C3C"), -- Candy red
	Warning = Color3.fromHex("F1C40F"), -- Bright yellow
	Info = Color3.fromHex("3498DB"), -- Soft blue
	Accent = Color3.fromHex("E056FD"), -- Electric neon magenta-purple
	
	-- High contrast crisp text
	Text = Color3.fromHex("FFFFFF"),
	TextSecondary = Color3.fromHex("BCC8FC"), -- Soft lavender-blue
	Stroke = Color3.fromHex("0E0720"), -- Deep dark outline for comic / toy effect
	
	-- Bright neon green / yellow money styles
	MoneyGreen = Color3.fromHex("2ECC71"),
	NeonRebirth = Color3.fromHex("D800FF"), -- Purple neon lightning
}

Theme.Fonts = {
	Regular = Enum.Font.FredokaOne, -- Clean, toy-like round font
	Bold = Enum.Font.FredokaOne,
	Title = Enum.Font.FredokaOne,
}

Theme.Sizes = {
	CornerRadius = UDim.new(0, 14), -- Rounded cartoonish corners
	StrokeThickness = 3.5, -- Chunky outlines
}

return Theme
