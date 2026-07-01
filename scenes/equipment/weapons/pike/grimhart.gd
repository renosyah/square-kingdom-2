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

func get_attack_damage(target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 1: # is cavalry
		return attack_damage + (target.hp * bonus_damage)
	return attack_damage
