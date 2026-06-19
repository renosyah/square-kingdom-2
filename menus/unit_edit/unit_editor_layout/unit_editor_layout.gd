extends MarginContainer

signal close
signal save_current_squads(squads, armies)

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
const fire_modes = {
	0 :["Volley!", preload("res://assets/user_interface/ability/volley_ability.png")], 
	1 :["Rappid!", preload("res://assets/user_interface/ability/rappid_fire.png")], 
}

export var player_color_idx :int
export var player_material :SpatialMaterial
export var camera_rotation_speed :float = 0.15
export var camera_zoom_speed :float = 0.02
export var current_squads :Array
export var current_army :Array

onready var orbital_camera_ui = $orbital_camera_ui
onready var squad_holder = $Control/Control/VBoxContainer2/HBoxContainer/squad_container/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer/MarginContainer/squad_holder
onready var squad_name = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/VBoxContainer/squad_name
onready var viewport = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport
onready var viewport_container = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer
onready var template_squad_warning = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/VBoxContainer/template_squad_warning

onready var horse = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport/horse
onready var movable_camera = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport/movable_camera
onready var infantry_member = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer/ViewportContainer/Viewport/infantry_member

onready var weapon_holder = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/MarginContainer5/weapon_holder
onready var range_weapon_holder = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/MarginContainer6/range_weapon_holder
onready var headgear_holder = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer/MarginContainer3/headgear_holder
onready var armor_holder = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer/MarginContainer5/armor_holder
onready var shield_holder = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/shield_option/MarginContainer7/shield_holder
onready var shield_option = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/shield_option
onready var abilities_holder = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer4/MarginContainer6/abilities_holder
onready var ability_desc = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer4/ability_desc
onready var fire_mode_option = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/fire_mode_option
onready var fire_mode_holder = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer2/fire_mode_option/MarginContainer7/fire_mode_holder

onready var player_color_display = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/MarginContainer4/player_color_display
onready var icon_color_display =  $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/MarginContainer5/icon_color_display
onready var potrait_display = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/MarginContainer4/MarginContainer2/potrait_display
onready var icon_display = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/MarginContainer5/MarginContainer2/icon_display
onready var edit_name = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer2/edit_name
onready var unit_role_buttons = {
	1:  $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer3/selection_button_cav,
	2:  $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer3/selection_button_inf,
	3:  $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer3/selection_button_rng,
}
onready var set_hero =  $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer3/set_hero
onready var set_squad = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer3/set_squad
onready var type_describe = $Control/Control/VBoxContainer2/HBoxContainer/MarginContainer2/MarginContainer2/ScrollContainer/MarginContainer/VBoxContainer2/VBoxContainer3/type_describe

onready var create_new = $Control/Control/VBoxContainer2/MarginContainer/HBoxContainer/create_new
onready var save = $Control/Control/VBoxContainer2/MarginContainer/HBoxContainer/save
onready var snack_bar = $Control/Control/snack_bar
onready var delete = $Control/Control/VBoxContainer2/MarginContainer/HBoxContainer/delete
onready var confirm_popup = $confirm_popup

var selected_index :int
var dup_squad_data :SquadData

func display():
	player_color_display.color = EntityIndex.player_colors[player_color_idx]
	icon_color_display.color = EntityIndex.player_colors[player_color_idx]
	
	orbital_camera_ui.rotate_speed = camera_rotation_speed
	orbital_camera_ui.zoom_speed = camera_zoom_speed
	
	orbital_camera_ui.orbit_pivot = movable_camera
	orbital_camera_ui.camera = movable_camera.camera
	orbital_camera_ui.camera.translation.z = 0.8
	
	display_current_squad()
	
	_on_squad_card_pressed(0, current_squads[0])
	
	viewport.size = viewport_container.rect_size
	
	for key in unit_role_buttons.keys():
		var btn :Button = unit_role_buttons[key]
		btn.connect("pressed", self, "_on_unit_role_button", [key])
		
	set_squad.connect("pressed", self, "_on_set_as_hero", [false])
	set_hero.connect("pressed", self, "_on_set_as_hero", [true])
	
	confirm_popup.visible = false
	
func _on_set_as_hero(v :bool):
	dup_squad_data.is_hero = v
	
	var is_mounted = dup_squad_data.is_mounted
	if v:
		dup_squad_data.total_member = 1
		
	else:
		dup_squad_data.total_member = 4 if is_mounted else 9
		
	display_hero(dup_squad_data.is_hero)
	
	# nah just set it to none if changes
	dup_squad_data.squad_ability_idx = 0
	display_abilities(dup_squad_data, 0)
	
func _on_unit_role_button(key):
	if key == 1:
		dup_squad_data.scene_idx = 1
		dup_squad_data.member_scene_idx = 1
		dup_squad_data.total_member = 4
		dup_squad_data.is_mounted = true
		
	else:
		dup_squad_data.scene_idx = 0
		dup_squad_data.member_scene_idx = 0
		dup_squad_data.total_member = 9
		dup_squad_data.is_mounted = false
		
	if dup_squad_data.is_hero:
		dup_squad_data.total_member = 1
		
	horse.visible = dup_squad_data.is_mounted
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
		
func display_fire_mode(selected_index :int):
	for i in fire_mode_holder.get_children():
		fire_mode_holder.remove_child(i)
		i.queue_free()
		
	for key in fire_modes.keys():
		var item = equipment_item_scene.instance()
		item.index = key
		item.icon = fire_modes[key][1]
		item.item_name = fire_modes[key][0]
		item.connect("selected", self, "_on_fire_mode_selected", [key])
		fire_mode_holder.add_child(item)
		item.set_selected(key == selected_index)
		
func display_abilities(s :SquadData, selected_index :int):
	for i in abilities_holder.get_children():
		abilities_holder.remove_child(i)
		i.queue_free()
		
	var abilities = AbilityHandle.squad_abilities
	ability_desc.text = "No Ability selected"
	
	# for none
	var item_null = equipment_item_scene.instance()
	item_null.index = 0
	item_null.icon = preload("res://assets/user_interface/icons/equipment/empty.png")
	item_null.item_name = "(Not Set)"
	item_null.connect("selected", self, "_on_ability_selected", [0])
	abilities_holder.add_child(item_null)
	item_null.set_selected(0 == selected_index)
	
	for idx in abilities.size():
		if idx == 0:
			continue
			
		var is_melee = abilities[idx]["type"] == "melee"
		var is_range = abilities[idx]["type"] == "range"
		var is_shield = abilities[idx]["type"] == "shield"
		var is_hero = abilities[idx]["type"] == "hero"
		var weapon_idx = abilities[idx]["weapon_idx"]
		
		var for_melee = is_melee and weapon_idx == s.member_melee_weapon_idx
		var for_range = is_range and weapon_idx == s.member_range_weapon_idx
		var for_shield = is_shield and s.member_shield_idx != 0
		var for_hero = is_hero and s.is_hero
		
		if not for_melee and not for_range and not for_shield and not for_hero:
			continue
		
		var is_selected = (idx == selected_index)
		
		var item = equipment_item_scene.instance()
		item.index = idx
		item.icon = abilities[idx]["icon"]
		item.item_name = abilities[idx]["name"]
		item.connect("selected", self, "_on_ability_selected", [idx])
		abilities_holder.add_child(item)
		item.set_selected(is_selected)
		
		if is_selected:
			ability_desc.text = abilities[selected_index]["detail"]
	
func display_role(role :int):
	for k in unit_role_buttons.keys():
		var b :Button = unit_role_buttons[k]
		b.modulate = Color(0.243137, 0.243137, 0.243137) if role == k else Color.white

func display_hero(is_hero :bool):
	set_squad.modulate.a = 0.5 if is_hero else 1.0
	set_hero.modulate.a = 0.5 if not is_hero else 1.0
	
	if is_hero:
		type_describe.text = "A powerful individual who stands above the common soldier. Heroes fight alone, possessing exceptional endurance and the ability to turn the tide of battle."
		
	else:
		type_describe.text = "The backbone of every army. A squad is a group of soldiers fighting together as a single battlefield formation."
		
func show_shield_option():
	var index = dup_squad_data.member_melee_weapon_idx
	var compatible = index in shield_melee_weapons
	shield_option.visible = compatible
	
	# replace with shield variant
	if compatible and dup_squad_data.member_shield_idx != 0:
		dup_squad_data.member_melee_weapon_idx = shield_melee_weapons[index]
		
	if not compatible:
		dup_squad_data.member_shield_idx = 0
	
func show_fire_mode_option():
	fire_mode_option.visible = dup_squad_data.member_range_weapon_idx != 0
	
func display_attribute():
	squad_name.text = dup_squad_data.squad_name
	potrait_display.texture = EntityIndex.squad_potraits[dup_squad_data.potrait_idx]
	icon_display.texture = EntityIndex.squad_icon[dup_squad_data.icon_idx]
	
func _on_back_pressed():
	emit_signal("close")
	
func display_current_squad():
	for i in squad_holder.get_children():
		squad_holder.remove_child(i)
		i.queue_free()
		
	for idx in current_squads.size():
		var data = current_squads[idx]
		
		# only accept infantry & cav
		if not data.scene_idx in [0,1]: 
			continue
			
		var card = preload("res://assets/user_interface/squad_card/squad_card.tscn").instance()
		data.color_idx = player_color_idx
		card.data = data
		
		var btn = Button.new()
		btn.rect_min_size = Vector2(70, 100)
		btn.connect("pressed", self, "_on_squad_card_pressed", [idx, current_squads[idx]])
		squad_holder.add_child(btn)
		btn.add_child(card)
		
		
func _on_melee_weapon_selected(index :int):
	dup_squad_data.member_melee_weapon_idx = index
	display_melee_weapons(index)
	show_shield_option()
	
	infantry_member.melee_weapon = EntityIndex.melee_weapons[index]
	infantry_member.shield = dup_squad_data.member_shield_idx
	infantry_member.apply_equipment()
	
	# nah just set it to none if changes
	dup_squad_data.squad_ability_idx = 0
	display_abilities(dup_squad_data, 0)
	
func _on_range_weapon_selected(index :int):
	dup_squad_data.member_range_weapon_idx = index
	display_range_weapons(index)
	show_fire_mode_option()
	
	infantry_member.range_weapon = EntityIndex.range_weapons[index]
	infantry_member.apply_equipment()
	
	# nah just set it to none if changes
	dup_squad_data.squad_ability_idx = 0
	display_abilities(dup_squad_data, 0)
	
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
	
	# nah just set it to none if changes
	dup_squad_data.squad_ability_idx = 0
	display_abilities(dup_squad_data, 0)
	
func _on_fire_mode_selected(index :int):
	dup_squad_data.range_fire_mode = index
	display_fire_mode(index)
	
func _on_ability_selected(index :int):
	dup_squad_data.squad_ability_idx = index
	display_abilities(dup_squad_data, index)
	
func _on_squad_card_pressed(idx:int, squad :SquadData):
	selected_index = idx
	edit_name.text = squad.squad_name
	
	 # 0 mean this is squad template and cannot be modified
	save.visible = (squad.squad_id != 0)
	delete.visible = (squad.squad_id != 0)
	create_new.visible = (squad.squad_id == 0)
	template_squad_warning.visible = (squad.squad_id == 0)
	
	dup_squad_data = SquadData.new()
	dup_squad_data.from_dictionary(squad.to_dictionary())
	dup_squad_data.squad_id = 1
	dup_squad_data.description = "Custom Squad"
	
	# for shield scinanigan, 
	# i regret made this shield and unshield varian 
	# but what ever
	if dup_squad_data.member_shield_idx != 0:
		var reverse = {}
		for key in shield_melee_weapons.keys():
			var value = shield_melee_weapons[key]
			reverse[value] = key
			
		# switch to unshielded version
		if reverse.has(dup_squad_data.member_melee_weapon_idx):
			dup_squad_data.member_melee_weapon_idx = reverse[dup_squad_data.member_melee_weapon_idx]
		
	infantry_member.headgear = EntityIndex.head_armors[dup_squad_data.member_headgear_idx]
	infantry_member.armor = EntityIndex.armors[dup_squad_data.member_armor_idx]
	infantry_member.shield = EntityIndex.shields[dup_squad_data.member_shield_idx]
	infantry_member.melee_weapon = EntityIndex.melee_weapons[dup_squad_data.member_melee_weapon_idx]
	infantry_member.range_weapon = EntityIndex.range_weapons[dup_squad_data.member_range_weapon_idx]
	infantry_member.material = player_material
	horse.visible = dup_squad_data.is_mounted
	
	display_melee_weapons(dup_squad_data.member_melee_weapon_idx)
	display_range_weapons(dup_squad_data.member_range_weapon_idx)
	display_headgear(dup_squad_data.member_headgear_idx)
	display_armor(dup_squad_data.member_armor_idx)
	display_shield(dup_squad_data.member_shield_idx)
	display_fire_mode(dup_squad_data.range_fire_mode)
	display_role(dup_squad_data.squad_role)
	display_hero(dup_squad_data.is_hero)
	display_abilities(dup_squad_data, dup_squad_data.squad_ability_idx)
	display_attribute()
	show_shield_option()
	show_fire_mode_option()
	
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
	
	current_squads.append(dup)
	Global.save_custom_squad()
	
	display_current_squad()
	var idx = current_squads.size() - 1
	_on_squad_card_pressed(idx, current_squads[idx])

func _on_save_pressed():
	snack_bar.text = "Squad Saved!"
	snack_bar.show()
	
	var dup = SquadData.new()
	dup.from_dictionary(dup_squad_data.to_dictionary())
	
	current_squads[selected_index] = dup
	emit_signal("save_current_squads", current_squads, current_army)
	
	display_current_squad()
	_on_squad_card_pressed(selected_index, current_squads[selected_index])
	
func _on_delete_pressed():
	confirm_popup.visible = true
	confirm_popup.show_popup("Delete", "Delete squad\nThis also remove from army\nContinue?")
	var yes = yield(confirm_popup,"confirmed")
	confirm_popup.visible = false
	
	if not yes:
		return
	
	snack_bar.text = "Squad Deleted!"
	snack_bar.show()
	
	current_squads.remove(selected_index)
	
	while current_army.has(selected_index):
		current_army.erase(selected_index)
	
	# replace it with peasant
	while current_army.size() < 4:
		current_army.append(0)
	
	emit_signal("save_current_squads", current_squads, current_army)
	
	selected_index = 0
	display_current_squad()
	_on_squad_card_pressed(selected_index, current_squads[selected_index])
