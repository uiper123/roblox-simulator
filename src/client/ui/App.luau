-- Candy UI Root App Component (React version with Low-Poly Night Cemetery Background)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.React)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local Theme = require(script.Parent.theme.Theme)

local HUD = require(script.Parent.hud.HUD)
local ShopWindow = require(script.Parent.windows.ShopWindow)
local PetsWindow = require(script.Parent.windows.PetsWindow)
local DailyWindow = require(script.Parent.windows.DailyWindow)
local PromoWindow = require(script.Parent.windows.PromoWindow)
local RebirthWindow = require(script.Parent.windows.RebirthWindow)
local Toast = require(script.Parent.components.Toast)

local function App()
	local player = Players.LocalPlayer
	local [activeWindow, setActiveWindow] = React.useState(nil)
	local [money, setMoney] = React.useState(0)
	local [crystals, setCrystals] = React.useState(0)
	local [rebirths, setRebirths] = React.useState(0)
	local [bagCount, setBagCount] = React.useState(0)
	local [bagMax, setBagMax] = React.useState(10)
	local [toasts, setToasts] = React.useState({})

	-- Toast helper function
	local showToast = React.useCallback(function(text, notificationType)
		local id = HttpService:GenerateGUID(false)
		setToasts(function(currentToasts)
			local newToasts = table.clone(currentToasts)
			table.insert(newToasts, { Id = id, Text = text, Type = notificationType or "Info" })
			return newToasts
		end)
	end, {})

	-- Global registration of UIManager callbacks
	React.useEffect(function()
		local UIManager = _G.UIManager
		if UIManager then
			UIManager._openWindowCallback = function(name)
				setActiveWindow(name)
			end
			UIManager._showToastCallback = function(text, notificationType)
				showToast(text, notificationType)
			end
		end
		return function()
			if UIManager then
				UIManager._openWindowCallback = nil
				UIManager._showToastCallback = nil
			end
		end
	end, {showToast})

	-- Auto-dismiss toasts
	local removeToast = React.useCallback(function(toastId)
		setToasts(function(currentToasts)
			local newToasts = {}
			for _, t in ipairs(currentToasts) do
				if t.Id ~= toastId then
					table.insert(newToasts, t)
				end
			end
			return newToasts
		end)
	end, {})

	-- Sync attributes
	React.useEffect(function()
		local function updateMoney() setMoney(player:GetAttribute("Money") or 100000) end -- Defaulting to $ 100,000 for display
		local function updateCrystals() setCrystals(player:GetAttribute("Crystals") or 0) end
		local function updateRebirths() setRebirths(player:GetAttribute("Rebirths") or 0) end

		local c1 = player:GetAttributeChangedSignal("Money"):Connect(updateMoney)
		local c2 = player:GetAttributeChangedSignal("Crystals"):Connect(updateCrystals)
		local c3 = player:GetAttributeChangedSignal("Rebirths"):Connect(updateRebirths)

		updateMoney()
		updateCrystals()
		updateRebirths()

		return function()
			c1:Disconnect()
			c2:Disconnect()
			c3:Disconnect()
		end
	end, {})

	-- Sync bag data
	React.useEffect(function()
		local folder = player:WaitForChild("BagData", 5)
		if not folder then return end

		local function updateBag()
			local count = 0
			for _, item in ipairs(folder:GetChildren()) do
				if item:IsA("ValueBase") then
					count = count + (item.Value or 1)
				else
					count = count + 1
				end
			end
			setBagCount(count)
		end

		local conn = folder.ChildAdded:Connect(updateBag)
		local conn2 = folder.ChildRemoved:Connect(updateBag)
		updateBag()

		return function()
			conn:Disconnect()
			conn2:Disconnect()
		end
	end, {})

	-- Sync upgrades (BagMax)
	React.useEffect(function()
		local function updateBagMax()
			local lvl = player:GetAttribute("Upgrade_BagCapacity") or 1
			local UpgradeConfig = require(ReplicatedStorage.Shared.config.UpgradeConfig)
			local levels = UpgradeConfig.BagCapacity.Levels
			if levels[lvl] then
				setBagMax(levels[lvl].Value)
			end
		end

		local conn = player:GetAttributeChangedSignal("Upgrade_BagCapacity"):Connect(updateBagMax)
		updateBagMax()

		return function()
			conn:Disconnect()
		end
	end, {})

	-- Assemble background components (Cemetery elements)
	local bgElements = {
		-- Spooky violet gradient
		SkyGradient = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 0,
		}, {
			UIGradient = React.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("0E0A24")), -- Jet indigo
					ColorSequenceKeypoint.new(0.6, Color3.fromHex("1B0C3A")), -- Rich dark purple
					ColorSequenceKeypoint.new(1, Color3.fromHex("30104A")), -- Warm magenta ground glow
				}),
				Rotation = 90,
			})
		}),

		-- Big toy glowing moon
		Moon = React.createElement("Frame", {
			Size = UDim2.new(0, 140, 0, 140),
			Position = UDim2.new(0.5, -70, 0, 80),
			BackgroundColor3 = Color3.fromHex("FFFDF0"), -- Pure bright cream-white
			BorderSizePixel = 0,
			ZIndex = 1,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0), -- Perfect circle
			}),
			-- Outer soft neon-halo
			Glow = React.createElement("UIStroke", {
				Color = Color3.fromHex("E2A6FF"),
				Thickness = 8,
				Transparency = 0.4,
			})
		}),

		-- Star clusters (low-poly diamond shapes)
		Star1 = React.createElement("TextLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0.2, 40, 0.1, 20),
			BackgroundTransparency = 1,
			Text = "✦",
			TextColor3 = Color3.fromHex("FFD2FF"),
			TextSize = 24,
			ZIndex = 1,
		}),
		Star2 = React.createElement("TextLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0.8, -80, 0.15, -10),
			BackgroundTransparency = 1,
			Text = "✦",
			TextColor3 = Color3.fromHex("FFD2FF"),
			TextSize = 16,
			Rotation = 15,
			ZIndex = 1,
		}),
		Star3 = React.createElement("TextLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0.48, 100, 0.08, 10),
			BackgroundTransparency = 1,
			Text = "✦",
			TextColor3 = Color3.fromHex("FFD2FF"),
			TextSize = 20,
			Rotation = -10,
			ZIndex = 1,
		}),

		-- Left Spooky tree silhouette
		SpookyTreeLeft = React.createElement("Frame", {
			Size = UDim2.new(0, 160, 0, 280),
			Position = UDim2.new(0, -10, 1, -260),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			Trunk = React.createElement("Frame", {
				Size = UDim2.new(0, 30, 0, 150),
				Position = UDim2.new(0.5, -15, 0.45, 0),
				BackgroundColor3 = Color3.fromHex("0B071F"),
				BorderSizePixel = 0,
			}, {
				UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 8) }),
				-- Branch 1
				B1 = React.createElement("Frame", {
					Size = UDim2.new(0, 60, 0, 14),
					Position = UDim2.new(1, -10, 0.2, 0),
					Rotation = -35,
					BackgroundColor3 = Color3.fromHex("0B071F"),
					BorderSizePixel = 0,
				}),
				-- Branch 2
				B2 = React.createElement("Frame", {
					Size = UDim2.new(0, 50, 0, 12),
					Position = UDim2.new(-1, 0, 0.4, 0),
					Rotation = 25,
					BackgroundColor3 = Color3.fromHex("0B071F"),
					BorderSizePixel = 0,
				}),
			}),
		}),

		-- Right Spooky tree silhouette
		SpookyTreeRight = React.createElement("Frame", {
			Size = UDim2.new(0, 150, 0, 260),
			Position = UDim2.new(1, -140, 1, -240),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			Trunk = React.createElement("Frame", {
				Size = UDim2.new(0, 26, 0, 140),
				Position = UDim2.new(0.5, -13, 0.45, 0),
				BackgroundColor3 = Color3.fromHex("0B071F"),
				BorderSizePixel = 0,
			}, {
				UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
				-- Branch 1
				B1 = React.createElement("Frame", {
					Size = UDim2.new(0, 50, 0, 12),
					Position = UDim2.new(-1.1, 0, 0.25, 0),
					Rotation = 30,
					BackgroundColor3 = Color3.fromHex("0B071F"),
					BorderSizePixel = 0,
				}),
			})
		}),

		-- Hilly Graveyard Ground (Flat geometric layers)
		HillsBase = React.createElement("Frame", {
			Size = UDim2.new(1, 40, 0, 110),
			Position = UDim2.new(0, -20, 1, -100),
			BackgroundColor3 = Color3.fromHex("0B071F"), -- Dark base ground
			BorderSizePixel = 0,
			ZIndex = 3,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 20),
			}),
			UIStroke = React.createElement("UIStroke", {
				Color = Theme.Colors.Stroke,
				Thickness = 4,
			})
		}),

		-- Gravestone left
		GraveLeft = React.createElement("Frame", {
			Size = UDim2.new(0, 50, 0, 70),
			Position = UDim2.new(0.15, 0, 1, -125),
			BackgroundColor3 = Color3.fromHex("2E2D4A"), -- Stone grey-blue
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 12) }),
			UIStroke = React.createElement("UIStroke", { Color = Theme.Colors.Stroke, Thickness = 3 }),
			Label = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.new(0, 0, 0.4, 0),
				BackgroundTransparency = 1,
				Text = "RIP",
				TextColor3 = Color3.fromHex("151426"),
				Font = Theme.Fonts.Bold,
				TextSize = 14,
			}),
			Cross = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 0.1, 0),
				BackgroundTransparency = 1,
				Text = "†",
				TextColor3 = Color3.fromHex("151426"),
				Font = Theme.Fonts.Bold,
				TextSize = 16,
			})
		}),

		-- Gravestone right
		GraveRight = React.createElement("Frame", {
			Size = UDim2.new(0, 44, 0, 60),
			Position = UDim2.new(0.78, 10, 1, -115),
			BackgroundColor3 = Color3.fromHex("2D2947"),
			BorderSizePixel = 0,
			ZIndex = 2,
			Rotation = 10, -- Leaning
		}, {
			UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
			UIStroke = React.createElement("UIStroke", { Color = Theme.Colors.Stroke, Thickness = 2.5 }),
			Cross = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "†",
				TextColor3 = Color3.fromHex("151426"),
				Font = Theme.Fonts.Bold,
				TextSize = 22,
			})
		}),

		-- Floating Mist / Fog (semi-transparent soft white-purple frames)
		Mist = React.createElement("Frame", {
			Size = UDim2.new(1.2, 0, 0, 60),
			Position = UDim2.new(-0.1, 0, 1, -120),
			BackgroundColor3 = Color3.fromHex("E6D7FF"),
			BackgroundTransparency = 0.82, -- Very soft spooky fog
			BorderSizePixel = 0,
			ZIndex = 4,
		}, {
			UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 30) }),
		})
	}

	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		-- Spooky Graveyard Background layer
		Background = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			ZIndex = 1,
		}, bgElements),

		-- Foreground UI Layer
		Foreground = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 10,
		}, {
			-- Игровой HUD
			Hud = React.createElement(HUD, {
				OpenWindow = function(name)
					setActiveWindow(function(current)
						if current == name then return nil else return name end
					end)
				end,
				PlayerStats = {
					Money = money,
					Crystals = crystals,
					BagCount = bagCount,
					BagMax = bagMax,
				}
			}),

			-- Окна
			Shop = React.createElement(ShopWindow, {
				Visible = activeWindow == "Shop",
				OnClose = function() setActiveWindow(nil) end,
			}),

			Pets = React.createElement(PetsWindow, {
				Visible = activeWindow == "Pets",
				OnClose = function() setActiveWindow(nil) end,
			}),

			Daily = React.createElement(DailyWindow, {
				Visible = activeWindow == "Daily",
				OnClose = function() setActiveWindow(nil) end,
			}),

			Promo = React.createElement(PromoWindow, {
				Visible = activeWindow == "Promo",
				OnClose = function() setActiveWindow(nil) end,
			}),

			Rebirth = React.createElement(RebirthWindow, {
				Visible = activeWindow == "Rebirth",
				OnClose = function() setActiveWindow(nil) end,
			}),

			-- Уведомления (Toasts)
			ToastContainer = React.createElement("Frame", {
				Size = UDim2.new(0, 300, 0, 400),
				Position = UDim2.new(1, -320, 1, -420),
				BackgroundTransparency = 1,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					Padding = UDim.new(0, 10),
				}),
				Toasts = React.createElement(React.Fragment, {}, (function()
					local elements = {}
					for _, toast in ipairs(toasts) do
						elements[toast.Id] = React.createElement(Toast, {
							Text = toast.Text,
							Type = toast.Type,
							OnFinished = function() removeToast(toast.Id) end,
						})
					end
					return elements
				end)())
			})
		})
	})
end

return App
