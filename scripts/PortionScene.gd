extends Node2D

const EMPTY_COLOR := Color.black

onready var color_rect: ColorRect = $Container/Portion


func _ready():
	color_rect.set_custom_minimum_size($Container.get_size())


func set_coords(pos: Vector2, size: Vector2):
	$Container._set_global_position(pos)
	$Container._set_size(size)
	$Container.set_custom_minimum_size(size)



func set_color(new_color: int) -> void:
	if !is_instance_valid(color_rect):
		color_rect = $Container/Portion
	if new_color <= 0 || new_color > Globals.MAX_COLORS:
		color_rect.set_frame_color(EMPTY_COLOR)
		#color_rect.set_visible(false)
		return
	color_rect.set_frame_color(Globals.VALERIA_palette[new_color - 1])
	#color_rect.set_visible(true)
		

#func _draw():
#	draw_rect(Rect2($Container.get_global_position(), $Container.get_size()), \
#			Color.red, false)
	
