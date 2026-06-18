extends Button

var squad :BaseSquad
var required_enemy_in_melee :bool
var required_enemy_in_range :bool

onready var time_progress = $ability_button_cooldown/time_progress
onready var label_time = $ability_button_cooldown/label_time
onready var cooldown_bg = $cooldown_bg
onready var ability_button_cooldown = $ability_button_cooldown
onready var ability_icon = $ability_icon
onready var label = $VBoxContainer/MarginContainer/MarginContainer/Label

func set_ability_icon(n :String, v :StreamTexture):
	label.text = n
	ability_icon.texture = v

func _process(delta):
	if not visible:
		return
		
	if is_instance_valid(squad):
		var cooldowns = squad.get_ability_cooldown()
		var on_cooldown = cooldowns[0]
		
		if required_enemy_in_melee:
			disabled = not squad.in_melee_engagement()
			
		if required_enemy_in_range:
			disabled = not squad.in_range_engagement()
			
		cooldown_bg.visible = on_cooldown or disabled
		ability_button_cooldown.visible = on_cooldown
		label_time.text = "%s" % int(cooldowns[1])
		time_progress.value = cooldowns[1]
		time_progress.max_value = cooldowns[2]
