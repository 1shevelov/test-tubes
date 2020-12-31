extends Node2D

const PORTION_SCENE := preload("res://scenes/PortionScene.tscn")
const BORDER : float = 0.05 # in %

var tube_size : Vector2
var tube_position : Vector2

var tube_content : Array = []

var portion_size : Vector2


func set_coords(pos: Vector2, size: Vector2) -> void:
	tube_position = pos
	tube_size = size
	portion_size = Vector2(tube_size.x * (1 - BORDER * 2), \
			tube_size.y * (1 - BORDER * 2) / Globals.MAX_TUBE_VOLUME)
	

func init(tube: Array) -> void:
	if check(tube):
		tube_content.resize(tube.size())
		var size_diff: int = Globals.MAX_TUBE_VOLUME - tube.size()
		for i in tube_content.size():
			var portion := PORTION_SCENE.instance()
			var portion_pos_y : float = tube_position.y + tube_size.y \
					* BORDER + portion_size.y * (i + size_diff)
			portion.set_coords(Vector2(tube_position.x + tube_size.x * BORDER, \
					portion_pos_y), portion_size)
			tube_content[i] = portion
			add_child(tube_content[i])
			tube_content[i].set_color(0)
	

# check before every update
func check(tube: Array) -> bool:
	if tube.empty():
		print_debug("Tube is empty")
		return false
	if tube.size() > Globals.MAX_TUBE_VOLUME:
		print_debug("Tube is too big: ", tube.size())
		return false
	for each in tube:
		if each < 0 || each > Globals.MAX_COLORS:
			print_debug("Wrong color: ", each)
			return false
	return true
	

func update_tube(tube: Array) -> void:
	if check(tube):
		var curr_portion: int = tube_content.size() - 1
		for i in range(tube.size() - 1, -1, -1):
			tube_content[curr_portion].set_color(tube[i])
			curr_portion -= 1


func _draw():
	var curr_height: float = tube_size.y * tube_content.size() \
			/ Globals.MAX_TUBE_VOLUME
	var curr_pos_y: float = tube_position.y + tube_size.y \
			* (1 - float(tube_content.size()) / Globals.MAX_TUBE_VOLUME)
	draw_rect(Rect2(Vector2(tube_position.x, curr_pos_y),
			Vector2(tube_size.x, curr_height)), Color.white, false)
