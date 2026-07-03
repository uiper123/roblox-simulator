-- Конфигурация перерождений для Ghost Hunter Simulator
local RebirthConfig = {
	BaseCost = 10000, -- Базовая цена первого перерождения
	MultiplierPerRebirth = 1.0, -- Множитель к монетам за каждое перерождение (+100% за rebirth)

	-- Вычисление стоимости следующего перерождения
	getCost = function(currentRebirths: number): number
		return RebirthConfig.BaseCost * (currentRebirths + 1)
	end
}

return RebirthConfig
