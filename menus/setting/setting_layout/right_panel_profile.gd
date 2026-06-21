extends MarginContainer

onready var color_btn_temp = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/color_btn_temp

var popup_choose_potrait

onready var player_color_display = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/MarginContainer4/player_color_display
onready var player_potrait_display = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/MarginContainer4/MarginContainer2/player_potrait_display
onready var edit_player_name = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/edit_player_name
onready var color_option_holder = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/color_option_holder
onready var h_box_container = $VBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer

var player_data :PlayerData = Global.player_data

func _ready():
	_apply()
	
	for idx in EntityIndex.player_colors.size() - 1: # exlude last:
		var btn :Button = color_btn_temp.duplicate()
		btn.visible = true
		btn.connect("pressed", self, "_color_btn_pressed", [idx])
		btn.get_child(0).color = EntityIndex.player_colors[idx]
		color_option_holder.add_child(btn)
	
func _apply():
	edit_player_name.text = player_data.player_name
	player_color_display.color = EntityIndex.player_colors[player_data.color_idx]
	player_potrait_display.texture = EntityIndex.squad_potraits[player_data.potrait_idx]

func _color_btn_pressed(idx):
	player_data.color_idx = idx
	_apply()

func _on_edit_player_name_text_changed(new_text):
	if not new_text.empty():
		player_data.player_name = new_text

func _on_button_random_name_pressed():
	player_data.player_name = RandomNameGenerator.generate_name()
	edit_player_name.text = player_data.player_name
	
func _on_prev_pressed():
	player_data.potrait_idx -= 1
	if player_data.potrait_idx < 0:
		player_data.potrait_idx = EntityIndex.squad_potraits.size() - 1
		
	player_potrait_display.texture = EntityIndex.squad_potraits[player_data.potrait_idx]
	
func _on_next_pressed():
	player_data.potrait_idx += 1
	if player_data.potrait_idx > EntityIndex.squad_potraits.size() - 1:
		player_data.potrait_idx = 0
		
	player_potrait_display.texture = EntityIndex.squad_potraits[player_data.potrait_idx]

func _on_choose_potrait_pressed():
	if popup_choose_potrait:
		popup_choose_potrait.visible = true

func _on_popup_choose_potrait_close():
	if popup_choose_potrait:
		popup_choose_potrait.visible = false

func _on_popup_choose_potrait_selected(idx):
	if popup_choose_potrait:
		popup_choose_potrait.visible = false
		
	player_data.potrait_idx = idx
	player_potrait_display.texture = EntityIndex.squad_potraits[player_data.potrait_idx]
