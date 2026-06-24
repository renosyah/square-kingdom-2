extends BaseData
class_name ArmyCardData

const COMMON = 0
const UNCOMMON = 1
const RARE = 2
const EPIC = 3
const LEGENDARY = 4

export var id :int
export var card_name:String
export var rarity:int
export var icon_index:int
export var is_buff :bool

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
export var extra_buff_value: float # 0.1 - 1.0

export var extra_debuff_duration:float # 1.0 - 100.0
export var extra_debuff_value :float  # 0.1 - 1.0

func generate_card(_is_buff :bool = true):
	is_buff = _is_buff
	id = randi()
	
	card_name = ""

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

	var _name_icon = _generate_name_icon() if is_buff else _generate_name_icon_debuff()
	card_name = _name_icon[0]
	icon_index = _name_icon[1]
	
func _apply_stat(stat :String):
	match stat:
		"spawn":
			spawn_time_decrease_percentage = rand_range(0.02, 0.08)
			if not is_buff:
				spawn_time_decrease_percentage = -spawn_time_decrease_percentage
			
			if randf() < 0.16:
				spawn_time_decrease_value = rand_range(0.1,0.6)
				if not is_buff:
					spawn_time_decrease_value = -spawn_time_decrease_value
				
				if randf() < 0.26:
					spawn_time_decrease_percentage = 0.0
				
				
		"speed":
			speed_bonus_percentage = rand_range(0.02, 0.08)
			if not is_buff:
				speed_bonus_percentage = -speed_bonus_percentage
			
			if randf() < 0.10:
				speed_bonus_value = rand_range(0.1,0.2)
				if not is_buff:
					speed_bonus_value = -speed_bonus_value
				
				if randf() < 0.16:
					speed_bonus_percentage = 0.0
				
		"melee":
			melee_speed_bonus_percentage = rand_range(0.02, 0.08)
			if not is_buff:
				melee_speed_bonus_percentage = -melee_speed_bonus_percentage
				
			if randf() < 0.12:
				melee_speed_bonus_value = rand_range(0.1,0.3)
				if not is_buff:
					melee_speed_bonus_value = -melee_speed_bonus_value
				
				if randf() < 0.11:
					melee_speed_bonus_percentage = 0.0
					
		"range":
			range_speed_bonus_percentage = rand_range(0.02, 0.08)
			if not is_buff:
				range_speed_bonus_percentage = -range_speed_bonus_percentage
			
			if randf() < 0.11:
				range_speed_bonus_value = rand_range(0.1,0.3)
				if not is_buff:
					range_speed_bonus_value = -range_speed_bonus_value
				
				if randf() < 0.13:
					range_speed_bonus_percentage = 0.0
				
		"hp":
			hp_bonus_percentage = rand_range(0.02, 0.08)
			if not is_buff:
				hp_bonus_percentage = -hp_bonus_percentage
				
			if randf() < 0.12:
				hp_bonus_value = randi() % 41 + 10
				if not is_buff:
					hp_bonus_value = -hp_bonus_value
				
				if randf() < 0.16:
					hp_bonus_percentage = 0.0
				
		"heal":
			heal_bonus_percentage = rand_range(0.02, 0.08)
			if not is_buff:
				heal_bonus_percentage = -heal_bonus_percentage
			
			if randf() < 0.13:
				heal_bonus_value = randi() % 21 + 5
				if not is_buff:
					heal_bonus_value = -heal_bonus_value
				
				if randf() < 0.12:
					heal_bonus_percentage = 0.0
					
func _generate_name_icon_debuff() -> Array:
	if speed_bonus_percentage < 0 and spawn_time_decrease_percentage < 0:
		return ["Bog Down", 19]
		
	if hp_bonus_percentage < 0 and heal_bonus_percentage < 0:
		return ["Sickness", 25]
		
	if melee_speed_bonus_percentage < 0 and hp_bonus_percentage < 0:
		var names = [
			["Attrition",17],
			["Hunger",23],
			["Thirst",27]
		]
		return names[randi() % names.size()]
		
	if range_speed_bonus_percentage < 0:
		var names = [
			["Bad Weather",18],
			["Hunger",23],
			["Thirst",27],
		]
		return names[randi() % names.size()]
		
	if melee_speed_bonus_percentage < 0:
		var names = [
			["Exhaustion",22],
			["Outnumber",24],
			["Disorganize",21],
		]
		return names[randi() % names.size()]
		
	if speed_bonus_percentage < 0:
		var names = [
			["Exhaustion",22],
			["Sickness", 25],
			["Bog Down", 19],
			["Bad Weather",18],
			["Thirst",27],
		]
		return names[randi() % names.size()]
		
	if hp_bonus_percentage < 0:
		var names = [
			["Supply Shortage",26],
			["Sickness", 25],
			["Attrition",17],
		]
		return names[randi() % names.size()]
		
	return ["Demoralise", 20]
	
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

func get_detail() -> String:
	var parts = []

	if abs(spawn_time_decrease_percentage) > 0:
		parts.append("%s%d%% Spawn Time" % ["-" if is_buff else "+",int(abs(spawn_time_decrease_percentage) * 100)])
	if abs(spawn_time_decrease_value) > 0:
		parts.append("%s%s Spawn Time" % ["-" if is_buff else "+", stepify(abs(spawn_time_decrease_value), 0.1)])

	if abs(speed_bonus_percentage) > 0:
		parts.append("%s%d%% Movement Speed" % ["+" if is_buff else "-",int(abs(speed_bonus_percentage) * 100)])
	if abs(speed_bonus_value) > 0:
		parts.append("%s%s Movement Speed" % ["+" if is_buff else "-",stepify(abs(speed_bonus_value), 0.1)])
		
	if abs(melee_speed_bonus_percentage) > 0:
		parts.append("%s%d%% Melee Attack Speed" % ["+" if is_buff else "-",int(abs(melee_speed_bonus_percentage) * 100)])
	if abs(melee_speed_bonus_value) > 0:
		parts.append("%s%s Melee Attack Speed" % ["+" if is_buff else "-",stepify(abs(melee_speed_bonus_value), 0.1)])

	if abs(range_speed_bonus_percentage) > 0:
		parts.append("%s%d%% Ranged Attack Speed" % ["+" if is_buff else "-",int(abs(range_speed_bonus_percentage) * 100)])
	if abs(range_speed_bonus_value) > 0:
		parts.append("%s%s Ranged Attack Speed" % ["+" if is_buff else "-",stepify(abs(range_speed_bonus_value), 0.1)])
		
	if abs(hp_bonus_percentage) > 0:
		parts.append("%s%d%% HP" % ["+" if is_buff else "-",int(abs(hp_bonus_percentage) * 100)])
	if abs(hp_bonus_value) > 0:
		parts.append("%s%d HP" % ["+" if is_buff else "-",abs(hp_bonus_value)])

	if abs(heal_bonus_percentage) > 0:
		parts.append("%s%d%% Healing" % ["+" if is_buff else "-",int(abs(heal_bonus_percentage) * 100)])
	if abs(heal_bonus_value) > 0:
		parts.append("%s%d Healing" % ["+" if is_buff else "-",abs(heal_bonus_value)])
		
	return "\n".join(parts)
	
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
	extra_buff_duration += extra.get("extra_buff_duration", 0.0)
	extra_buff_value += extra.get("extra_buff_value", 0.0)
	extra_debuff_duration += extra.get("extra_debuff_duration", 0.0)
	extra_debuff_value += extra.get("extra_debuff_value", 0.0)
	
func get_extra() -> Dictionary:
	var _data :Dictionary = .to_dictionary()
	
	if abs(spawn_time_decrease_percentage) > 0:
		_data["spawn_time_decrease_percentage"] = spawn_time_decrease_percentage
	_data["spawn_time_decrease_value"] = spawn_time_decrease_value
		
	if abs(speed_bonus_percentage) > 0:
		_data["speed_bonus_percentage"] = speed_bonus_percentage
	_data["speed_bonus_value"] = speed_bonus_value
		
	if abs(melee_speed_bonus_percentage) > 0:
		_data["melee_speed_bonus_percentage"] = melee_speed_bonus_percentage
	_data["melee_speed_bonus_value"] = melee_speed_bonus_value
	
	if abs(range_speed_bonus_percentage) > 0:
		_data["range_speed_bonus_percentage"] = range_speed_bonus_percentage
	_data["range_speed_bonus_value"] = range_speed_bonus_value
	
	if abs(hp_bonus_percentage) > 0:
		_data["hp_bonus_percentage"] = hp_bonus_percentage
	_data["hp_bonus_value"] = hp_bonus_value
	
	if abs(heal_bonus_percentage) > 0:
		_data["heal_bonus_percentage"] = heal_bonus_percentage
	_data["heal_bonus_value"] = heal_bonus_value
	
	_data["extra_buff_duration"] = extra_buff_duration
	_data["extra_buff_value"] = extra_buff_value
	
	_data["extra_debuff_duration"] = extra_debuff_duration
	_data["extra_debuff_value"] = extra_debuff_value
		
	return _data


func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	id = _data.get("a", 0)
	card_name = _data.get("b", "")
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
	is_buff = _data.get("l", false)
	extra_buff_duration = _data.get("m", 0.0)
	extra_buff_value = _data.get("m1", 0.0)
	extra_debuff_duration = _data.get("n", 0.0)
	extra_debuff_value = _data.get("n1", 0.0)

func to_dictionary() -> Dictionary:
	var _data :Dictionary = .to_dictionary()
	_data["a"] = id
	_data["b"] = card_name
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
	_data["l"] = is_buff
	_data["m"] = extra_buff_duration
	_data["m1"] = extra_buff_value
	_data["n"] = extra_debuff_duration
	_data["n1"] = extra_debuff_value
	return _data
