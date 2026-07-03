-- Сервис управления перерождениями игроков на сервере
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RebirthConfig = require(ReplicatedStorage.Shared.config.RebirthConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CurrencyService = require(ServerScriptService.Server.CurrencyService)
local UpgradeService = require(ServerScriptService.Server.UpgradeService)

local RebirthService = {}
local playerRebirths = {} -- Ключ: UserId, Значение: кол-во ребирхов (number)

-- Инициализация сервиса
function RebirthService.init()
	local requestRebirthEvent = Remotes.getEvent("RequestRebirth")
	requestRebirthEvent.OnServerEvent:Connect(RebirthService.onRebirthRequest)
	
	print("[REBIRTH SERVICE] Сервис перерождений успешно запущен!")
end

-- Настройка ребирхов при входе игрока
function RebirthService.setupPlayer(player: Player, loadedRebirths: number?)
	local userId = player.UserId
	local rebirthCount = loadedRebirths or 0
	
	playerRebirths[userId] = rebirthCount
	player:SetAttribute("Rebirths", rebirthCount)

	-- Создаем или находим лидерборд
	local leaderstats = player:WaitForChild("leaderstats", 5)
	if leaderstats then
		local rebirthsValue = Instance.new("IntValue")
		rebirthsValue.Name = "Rebirths"
		rebirthsValue.Value = rebirthCount
		rebirthsValue.Parent = leaderstats
	end
end

-- Обработка запроса перерождения от клиента
function RebirthService.onRebirthRequest(player: Player)
	local userId = player.UserId
	local currentRebirths = playerRebirths[userId]
	
	if not currentRebirths then return end

	local cost = RebirthConfig.getCost(currentRebirths)
	local currentMoney = CurrencyService.get(player, "Money")

	-- Проверяем, хватает ли монет
	if currentMoney >= cost then
		-- Списываем все монеты (сбрасываем до 0)
		CurrencyService.spend(player, "Money", currentMoney)

		-- Увеличиваем количество перерождений
		local newRebirths = currentRebirths + 1
		playerRebirths[userId] = newRebirths
		player:SetAttribute("Rebirths", newRebirths)

		-- Обновляем в лидерстатах
		local leaderstats = player:FindFirstChild("leaderstats")
		local rebirthsValue = leaderstats and leaderstats:FindFirstChild("Rebirths")
		if rebirthsValue then
			rebirthsValue.Value = newRebirths
		end

		-- Сбрасываем апгрейды до 1 уровня
		UpgradeService.resetPlayer(player)

		-- Сбрасываем разблокировки локаций
		player:SetAttribute("Unlocked_ForestArea", false)
		player:SetAttribute("Unlocked_MansionArea", false)

		-- Отправляем уведомление
		local multiplier = RebirthService.getMultiplier(player)
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, string.format("Перерождение совершено! Множитель монет теперь: x%.1f!", multiplier))

		print(string.format("[REBIRTH SERVICE] Игрок %s совершил перерождение #%d. Сброшено монет: %d", player.Name, newRebirths, currentMoney))
	else
		local notificationEvent = Remotes.getEvent("ShowNotification")
		notificationEvent:FireClient(player, string.format("Недостаточно монет для перерождения! Нужно: $%d", cost))
	end
end

-- Получить текущий множитель перерождений (1.0 + Rebirths * MultiplierPerRebirth)
function RebirthService.getMultiplier(player: Player): number
	local userId = player.UserId
	local rebirthCount = playerRebirths[userId] or 0
	return 1.0 + (rebirthCount * RebirthConfig.MultiplierPerRebirth)
end

-- Получить данные сохранения
function RebirthService.getSaveData(player: Player): number
	return playerRebirths[player.UserId] or 0
end

-- Очистка памяти при выходе
function RebirthService.removePlayer(player: Player)
	playerRebirths[player.UserId] = nil
end

return RebirthService
