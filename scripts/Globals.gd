extends Node

signal show_message(msg)

const MAX_COLORS := 10
# the game will finish after this number of moves
const MAX_MOVES := 50
const MAX_TUBE_VOLUME := 8
const MAX_TUBES := 16

const VALERIA_palette := PoolColorArray([Color8(204, 6, 5), Color8(59, 131, 189),
	Color8(250, 210, 1), Color8(246, 246, 246), Color8(87, 166, 57),
	Color8(108, 70, 117), Color8(255, 117, 20), Color8(132, 195, 190),
	Color8(234, 137, 154), Color8(130, 137, 143)])
const EMPTY_COLOR := Color8(0, 0, 0, 96)
const NO_COLOR := Color.transparent

var _curr_level: Level setget set_level, get_level
var game_scene  # game scene node

const LEVELS_PATH := "res://levels"

const VPS_MIN := Vector2(800, 600)


func set_message_receiver(receiver_node) -> void:
	# warning-ignore:return_value_discarded
	connect("show_message", receiver_node, "message_show", [], CONNECT_DEFERRED)
	
	
# to show messages to user
func send_message(msg: String) -> void:
	emit_signal("show_message", msg)


func set_level(new_level: Level) -> void:
	_curr_level = new_level
	
	
func get_level() -> Level:
	return _curr_level


func get_level_biggest_tube():
	var biggest_tube: int = 0
	for each in _curr_level.get_all_tubes_content():
		if each.size() > biggest_tube:
			biggest_tube = each.size()
	return biggest_tube
