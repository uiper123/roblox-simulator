-- Сервис управления инвентарем игрока на сервере (в оперативной памяти)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.config.GameConfig)
local GhostConfig = require(ReplicatedStorage.Shared.config.GhostConfig)

local InventoryService = {}
local inventories = {} -- Ключ: UserId, Значение: { Ghosts = { "Common", ... }, MaxCapacity = X }

-- Создать физический инструмент призрака в рюкзаке игрока
local function createGhostTool(player: Player, rarity: string)
	local conf = GhostConfig[rarity]
	if not conf then return end

	local tool = Instance.new("Tool")
	tool.Name = conf.Name
	tool.RequiresHandle = true
	tool:SetAttribute("Rarity", rarity)
	tool:SetAttribute("IsGhost", true)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1.2, 1.2, 1.2)
	handle.Shape = Enum.PartType.Ball
	handle.Material = Enum.Material.Neon
	handle.CanCollide = false
	handle.Color = conf.Color
	handle.Parent = tool

	-- Добавим красивый ParticleEmitter в Handle
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(conf.Color)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particles.Lifetime = NumberRange.new(0.5, 1.2)
	particles.Speed = NumberRange.new(1, 3)
	particles.SpreadAngle = Vector2.new(-180, 180)
	particles.Parent = handle

	-- Добавим BillboardGui над призраком
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "GhostTag"
	billboard.Size = UDim2.new(0, 150, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = handle

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextSize = 14
	textLabel.TextColor3 = conf.Color
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0.2
	textLabel.Text = "👻 " .. conf.Name .. " 👻"
	textLabel.Parent = billboard

	tool.Parent = player.Backpack
end

-- Инициализировать или получить инвентарь игрока
function InventoryService.getInventory(player: Player)
	local userId = player.UserId
	if not inventories[userId] then
		inventories[userId] = {
			Ghosts = {},
			MaxCapacity = GameConfig.DefaultBagCapacity
		}
	end
	return inventories[userId]
end

-- Добавить призрака в инвентарь (возвращает true при успехе, false если рюкзак полон)
function InventoryService.addGhost(player: Player, rarity: string): boolean
	local inv = InventoryService.getInventory(player)
	if #inv.Ghosts < inv.MaxCapacity then
		table.insert(inv.Ghosts, rarity)
		
		-- Создаем физический инструмент призрака
		createGhostTool(player, rarity)
		
		return true
	end
	return false
end

-- Очистить рюкзак и вернуть список привидений
function InventoryService.clearInventory(player: Player): {string}
	local inv = InventoryService.getInventory(player)
	local clearedGhosts = inv.Ghosts
	inv.Ghosts = {}
	
	-- Удалить физические инструменты призраков у игрока (в Backpack и Character)
	local character = player.Character
	if character then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsGhost") then
				child:Destroy()
			end
		end
	end
	
	local backpack = player.Backpack
	if backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsGhost") then
				child:Destroy()
			end
		end
	end

	return clearedGhosts
end

-- Проверка, заполнен ли рюкзак
function InventoryService.isFull(player: Player): boolean
	local inv = InventoryService.getInventory(player)
	return #inv.Ghosts >= inv.MaxCapacity
end

-- Получить текущее количество привидений в рюкзаке
function InventoryService.getGhostsCount(player: Player): number
	local inv = InventoryService.getInventory(player)
	return #inv.Ghosts
end

-- Установить максимальную вместимость рюкзака
function InventoryService.setMaxCapacity(player: Player, capacity: number)
	local inv = InventoryService.getInventory(player)
	inv.MaxCapacity = capacity
end

-- Очистка памяти при выходе игрока
function InventoryService.removePlayer(player: Player)
	inventories[player.UserId] = nil
end

return InventoryService
