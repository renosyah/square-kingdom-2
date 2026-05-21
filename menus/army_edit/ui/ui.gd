extends Control

const dragable_card_scene = preload("res://assets/dragable_card/dragable_card.tscn")

onready var army_label = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/VBoxContainer/army_container/VBoxContainer/Label2

onready var squad_holder = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/squad_container/VBoxContainer/HBoxContainer/ScrollContainer/squad_holder
onready var army_squad_holder = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/VBoxContainer/army_container/VBoxContainer/HBoxContainer/army_squad_holder_holder

onready var army_container = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/VBoxContainer/army_container
onready var squad_container = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/squad_container
onready var trash_area = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/trash_area

onready var trash_highlight = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/trash_area/highlight
onready var army_highlight = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/VBoxContainer/army_container/highlight
onready var squad_highlight = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/squad_container/highlight

onready var dragable_item = $CanvasLayer/Control/dragable_item
onready var add_button_squad = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/squad_container/VBoxContainer/HBoxContainer/ScrollContainer/squad_holder/add_button_squad

onready var info = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/info
onready var snack_bar = $CanvasLayer/Control/snack_bar

onready var areas = {
	trash_area:trash_highlight,
	army_container:army_highlight,
	squad_container:squad_highlight
}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	set_process(false)
	
	display_current_squad()
	display_current_army()
	
	Global.hide_transition()
	
func _process(delta):
	var pos = dragable_item.rect_position
	for key in areas.keys():
		areas[key].visible = _is_point_inside_area(key, pos)
	
func display_current_squad():
	squad_holder.remove_child(add_button_squad)
	
	for i in squad_holder.get_children():
		squad_holder.remove_child(i)
		i.queue_free()
		
	var idx = 0
	for data in Global.custom_squads:
		var card = preload("res://assets/user_interface/squad_card/squad_card.tscn").instance()
		data.color_idx = Global.player_data.color_idx
		card.data = data
		
		var dragable = dragable_card_scene.instance()
		var c = MarginContainer.new()
		c.mouse_filter = MOUSE_FILTER_IGNORE
		c.add_child(card)
		
		dragable.connect("on_grab", self, "_on_card_on_grab", [c, Global.custom_squads[idx]])
		dragable.connect("on_draging", self, "_on_card_on_draging")
		dragable.connect("on_release", self, "_on_card_on_release", [idx, 1])
		dragable.connect("on_cancel", self, "_on_card_on_cancel")
		
		squad_holder.add_child(dragable)
		dragable.add_child(c)
		
		idx += 1
		
	squad_holder.add_child(add_button_squad)
	
func display_current_army():
	for i in army_squad_holder.get_children():
		army_squad_holder.remove_child(i)
		i.queue_free()
		
	var squads = Global.custom_squads
	
	var idx = 0
	for i in Global.current_army:
		var card = preload("res://assets/user_interface/squad_card/squad_card.tscn").instance()
		card.data = squads[i]
		
		var dragable = dragable_card_scene.instance()
		var c = MarginContainer.new()
		c.mouse_filter = MOUSE_FILTER_IGNORE
		c.add_child(card)
		
		dragable.connect("on_grab", self, "_on_card_on_grab", [c, Global.custom_squads[i]])
		dragable.connect("on_draging", self, "_on_card_on_draging")
		dragable.connect("on_release", self, "_on_card_on_release", [idx, 2])
		dragable.connect("on_cancel", self, "_on_card_on_cancel")
		
		army_squad_holder.add_child(dragable)
		dragable.add_child(c)
		
		idx += 1
	
	army_label.text = "  Army (%s/%s)" % [Global.current_army.size(), Global.max_army_size]
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
			
func _is_point_inside_area(container :MarginContainer, point: Vector2) -> bool:
	var x: bool = point.x >= container.rect_global_position.x and point.x <= container.rect_global_position.x + (container.rect_size.x * container.get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= container.rect_global_position.y and point.y <= container.rect_global_position.y + (container.rect_size.y * container.get_global_transform_with_canvas().get_scale().y)
	return x and y
	
func _on_card_on_grab(card, pos, container, data):
	card.modulate.a = 0.2
	dragable_item.visible = true
	dragable_item.rect_position = pos
	dragable_item.add_child(container.duplicate(true))
	set_process(true)
	
	info.display_info(data)
	
func _on_card_on_draging(card, pos):
	dragable_item.rect_position = pos
	
func _on_card_on_release(card, pos, idx, type_drag):
	card.modulate.a = 1
	dragable_item.visible = false
	var _child = dragable_item.get_child(0)
	dragable_item.remove_child(_child)
	_child.queue_free()
	set_process(false)
	
	# asume drag from squad to army container
	if type_drag == 1 and areas[army_container].visible:
		if Global.current_army.size() < Global.max_army_size:
			Global.current_army.append(idx)
			
	# asume drag from squad to trash
	# and ajust the army too
	if type_drag == 1 and areas[trash_area].visible:
		Global.custom_squads.remove(idx)
		display_current_squad()
		
		var dups = Global.current_army.duplicate()
		Global.current_army.clear()
		
		for new_idx in dups:
			if new_idx != idx:
				Global.current_army.append(new_idx)
			
	# asume drag from army container to trash or back to squad
	# which honestly work the same as removing it
	if type_drag == 2 and (areas[trash_area].visible or areas[squad_container].visible):
		if Global.current_army.size() > 0:
			Global.current_army.remove(idx)
			
	Global.sort_army()
	display_current_army()
	
	for key in areas.keys():
		areas[key].visible = false
	
func _on_card_on_cancel(card):
	card.modulate.a = 1
	dragable_item.visible = false
	var _child = dragable_item.get_child(0)
	dragable_item.remove_child(_child)
	_child.queue_free()
	set_process(false)
	
	for key in areas.keys():
		areas[key].visible = false
		
func _on_delete_button_pressed():
	Global.current_army.clear()
	display_current_army()
	
func _on_back_pressed():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)

func _on_save_pressed():
	Global.save_custom_squad()
	snack_bar.text = "Army saved!"
	snack_bar.show()


















