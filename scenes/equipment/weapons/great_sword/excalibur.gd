extends MeleeWeapon

onready var trail_render = $TrailRender
var _visible :bool

func _ready():
	_visible = get_parent().visible
	trail_render.render = _visible

func _process(delta):
	var _v = get_parent().visible
	if _visible != _v:
		_visible = _v
		trail_render.render = _v

func get_attack_damage(enemy_squad_attribute :Array) -> int:
	var dmg = attack_damage
	
	if enemy_squad_attribute[1] == 2: # using two handed
		dmg += attack_damage * bonus_damage
		
	if enemy_squad_attribute[0] == 0: # is infantry
		dmg += attack_damage * bonus_damage
	
	return dmg
