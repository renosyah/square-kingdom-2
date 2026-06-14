extends Control

const equipment_item_scene = preload("res://menus/unit_edit/equipment_item/equipment_item.tscn")

# {weapon_index_entity:[0, name, icon]}
const melee_weapons = {
	0 :["Dagger",preload("res://assets/user_interface/icons/equipment/dagger.png")], 
	1 :["Pitchfork",preload("res://assets/user_interface/icons/equipment/pitchfork.png")],
	2 :["Spear",preload("res://assets/user_interface/icons/equipment/spear.png")],
	4 :["Pike",preload("res://assets/user_interface/icons/equipment/pike.png")],
	5 :["Sword",preload("res://assets/user_interface/icons/equipment/sword.png")],
	11 :["Arabian Sword",preload("res://assets/user_interface/icons/equipment/sword_curve.png")],
	7 :["Axe",preload("res://assets/user_interface/icons/equipment/axe.png")],
	9 :["Great Axe",preload("res://assets/user_interface/icons/equipment/great_axe.png")],
	10 :["Great Sword",preload("res://assets/user_interface/icons/equipment/great_sword.png")],
}
const shield_melee_weapons = { 2:3,5:6,7:8,11:11 } # {unshield_varian:shield_variant}

const range_weapons = {
	0 :["(Not Set)",preload("res://assets/user_interface/icons/equipment/empty.png")], 
	1 :["Javeline",preload("res://assets/user_interface/icons/equipment/javeline.png")],
	2 :["Throwing Axe",preload("res://assets/user_interface/icons/equipment/throwing_axe.png")],
	3 :["Bow",preload("res://assets/user_interface/icons/equipment/bow.png")],
	4 :["Longbow",preload("res://assets/user_interface/icons/equipment/longbow.png")],
	5 :["Crossbow",preload("res://assets/user_interface/icons/equipment/crossbow.png")],
}
const headgears = {
	0 :["(Not Set)",preload("res://assets/user_interface/icons/equipment/empty.png")], 
	1 :["Cape", preload("res://assets/user_interface/icons/equipment/helmet_1.png")], 
	2 :["Kettle", preload("res://assets/user_interface/icons/equipment/helmet_2.png")], 
	3 :["Steel Helm 1", preload("res://assets/user_interface/icons/equipment/headgear.png")], 
	4 :["Steel Helm 2", preload("res://assets/user_interface/icons/equipment/helmet_3.png")], 
	5 :["Steel Helm 3", preload("res://assets/user_interface/icons/equipment/helmet_4.png")], 
	6 :["Arabian Helm 1", preload("res://assets/user_interface/icons/equipment/helmet_5.png")], 
	7 :["Arabian Helm 2", preload("res://assets/user_interface/icons/equipment/helmet_6.png")], 
}
const armors = {
	0 :["(Not Set)", preload("res://assets/user_interface/icons/equipment/empty.png")], 
	1 :["Leather",preload("res://assets/user_interface/icons/equipment/armor_1.png")], 
	3 :["Iron",preload("res://assets/user_interface/icons/equipment/armor_2.png") ], 
	2 :["Plate",preload("res://assets/user_interface/icons/equipment/armor_3.png")], 
}
const shields = {
	0 :["(Not Set)",preload("res://assets/user_interface/icons/equipment/empty.png")], 
	1 :["Square",preload("res://assets/user_interface/icons/equipment/shield_1.png")], 
	2 :["Round",preload("res://assets/user_interface/icons/equipment/shield_2.png")], 
}

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

onready var weapon_holder = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/MarginContainer5/weapon_holder
onready var range_weapon_holder = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/MarginContainer6/range_weapon_holder
onready var headgear_holder = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer/MarginContainer3/headgear_holder
onready var armor_holder = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer/MarginContainer5/armor_holder
onready var shield_holder = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/shield_option/MarginContainer7/shield_holder
onready var shield_option = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/shield_option

onready var player_color_display = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/MarginContainer4/player_color_display
onready var icon_color_display =  $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/MarginContainer5/icon_color_display
onready var potrait_display = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/MarginContainer4/MarginContainer2/potrait_display
onready var icon_display = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/MarginContainer5/MarginContainer2/icon_display
onready var edit_name = $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer2/edit_name
onready var unit_role_buttons = {
	1: $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer3/selection_button_cav,
	2: $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer3/selection_button_inf,
	3: $CanvasLayer/Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer3/selection_button_rng,
}

onready var create_new = $CanvasLayer/Control/Control/VBoxContainer2/MarginContainer/HBoxContainer/create_new
onready var save = $CanvasLayer/Control/Control/VBoxContainer2/MarginContainer/HBoxContainer/save
onready var snack_bar = $CanvasLayer/Control/Control/snack_bar
onready var delete = $CanvasLayer/Control/Control/VBoxContainer2/MarginContainer/HBoxContainer/delete
onready var confirm_popup = $CanvasLayer/confirm_popup

var selected_index :int
var dup_squad_data :SquadData

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	player_color_display.color = EntityIndex.player_colors[player_data.color_idx]
	icon_color_display.color = EntityIndex.player_colors[player_data.color_idx]
	
	orbital_camera_ui.rotate_speed = setting.camera_rotation_speed
	orbital_camera_ui.zoom_speed = setting.camera_zoom_speed
	
	orbital_camera_ui.orbit_pivot = movable_camera
	orbital_camera_ui.camera = movable_camera.camera
	orbital_camera_ui.camera.translation.z = 0.8
	
	Global.hide_transition()
	display_current_squad()
	
	_on_squad_card_pressed(0, Global.custom_squads[0])
	
	viewport.size = viewport_container.rect_size
	
	for key in unit_role_buttons.keys():
		var btn :Button = unit_role_buttons[key]
		btn.connect("pressed", self, "_on_unit_role_button", [key])
		
	confirm_popup.visible = false
	
func _on_unit_role_button(key):
	dup_squad_data.squad_role = key
	display_role(dup_squad_data.squad_role)
	
func display_melee_weapons(selected_index :int):
	for i in weapon_holder.get_children():
		weapon_holder.remove_child(i)
		i.queue_free()
		
	for key in melee_weapons.keys():
		var item = equipment_item_scene.instance()
		item.index = key
		item.icon = melee_weapons[key][1]
		item.item_name = melee_weapons[key][0]
		item.connect("selected", self, "_on_melee_weapon_selected", [key])
		weapon_holder.add_child(item)
		item.set_selected(key == selected_index)
	
func display_range_weapons(selected_index :int):
	for i in range_weapon_holder.get_children():
		range_weapon_holder.remove_child(i)
		i.queue_free()
		
	for key in range_weapons.keys():
		var item = equipment_item_scene.instance()
		item.index = key
		item.icon = range_weapons[key][1]
		item.item_name = range_weapons[key][0]
		item.connect("selected", self, "_on_range_weapon_selected", [key])
		range_weapon_holder.add_child(item)
		item.set_selected(key == selected_index)
	
func display_headgear(selected_index :int):
	for i in headgear_holder.get_children():
		headgear_holder.remove_child(i)
		i.queue_free()
		
	for key in headgears.keys():
		var item = equipment_item_scene.instance()
		item.index = key
		item.icon = headgears[key][1]
		item.item_name = headgears[key][0]
		item.connect("selected", self, "_on_headgear_selected", [key])
		headgear_holder.add_child(item)
		item.set_selected(key == selected_index)
	
func display_armor(selected_index :int):
	for i in armor_holder.get_children():
		armor_holder.remove_child(i)
		i.queue_free()
		
	for key in armors.keys():
		var item = equipment_item_scene.instance()
		item.index = key
		item.icon = armors[key][1]
		item.item_name = armors[key][0]
		item.connect("selected", self, "_on_armors_selected", [key])
		armor_holder.add_child(item)
		item.set_selected(key == selected_index)
		
func display_shield(selected_index :int):
	for i in shield_holder.get_children():
		shield_holder.remove_child(i)
		i.queue_free()
		
	for key in shields.keys():
		var item = equipment_item_scene.instance()
		item.index = key
		item.icon = shields[key][1]
		item.item_name = shields[key][0]
		item.connect("selected", self, "_on_shield_selected", [key])
		shield_holder.add_child(item)
		item.set_selected(key == selected_index)

func display_role(role :int):
	for k in unit_role_buttons.keys():
		var b :Button = unit_role_buttons[k]
		b.modulate = Color(0.243137, 0.243137, 0.243137) if role == k else Color.white

func show_shield_option():
	var index = dup_squad_data.member_melee_weapon_idx
	var compatible = index in shield_melee_weapons
	shield_option.visible = compatible
	
	# replace with shield variant
	if compatible and dup_squad_data.member_shield_idx != 0:
		dup_squad_data.member_melee_weapon_idx = shield_melee_weapons[index]
		
	if not compatible:
		dup_squad_data.member_shield_idx = 0
	
func display_attribute():
	squad_name.text = dup_squad_data.squad_name
	potrait_display.texture = EntityIndex.squad_potraits[dup_squad_data.potrait_idx]
	icon_display.texture = EntityIndex.squad_icon[dup_squad_data.icon_idx]
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
			
func _on_back_pressed():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", false)
	
func display_current_squad():
	for i in squad_holder.get_children():
		squad_holder.remove_child(i)
		i.queue_free()
		
	for idx in Global.custom_squads.size():
		var data = Global.custom_squads[idx]
		
		# only accept infantry & cav
		if not data.scene_idx in [0,1]: 
			continue
			
		var card = preload("res://assets/user_interface/squad_card/squad_card.tscn").instance()
		data.color_idx = Global.player_data.color_idx
		card.data = data
		
		var btn = Button.new()
		btn.rect_min_size = Vector2(70, 100)
		btn.connect("pressed", self, "_on_squad_card_pressed", [idx, Global.custom_squads[idx]])
		squad_holder.add_child(btn)
		btn.add_child(card)
		
		
func _on_melee_weapon_selected(index :int):
	dup_squad_data.member_melee_weapon_idx = index
	display_melee_weapons(index)
	show_shield_option()
	
	infantry_member.melee_weapon = EntityIndex.melee_weapons[index]
	infantry_member.shield = dup_squad_data.member_shield_idx
	infantry_member.apply_equipment()
	
func _on_range_weapon_selected(index :int):
	dup_squad_data.member_range_weapon_idx = index
	display_range_weapons(index)
	infantry_member.range_weapon = EntityIndex.range_weapons[index]
	infantry_member.apply_equipment()
	
func _on_headgear_selected(index :int):
	dup_squad_data.member_headgear_idx = index
	display_headgear(index)
	infantry_member.headgear = EntityIndex.head_armors[index]
	infantry_member.apply_equipment()
	
func _on_armors_selected(index :int):
	dup_squad_data.member_armor_idx = index
	display_armor(index)
	infantry_member.armor = EntityIndex.armors[index]
	infantry_member.apply_equipment()
	
func _on_shield_selected(index :int):
	dup_squad_data.member_shield_idx = index
	display_shield(index)
	infantry_member.shield = EntityIndex.shields[index]
	infantry_member.apply_equipment()
	
func _on_squad_card_pressed(idx:int, squad :SquadData):
	selected_index = idx
	edit_name.text = squad.squad_name
	
	 # 0 mean this is squad template and cannot be modified
	save.visible = (squad.squad_id != 0)
	delete.visible = (squad.squad_id != 0)
	create_new.visible = (squad.squad_id == 0)
	
	dup_squad_data = SquadData.new()
	dup_squad_data.from_dictionary(squad.to_dictionary())
	dup_squad_data.squad_id = 1
	dup_squad_data.description = "Custom Squad"
	
	infantry_member.headgear = EntityIndex.head_armors[dup_squad_data.member_headgear_idx]
	infantry_member.armor = EntityIndex.armors[dup_squad_data.member_armor_idx]
	infantry_member.shield = EntityIndex.shields[dup_squad_data.member_shield_idx]
	infantry_member.melee_weapon = EntityIndex.melee_weapons[dup_squad_data.member_melee_weapon_idx]
	infantry_member.range_weapon = EntityIndex.range_weapons[dup_squad_data.member_range_weapon_idx]
	infantry_member.material = Global.player_materials[player_data.color_idx]
	horse.visible = dup_squad_data.is_mounted
	
	display_melee_weapons(dup_squad_data.member_melee_weapon_idx)
	display_range_weapons(dup_squad_data.member_range_weapon_idx)
	display_headgear(dup_squad_data.member_headgear_idx)
	display_armor(dup_squad_data.member_armor_idx)
	display_shield(dup_squad_data.member_shield_idx)
	display_role(dup_squad_data.squad_role)
	display_attribute()
	show_shield_option()
	
	infantry_member.apply_equipment()
	
func _on_change_icon_pressed():
	dup_squad_data.icon_idx += 1
	if dup_squad_data.icon_idx > EntityIndex.squad_icon.size() - 1:
		dup_squad_data.icon_idx = 0
		 
	display_attribute()

func _on_change_potrait_pressed():
	dup_squad_data.potrait_idx += 1
	if dup_squad_data.potrait_idx > EntityIndex.squad_potraits.size() - 1:
		dup_squad_data.potrait_idx = 0
		
	display_attribute()

func _on_button_random_name_pressed():
	edit_name.text = RandomNameGenerator.generate_name()
	dup_squad_data.squad_name = edit_name.text
	display_attribute()

func _on_edit_name_text_changed(new_text):
	dup_squad_data.squad_name = new_text
	squad_name.text = dup_squad_data.squad_name
	
func _on_create_new_pressed():
	snack_bar.text = "Squad Created!"
	snack_bar.show()
	
	var dup = SquadData.new()
	dup.from_dictionary(dup_squad_data.to_dictionary())
	
	Global.custom_squads.append(dup)
	Global.save_custom_squad()
	
	display_current_squad()
	var idx = Global.custom_squads.size() - 1
	_on_squad_card_pressed(idx, Global.custom_squads[idx])

func _on_save_pressed():
	snack_bar.text = "Squad Saved!"
	snack_bar.show()
	
	var dup = SquadData.new()
	dup.from_dictionary(dup_squad_data.to_dictionary())
	
	Global.custom_squads[selected_index] = dup
	Global.save_custom_squad()
	
	display_current_squad()
	_on_squad_card_pressed(selected_index, Global.custom_squads[selected_index])
	
func _on_delete_pressed():
	confirm_popup.visible = true
	confirm_popup.show_popup("Delete", "Delete squad\nThis also remove from army\nContinue?")
	var yes = yield(confirm_popup,"confirmed")
	confirm_popup.visible = false
	
	if not yes:
		return
	
	snack_bar.text = "Squad Deleted!"
	snack_bar.show()
	
	Global.custom_squads.remove(selected_index)
	
	while Global.current_army.has(selected_index):
		Global.current_army.erase(selected_index)
	
	# replace it with peasant
	while Global.current_army.size() < 4:
		Global.current_army.append(0)
	
	Global.save_custom_squad()
	
	selected_index = 0
	display_current_squad()
	_on_squad_card_pressed(selected_index, Global.custom_squads[selected_index])
