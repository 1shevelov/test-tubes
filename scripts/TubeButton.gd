extends Button

signal but_pressed(num)

var num: int = 0


func _ready():
	set_text(String(num))
	# warning-ignore:return_value_discarded
	connect("but_pressed", get_parent(), "_on_but_pressed")


func set_coords(center_pos: Vector2) -> void:
	_set_global_position(center_pos - get_size() * 2)


func _on_TubeButton_toggled(button_pressed):
	if button_pressed:
		_set_position(get_position() + Vector2(0, - 15))
		_set_size(Vector2(get_size().x, get_size().y * 1.5))
	else:
		_set_position(get_position() + Vector2(0, 15))
		_set_size(Vector2(get_size().x, get_size().y / 1.5))
	emit_signal("but_pressed", num)

