extends Button

export var image :StreamTexture

onready var selected = $selected
onready var icn = $MarginContainer/icon

func _ready():
	icn.texture = image

func set_selected(v :bool):
	selected.visible = v
