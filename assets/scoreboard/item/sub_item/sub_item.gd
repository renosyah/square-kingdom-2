extends HBoxContainer

var data

onready var dead = $HBoxContainer2/squad_potrait/dead
onready var squad_potrait = $HBoxContainer2/squad_potrait
onready var squad_name = $HBoxContainer2/squad_name
onready var total_kill = $total_kill
onready var total_dead = $total_dead
onready var total_ff = $total_ff
onready var total_all = $total_all

func _ready():
	dead.visible = data.is_dead
	squad_potrait.texture = EntityIndex.squad_potraits[data.squad_potrait_idx] 
	squad_name.text = data.squad_name
	
	total_kill.text = "%s" % data.kill
	total_dead.text = "%s" % data.dead
	total_ff.text = "%s" % data.friendly_fire
	total_all.text = "%s" % data.get_total()
