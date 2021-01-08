extends Node2D

const PORTION_SCENE := preload("res://scenes/PortionScene.tscn")
const BORDER : float = 0.03 # in %

var TUBE_SIZE : Vector2 # size of the MAX_VOLUME tube
var tube_position : Vector2

var tube_content : Array = []

var portion_size : Vector2


func set_coords(pos: Vector2, SIZE: Vector2) -> void:
	tube_position = pos
	TUBE_SIZE = SIZE
	portion_size = Vector2(TUBE_SIZE.x * (1 - BORDER * 2), \
			TUBE_SIZE.y * (1 - BORDER * 2) / Globals.MAX_TUBE_VOLUME)
	

func init(tube: Array) -> void:
	if check(tube):
		tube_content.resize(tube.size())
		#var size_diff: int = Globals.MAX_TUBE_VOLUME - tube.size()
		for i in tube_content.size():
			var portion := PORTION_SCENE.instance()
			var portion_pos_y : float = tube_position.y + TUBE_SIZE.y * BORDER + portion_size.y * i# + size_diff)
			portion.set_coords(Vector2(tube_position.x + TUBE_SIZE.x * BORDER, \
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
	var curr_height: float = TUBE_SIZE.y * (float(tube_content.size()) / Globals.MAX_TUBE_VOLUME + 2 * BORDER)
	var curr_pos_y: float = tube_position.y# + TUBE_SIZE.y - curr_height
	draw_rect(Rect2(Vector2(tube_position.x, curr_pos_y),
			Vector2(TUBE_SIZE.x, curr_height)), Color.white, false)
