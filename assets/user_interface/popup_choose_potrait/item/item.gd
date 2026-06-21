extends Button

export var image :StreamTexture

onready var selected = $selected
onready var icn = $MarginContainer/icon
onready var selected_2 = $MarginContainer/selected2

func _ready():
	icn.texture = image
	
func set_selected(v :bool):
	selected.visible = v
	selected_2.visible = v
