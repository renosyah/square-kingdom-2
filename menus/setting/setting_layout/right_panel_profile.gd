extends MarginContainer

onready var color_btn_temp = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/color_btn_temp

onready var player_color_display = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/MarginContainer/player_color_display
onready var player_potrait_display = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/MarginContainer/MarginContainer2/player_potrait_display
onready var color_option_holder = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer2
onready var edit_player_name = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/edit_player_name

var player_data :PlayerData = Global.player_data

func _ready():
	_apply()
	
	for idx in Global.player_colors.size():
		var btn :Button = color_btn_temp.duplicate()
		btn.visible = true
		btn.connect("pressed", self, "_color_btn_pressed", [idx])
		btn.get_child(0).color = Global.player_colors[idx]
		color_option_holder.add_child(btn)
	
func _apply():
	edit_player_name.text = player_data.player_name
	player_color_display.color = Global.player_colors[player_data.color_idx]
	player_potrait_display.texture = Global.player_potraits[player_data.potrait_idx]
	
func _color_btn_pressed(idx):
	player_data.color_idx = idx
	_apply()

func _on_edit_player_name_text_changed(new_text):
	if not new_text.empty():
		player_data.player_name = new_text

func _on_change_potrait_pressed():
	player_data.potrait_idx += 1
	if player_data.potrait_idx > Global.player_potraits.size() - 1:
		player_data.potrait_idx = 0
		
	player_potrait_display.texture = Global.player_potraits[player_data.potrait_idx]
