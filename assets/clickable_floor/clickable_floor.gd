extends Spatial
class_name ClickableFloor

signal on_floor_clicked(pos)

var _click_position :Vector3

onready var _input_detection = $input_detection
onready var _is_dekstop = OS.get_name() in Global.dekstops

func _on_Area_input_event(_camera, event, position, _normal, _shape_idx):
	_click_position = position
	if _is_dekstop:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					emit_signal("on_floor_clicked", _click_position)
	else:
		_input_detection.check_input(event)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_floor_clicked", _click_position)
		

