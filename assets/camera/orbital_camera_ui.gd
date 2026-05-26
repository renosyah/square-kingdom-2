extends Control

const is_dekstop = ["Server", "Windows", "WinRT", "X11"]
const is_android = ["Android"]

export var rotate_speed := 0.15
export var detect_in_out :bool
export var min_pitch := -80.0
export var max_pitch := -10.0
export var use_unhandle :bool

var zoom_speed := 0.02
export var min_zoom :float = 2
export var max_zoom :float = 3

var orbit_pivot :MovableCamera
var camera :Camera

var _dragging := false
var _pitch := -45.0

onready var _use_mouse :bool = OS.get_name() in is_dekstop
onready var _label = $Label

# touchscreen
var touches := {}
var is_pinch_zoom := false
var last_pinch_distance := 0.0

func _ready():
	if not use_unhandle:
		mouse_filter = Control.MOUSE_FILTER_STOP
		connect("gui_input", self, "_on_movable_camera_ui_gui_input")
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_movable_camera_ui_gui_input(event):
	_input_control(event)
	
func _unhandled_input(event):
	if use_unhandle:
		_input_control(event)
		
func _input_control(event):
	if not visible:
		return
		
	if _use_mouse:
		_input_mouse(event)
	else:
		_input_touch(event)
		
func _input_mouse(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			_dragging = event.pressed
			return
			
		if event.button_index == BUTTON_WHEEL_UP:
			_zoom_camera(-zoom_speed)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_zoom_camera(zoom_speed)
		
	elif event is InputEventMouseMotion and _dragging:
		_rotate_camera(event.relative)
		
func _input_touch(event):
	if event is InputEventScreenTouch:
		if not _is_point_inside_area(event.position):
			return
		
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			if touches.size() < 2:
				is_pinch_zoom = false
	
	elif event is InputEventScreenDrag:
		touches[event.index] = event.position
		if touches.size() == 1:
			_rotate_camera(event.relative)
		
		elif touches.size() == 2:
			# Pinch zoom
			var keys = touches.keys()
			var pos1 = touches[keys[0]]
			var pos2 = touches[keys[1]]
			
			var current_distance = pos1.distance_to(pos2)
			
			if !is_pinch_zoom:
				is_pinch_zoom = true
				last_pinch_distance = current_distance
				
			else:
				var delta_distance = current_distance - last_pinch_distance
				_zoom_camera(-delta_distance * zoom_speed)
				last_pinch_distance = current_distance
				
	_label.text = "Cam pos : %s" % camera.translation
	
func _rotate_camera(relative :Vector2):
	# horizontal orbit
	orbit_pivot.rotation_degrees.y -= (
		relative.x * rotate_speed * 0.011
	)
	# vertical orbit
	_pitch -= relative.y * rotate_speed * 0.011
	_pitch = clamp(
		_pitch,
		min_pitch,
		max_pitch
	)
	orbit_pivot.rotation_degrees.x = _pitch
	
func _zoom_camera(amount :float):
	camera.translation.z += amount
	camera.translation.z = clamp(
		camera.translation.z,
		min_zoom,
		max_zoom
	)
	
func _is_point_inside_area(point: Vector2) -> bool:
	if not use_unhandle:
		return true
		
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y
