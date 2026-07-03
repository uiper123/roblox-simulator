-- Общие настройки игры Ghost Hunter Simulator (Фаза 1)
local GameConfig = {
	-- Стартовые параметры игрока
	StartingMoney = 0,
	StartingCrystals = 0,
	DefaultBagCapacity = 10,

	-- Настройки спавна привидений
	SpawnInterval = 3,           -- Интервал спавна в секундах
	MaxGhosts = 10,              -- Максимальное количество привидений на карте

	-- Настройки детектора
	DetectorRadius = 50,         -- Радиус действия детектора в студах

	-- Параметры тестовой карты
	SpawnZoneSize = Vector3.new(60, 1, 60),
	SpawnZonePosition = Vector3.new(0, 0.5, 0),
}

return GameConfig
