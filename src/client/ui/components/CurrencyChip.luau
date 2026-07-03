-- Компонент значка валюты (CurrencyChip) с анимациями
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.theme.Theme)

local CurrencyChipFactory = {}

function CurrencyChipFactory.create(options)
	local size = options.Size or UDim2.new(0, 140, 0, 36)
	local position = options.Position or UDim2.new(0, 0, 0, 0)
	local currencyType = options.CurrencyType or "Money" -- "Money" или "Crystals"
	local parent = options.Parent

	-- 1. Корпус фишки (Пилюля)
	local container = Instance.new("Frame")
	container.Name = "CurrencyChip_" .. currencyType
	container.Size = size
	container.Position = position
	container.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(1, 0) -- Полное скругление
	containerCorner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = Theme.Sizes.BorderWidth
	stroke.Color = Theme.Colors.Stroke
	stroke.Parent = container

	-- 2. Иконка валюты
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 30, 0, 30)
	icon.Position = UDim2.new(0, 4, 0.5, -15)
	icon.BackgroundTransparency = 1
	icon.Font = Theme.Fonts.Title
	icon.TextSize = 18
	icon.Text = (currencyType == "Money") and "💵" or "💎"
	icon.Parent = container

	-- 3. Текст баланса
	local label = Instance.new("TextLabel")
	label.Name = "BalanceLabel"
	label.Size = UDim2.new(1, -44, 1, 0)
	label.Position = UDim2.new(0, 36, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Theme.Fonts.Bold
	label.TextSize = 16
	label.TextColor3 = (currencyType == "Money") and Theme.Colors.Success or Theme.Colors.Neon
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "0"
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Theme.Colors.Stroke
	label.Parent = container

	-- Состояние баланса
	local currentValue = 0

	-- Вспомогательная функция форматирования чисел
	local function formatNumber(value: number): string
		local formatted = tostring(value)
		while true do  
			local k
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if k == 0 then
				break
			end
		end
		return formatted
	end

	-- API управления
	local api = {}
	api.Instance = container

	-- Плавное прокручивание счета (Count-up animation) с улучшенными анимациями
	function api.SetValue(newValue: number)
		local diff = newValue - currentValue
		if diff == 0 then return end

		-- Если баланс изменился, рисуем эффект "+N" или "-N"
		if currentValue > 0 then
			task.spawn(function()
				local deltaLabel = Instance.new("TextLabel")
				deltaLabel.Name = "DeltaLabel"
				deltaLabel.Size = UDim2.new(0, 100, 0, 20)
				deltaLabel.Position = UDim2.new(0.5, -50, 0, -25)
				deltaLabel.BackgroundTransparency = 1
				deltaLabel.Font = Theme.Fonts.Title
				deltaLabel.TextSize = 18
				deltaLabel.TextStrokeTransparency = 0.3
				deltaLabel.TextStrokeColor3 = Theme.Colors.Stroke
				
				if diff > 0 then
					deltaLabel.TextColor3 = (currencyType == "Money") and Theme.Colors.Success or Theme.Colors.Neon
					deltaLabel.Text = "+" .. formatNumber(diff)
				else
					deltaLabel.TextColor3 = Theme.Colors.Error or Color3.fromRGB(255, 75, 75)
					deltaLabel.Text = "-" .. formatNumber(math.abs(diff))
				end
				
				deltaLabel.Parent = container

				-- Анимация взлета и растворения дельты
				local upTween = TweenService:Create(deltaLabel, TweenInfo.new(1.0, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = UDim2.new(0.5, -50, 0, -55),
					TextTransparency = 1,
					TextStrokeTransparency = 1
				})
				upTween:Play()
				upTween.Completed:Connect(function()
					deltaLabel:Destroy()
				end)

				-- Анимация самого контейнера (фишки)
				if diff < 0 then
					-- Эффект тряски при покупке (уменьшении баланса)
					local originalPos = container.Position
					task.spawn(function()
						for i = 1, 6 do
							local offset = (i % 2 == 0) and 3 or -3
							container.Position = originalPos + UDim2.new(0, offset, 0, 0)
							task.wait(0.04)
						end
						container.Position = originalPos
					end)
				else
					-- Эффект пульсации при продаже (увеличении баланса)
					local originalSize = container.Size
					local originalPos = container.Position
					local bounceInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
					local bounceTween = TweenService:Create(container, bounceInfo, {
						Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 12, originalSize.Y.Scale, originalSize.Y.Offset + 6),
						Position = originalPos + UDim2.new(0, -6, 0, -3)
					})
					bounceTween:Play()
				end
			end)
		end

		-- Анимация накрутки цифр вверх/вниз
		local duration = 0.5
		local startTime = tick()
		local startVal = currentValue
		currentValue = newValue

		task.spawn(function()
			while tick() - startTime < duration do
				local elapsed = tick() - startTime
				local progress = math.clamp(elapsed / duration, 0, 1)
				local lerpVal = math.floor(startVal + (newValue - startVal) * progress)
				
				label.Text = formatNumber(lerpVal)
				
				-- Эффект подпрыгивания цифр (пульсация масштаба)
				if progress < 0.5 then
					label.TextSize = 17
				else
					label.TextSize = 16
				end
				
				task.wait()
			end
			label.Text = formatNumber(newValue)
			label.TextSize = 16
		end)
	end

	function api.Destroy()
		container:Destroy()
	end

	return api
end

return CurrencyChipFactory
