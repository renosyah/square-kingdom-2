extends BaseData
class_name ArmyCardData

const COMMON = 0
const UNCOMMON = 1
const RARE = 2
const EPIC = 3
const LEGENDARY = 4

export var id :int
export var card_name:String
export var detail:String
export var rarity:int
export var icon_index:int

export var spawn_time_decrease_percentage :float # 0.1 - 1.0
export var spawn_time_decrease_value :float # 1.0 - 100.0

export var speed_bonus_percentage :float # 0.1 - 1.0
export var speed_bonus_value :float # 1.0 - 100.0

export var melee_speed_bonus_percentage :float # 0.1 - 1.0
export var melee_speed_bonus_value :float # 1.0 - 100.0

export var range_speed_bonus_percentage :float # 0.1 - 1.0
export var range_speed_bonus_value :float # 1.0 - 100.0

export var hp_bonus_percentage :float # 0.1 - 1.0
export var hp_bonus_value:int # 1 - 100

export var heal_bonus_percentage :float # 0.1 - 1.0
export var heal_bonus_value :int # 1 - 100

export var extra_buff_duration:float # 1.0 - 100.0
export var extra_debuff_duration:float # 1.0 - 100.0

export var extra_buff_value: float # 1.0 - 100.0
export var extra_debuff_value :float # 1.0 - 100.0

func generate_card():
	id = randi()
	
	card_name = ""
	detail = ""

	spawn_time_decrease_percentage = 0.0
	spawn_time_decrease_value = 0.0

	speed_bonus_percentage = 0.0
	speed_bonus_value = 0.0

	melee_speed_bonus_percentage = 0.0
	melee_speed_bonus_value = 0.0

	range_speed_bonus_percentage = 0.0
	range_speed_bonus_value = 0.0

	hp_bonus_percentage = 0.0
	hp_bonus_value = 0

	heal_bonus_percentage = 0
	heal_bonus_value = 0

	extra_buff_duration = 0.0
	extra_debuff_duration = 0.0

	extra_buff_value = 0.0
	extra_debuff_value = 0.0

	var roll = randf()
	var stat_count = 1

	if roll <= 0.50:
		rarity = COMMON
		stat_count = 1
	elif roll <= 0.75:
		rarity = UNCOMMON
		stat_count = 2
	elif roll <= 0.90:
		rarity = RARE
		stat_count = 3
	elif roll <= 0.98:
		rarity = EPIC
		stat_count = 4
	else:
		rarity = LEGENDARY
		stat_count = 5

	var stats = [
		"spawn",
		"speed",
		"melee",
		"range",
		"hp",
		"heal"
	]

	stats.shuffle()

	for i in range(stat_count):
		_apply_stat(stats[i])

	var _name_icon = _generate_name_icon()
	card_name = _name_icon[0]
	icon_index = _name_icon[1]
	detail = _generate_detail()
	
func _apply_stat(stat :String):
	match stat:
		"spawn":
			spawn_time_decrease_percentage = rand_range(0.02, 0.08)
			if randf() < 0.16:
				spawn_time_decrease_value = rand_range(0.1,0.6)
				
		"speed":
			speed_bonus_percentage = rand_range(0.02, 0.08)
			if randf() < 0.10:
				speed_bonus_value = rand_range(0.1,0.2)
				
		"melee":
			melee_speed_bonus_percentage = rand_range(0.02, 0.08)
			if randf() < 0.12:
				melee_speed_bonus_value = rand_range(0.1,0.3)
				
		"range":
			range_speed_bonus_percentage = rand_range(0.02, 0.08)
			if randf() < 0.11:
				range_speed_bonus_value = rand_range(0.1,0.3)
				
		"hp":
			hp_bonus_percentage = rand_range(0.02, 0.08)
			if randf() < 0.12:
				hp_bonus_value = randi() % 41 + 10
				
		"heal":
			heal_bonus_percentage = rand_range(0.02, 0.08)
			if randf() < 0.13:
				heal_bonus_value = randi() % 21 + 5
			
func _generate_name_icon() -> Array:
	if speed_bonus_percentage > 0 and spawn_time_decrease_percentage > 0:
		return ["Singing March", 11]

	if hp_bonus_percentage > 0 and heal_bonus_percentage > 0:
		return ["Field Hospital", 4]

	if melee_speed_bonus_percentage > 0 and hp_bonus_percentage > 0:
		return ["Veteran Warriors", 16]

	if range_speed_bonus_percentage > 0:
		var names = [
			["Arrow Drills",1],
			["Fletcher Guild",5],
			["Master Archers",8]
		]
		return names[randi() % names.size()]

	if melee_speed_bonus_percentage > 0:
		var names = [
			["Combat Training",3],
			["Seasoned Veterans",10],
			["Mercenary Company",9],
		]
		return names[randi() % names.size()]

	if speed_bonus_percentage > 0:
		var names = [
			["Forced March",6],
			["Stamina Training",12],
			["Swift Advance",14]
		]
		return names[randi() % names.size()]
		
	if hp_bonus_percentage > 0:
		var names = [
			["Hardy Folk",7],
			["Strong Constitution",13],
			["Veteran Survivors",15]
		]
		return names[randi() % names.size()]

	if heal_bonus_percentage > 0:
		return ["Camp Healers",2]
		
	return ["Army Traditions",0]

func _generate_detail() -> String:
	var parts = []

	if spawn_time_decrease_percentage > 0:
		parts.append("-%d%% Spawn Time" % int(spawn_time_decrease_percentage * 100))
	if spawn_time_decrease_value > 0:
		parts.append("-%s Spawn Time" % spawn_time_decrease_value)

	if speed_bonus_percentage > 0:
		parts.append("+%d%% Movement Speed" % int(speed_bonus_percentage * 100))
	if speed_bonus_value > 0:
		parts.append("+%s Movement Speed" % speed_bonus_value)
		
	if melee_speed_bonus_percentage > 0:
		parts.append("+%d%% Melee Attack Speed" % int(melee_speed_bonus_percentage * 100))
	if melee_speed_bonus_value > 0:
		parts.append("+%s Melee Attack Speed" % melee_speed_bonus_value)

	if range_speed_bonus_percentage > 0:
		parts.append("+%d%% Ranged Attack Speed" % int(range_speed_bonus_percentage * 100))
	if range_speed_bonus_value > 0:
		parts.append("+%s Ranged Attack Speed" % range_speed_bonus_value)
		
	if hp_bonus_percentage > 0:
		parts.append("+%d%% HP" % int(hp_bonus_percentage * 100))
	if hp_bonus_value > 0:
		parts.append("+%d HP" % hp_bonus_value)

	if heal_bonus_percentage > 0:
		parts.append("+%d%% Healing" % int(heal_bonus_percentage * 100))
	if heal_bonus_value > 0:
		parts.append("+%d Healing" % heal_bonus_value)
		
	return ", ".join(parts)
	
func sum(extra :Dictionary):
	spawn_time_decrease_percentage += extra.get("spawn_time_decrease_percentage", 0.0)
	spawn_time_decrease_value += extra.get("spawn_time_decrease_value", 0.0)
	speed_bonus_percentage += extra.get("speed_bonus_percentage", 0.0)
	speed_bonus_value += extra.get("speed_bonus_value", 0.0)
	melee_speed_bonus_percentage += extra.get("melee_speed_bonus_percentage", 0.0)
	melee_speed_bonus_value += extra.get("melee_speed_bonus_value", 0.0)
	range_speed_bonus_percentage += extra.get("range_speed_bonus_percentage", 0.0)
	range_speed_bonus_value += extra.get("range_speed_bonus_value", 0.0)
	hp_bonus_percentage += extra.get("jhp_bonus_percentage", 0.0)
	hp_bonus_value += extra.get("hp_bonus_value", 0)
	heal_bonus_percentage += extra.get("heal_bonus_percentage", 0.0)
	heal_bonus_value += extra.get("heal_bonus_value", 0)
	
func get_extra() -> Dictionary:
	var _data :Dictionary = .to_dictionary()
	_data["spawn_time_decrease_percentage"] = spawn_time_decrease_percentage
	_data["spawn_time_decrease_value"] = spawn_time_decrease_value
	_data["speed_bonus_percentage"] = speed_bonus_percentage
	_data["speed_bonus_value"] = speed_bonus_value
	_data["melee_speed_bonus_percentage"] = melee_speed_bonus_percentage
	_data["melee_speed_bonus_value"] = melee_speed_bonus_value
	_data["range_speed_bonus_percentage"] = range_speed_bonus_percentage
	_data["range_speed_bonus_value"] = range_speed_bonus_value
	_data["hp_bonus_percentage"] = hp_bonus_percentage
	_data["hp_bonus_value"] = hp_bonus_value
	_data["heal_bonus_percentage"] = heal_bonus_percentage
	_data["heal_bonus_value"] = heal_bonus_value
	return _data


func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	id = _data.get("a", 0)
	card_name = _data.get("b", "")
	detail = _data.get("c", "")
	rarity = _data.get("d", COMMON)
	icon_index = _data.get("e", 0)
	spawn_time_decrease_percentage = _data.get("f", 0.0)
	spawn_time_decrease_value = _data.get("f1", 0.0)
	speed_bonus_percentage = _data.get("g", 0.0)
	speed_bonus_value = _data.get("g1", 0.0)
	melee_speed_bonus_percentage = _data.get("h", 0.0)
	melee_speed_bonus_value = _data.get("h1", 0.0)
	range_speed_bonus_percentage = _data.get("i", 0.0)
	range_speed_bonus_value = _data.get("i1", 0.0)
	hp_bonus_percentage = _data.get("j", 0.0)
	hp_bonus_value = _data.get("j1", 0)
	heal_bonus_percentage = _data.get("k", 0.0)
	heal_bonus_value = _data.get("k1", 0)

func to_dictionary() -> Dictionary:
	var _data :Dictionary = .to_dictionary()
	_data["a"] = id
	_data["b"] = card_name
	_data["c"] = detail
	_data["d"] = rarity
	_data["e"] = icon_index
	_data["f"] = spawn_time_decrease_percentage
	_data["f1"] = spawn_time_decrease_value
	_data["g"] = speed_bonus_percentage
	_data["g1"] = speed_bonus_value
	_data["h"] = melee_speed_bonus_percentage
	_data["h1"] = melee_speed_bonus_value
	_data["i"] = range_speed_bonus_percentage
	_data["i1"] = range_speed_bonus_value
	_data["j"] = hp_bonus_percentage
	_data["j1"] = hp_bonus_value
	_data["k"] = heal_bonus_percentage
	_data["k1"] = heal_bonus_value
	return _data
