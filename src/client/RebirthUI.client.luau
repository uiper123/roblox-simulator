-- Клиентский контроллер UI перерождений (Rebirth UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сетевые события
local requestRebirthEvent = Remotes.getEvent("RequestRebirth")

-- Ссылка на элементы UI
local screenGui = nil
local rebirthFrame = nil
local rebirthsLabel = nil
local multiplierLabel = nil
local costLabel = nil
local rebirthBtnAction = nil

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

-- Обновление текстов и кнопок в меню
local function updateRebirthUI()
	if not rebirthFrame then return end

	local rebirths = player:GetAttribute("Rebirths") or 0
	local money = player:GetAttribute("Money") or 0

	local cost = RebirthConfig.getCost(rebirths)
	local multiplier = 1.0 + (rebirths * RebirthConfig.MultiplierPerRebirth)

	rebirthsLabel.Text = string.format("Текущие перерождения: %d", rebirths)
	multiplierLabel.Text = string.format("Множитель монет: x%.1f", multiplier)
	costLabel.Text = string.format("Цена следующего перерождения: $%s", formatNumber(cost))

	-- Красим кнопку покупки
	if money >= cost then
		rebirthBtnAction.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Зеленая
		rebirthBtnAction.AutoButtonColor = true
	else
		rebirthBtnAction.BackgroundColor3 = Color3.fromRGB(192, 57, 43) -- Красная
		rebirthBtnAction.AutoButtonColor = false
	end
end

-- Создание интерфейса
local function createRebirthUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RebirthHUD"
	screenGui.ResetOnSpawn = false

	-- Кнопка открытия меню перерождений на левой стороне экрана
	local openBtn = Instance.new("TextButton")
	openBtn.Name = "RebirthButton"
	openBtn.Size = UDim2.new(0, 80, 0, 45)
	openBtn.Position = UDim2.new(0, 20, 0.45, 110) -- Под кнопкой PETS
	openBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96) -- Красивый зеленый
	openBtn.BorderSizePixel = 0
	openBtn.Font = Enum.Font.FredokaOne
	openBtn.TextSize = 13
	openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	openBtn.Text = "REBIRTH"
	openBtn.Parent = screenGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = openBtn

	-- Главная панель меню
	rebirthFrame = Instance.new("Frame")
	rebirthFrame.Name = "RebirthFrame"
	rebirthFrame.Size = UDim2.new(0, 360, 0, 270)
	rebirthFrame.Position = UDim2.new(0.5, -180, 0.5, -135)
	rebirthFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	rebirthFrame.BackgroundTransparency = 0.15
	rebirthFrame.BorderSizePixel = 0
	rebirthFrame.Visible = false
	rebirthFrame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = rebirthFrame

	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Name = "TitleLabel"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 20
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "ПЕРЕРОЖДЕНИЕ"
	title.Parent = rebirthFrame

	-- Кнопка закрытия
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -40, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "X"
	closeBtn.Parent = rebirthFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	-- Пояснительный текст
	local desc = Instance.new("TextLabel")
	desc.Name = "DescLabel"
	desc.Size = UDim2.new(1, -40, 0, 45)
	desc.Position = UDim2.new(0, 20, 0, 50)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.SourceSans
	desc.TextSize = 13
	desc.TextColor3 = Color3.fromRGB(180, 180, 190)
	desc.TextWrapped = true
	desc.Text = "Сбрасывает ваши монеты, локации и уровни улучшений в обмен на постоянный множитель монет!"
	desc.Parent = rebirthFrame

	-- Статистика: текущие ребирхи
	rebirthsLabel = Instance.new("TextLabel")
	rebirthsLabel.Name = "RebirthsLabel"
	rebirthsLabel.Size = UDim2.new(1, -40, 0, 25)
	rebirthsLabel.Position = UDim2.new(0, 20, 0, 105)
	rebirthsLabel.BackgroundTransparency = 1
	rebirthsLabel.Font = Enum.Font.FredokaOne
	rebirthsLabel.TextSize = 15
	rebirthsLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
	rebirthsLabel.Text = "Текущие перерождения: 0"
	rebirthsLabel.Parent = rebirthFrame

	-- Множитель монет
	multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Name = "MultiplierLabel"
	multiplierLabel.Size = UDim2.new(1, -40, 0, 25)
	multiplierLabel.Position = UDim2.new(0, 20, 0, 130)
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.Font = Enum.Font.FredokaOne
	multiplierLabel.TextSize = 15
	multiplierLabel.TextColor3 = Color3.fromRGB(46, 204, 113) -- Зеленый
	multiplierLabel.Text = "Множитель монет: x1.0"
	multiplierLabel.Parent = rebirthFrame

	-- Цена следующего
	costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(1, -40, 0, 25)
	costLabel.Position = UDim2.new(0, 20, 0, 155)
	costLabel.BackgroundTransparency = 1
	costLabel.Font = Enum.Font.FredokaOne
	costLabel.TextSize = 14
	costLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Золотой
	costLabel.Text = "Цена следующего перерождения: $10,000"
	costLabel.Parent = rebirthFrame

	-- Кнопка совершения перерождения
	rebirthBtnAction = Instance.new("TextButton")
	rebirthBtnAction.Name = "ActionButton"
	rebirthBtnAction.Size = UDim2.new(0, 200, 0, 45)
	rebirthBtnAction.Position = UDim2.new(0.5, -100, 1, -65)
	rebirthBtnAction.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	rebirthBtnAction.BorderSizePixel = 0
	rebirthBtnAction.Font = Enum.Font.FredokaOne
	rebirthBtnAction.TextSize = 16
	rebirthBtnAction.TextColor3 = Color3.fromRGB(255, 255, 255)
	rebirthBtnAction.Text = "ПЕРЕРОДИТЬСЯ"
	rebirthBtnAction.Parent = rebirthFrame

	local actCorner = Instance.new("UICorner")
	actCorner.CornerRadius = UDim.new(0, 8)
	actCorner.Parent = rebirthBtnAction

	-- Открытие/Закрытие по клику
	openBtn.MouseButton1Click:Connect(function()
		rebirthFrame.Visible = not rebirthFrame.Visible
		if rebirthFrame.Visible then
			updateRebirthUI()
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		rebirthFrame.Visible = false
	end)

	rebirthBtnAction.MouseButton1Click:Connect(function()
		requestRebirthEvent:FireServer()
	end)

	screenGui.Parent = playerGui
end

-- Инициализация и слушатели событий изменений
local function init()
	createRebirthUI()

	-- Слушаем изменение монет и ребирхов для перерисовки
	player:GetAttributeChangedSignal("Money"):Connect(updateRebirthUI)
	player:GetAttributeChangedSignal("Rebirths"):Connect(updateRebirthUI)

	updateRebirthUI()
end

init()
print("RebirthUI client controller started")
