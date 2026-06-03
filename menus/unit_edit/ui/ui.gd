extends Control

onready var player_data :PlayerData = Global.player_data
onready var setting :SettingData = Global.setting_data
onready var orbital_camera_ui = $CanvasLayer/orbital_camera_ui
onready var squad_holder = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/squad_container/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/MarginContainer/squad_holder
onready var squad_name = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/VBoxContainer/squad_name
onready var viewport = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport
onready var viewport_container = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer

onready var horse = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport/horse
onready var movable_camera = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport/movable_camera
onready var infantry_member = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport/infantry_member

onready var save = $CanvasLayer/Control/Control/VBoxContainer2/MarginContainer/HBoxContainer/save

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	orbital_camera_ui.rotate_speed = setting.camera_rotation_speed
	orbital_camera_ui.zoom_speed = setting.camera_zoom_speed
	
	orbital_camera_ui.orbit_pivot = movable_camera
	orbital_camera_ui.camera = movable_camera.camera
	orbital_camera_ui.camera.translation.z = 0.8
	
	Global.hide_transition()
	display_current_squad()
	_on_squad_card_pressed(Global.custom_squads[0])
	
	viewport.size = viewport_container.rect_size
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
			
func _on_back_pressed():
	Global.change_scene("res://menus/army_edit/army_edit.tscn", false)
	
func display_current_squad():
	for i in squad_holder.get_children():
		squad_holder.remove_child(i)
		i.queue_free()
		
	var idx = 0
	for data in Global.custom_squads:
		
		# only accept infantry & cav
		if not data.scene_idx in [0,1]: 
			continue
			
		var card = preload("res://assets/user_interface/squad_card/squad_card.tscn").instance()
		data.color_idx = Global.player_data.color_idx
		card.data = data
		
		var btn = Button.new()
		btn.rect_min_size = Vector2(70, 100)
		btn.connect("pressed", self, "_on_squad_card_pressed", [Global.custom_squads[idx]])
		squad_holder.add_child(btn)
		btn.add_child(card)
		
		idx += 1

func _on_squad_card_pressed(squad :SquadData):
	 # 0 mean this is squad template and cannot be modified
	save.visible = (squad.squad_id != 0)
	
	infantry_member.headgear = EntityIndex.equipment[squad.member_headgear_idx]
	infantry_member.armor = EntityIndex.equipment[squad.member_armor_idx]
	infantry_member.shield = EntityIndex.equipment[squad.member_shield_idx]
	infantry_member.melee_weapon = EntityIndex.weapons[squad.member_melee_weapon_idx]
	infantry_member.range_weapon = EntityIndex.weapons[squad.member_range_weapon_idx]
	infantry_member.material = Global.player_materials[player_data.color_idx]
	horse.visible = squad.is_mounted
	infantry_member.apply_equipment()
	squad_name.text = squad.squad_name
