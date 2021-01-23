extends ColorRect


func _ready():
	#color_rect.set_custom_minimum_size($Container.get_size())
	pass


#func set_coords(pos: Vector2, size: Vector2):
#	$Container._set_global_position(pos)
#	$Container._set_size(size)
#	$Container.set_custom_minimum_size(size)


func set_color(new_color: int) -> void:
#	if !is_instance_valid(color_rect):
#		color_rect = $Container/Portion
	if new_color == 0:
		set_frame_color(Globals.EMPTY_COLOR)
	elif new_color == -1:
		set_frame_color(Globals.NO_COLOR)
	elif new_color > 0 && new_color <= Globals.MAX_COLORS:
		set_frame_color(Globals.VALERIA_palette[new_color - 1])
	else:
		print_debug("Invalid color value: ", new_color)
		

#func _draw():
#	draw_rect(Rect2($Container.get_global_position(), $Container.get_size()), \
#			Color.red, false)
	
