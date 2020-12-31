extends Node

signal show_message(msg)

const MAX_COLORS := 10
const MAX_TUBE_VOLUME := 4

const VALERIA_palette := PoolColorArray([Color8(204, 6, 5), Color8(59, 131, 189),
	Color8(250, 210, 1), Color8(246, 246, 246), Color8(87, 166, 57),
	Color8(108, 70, 117), Color8(255, 117, 20), Color8(132, 195, 190),
	Color8(234, 137, 154), Color8(130, 137, 143)])


func set_message_receiver(receiver_node: Node2D) -> void:
	# warning-ignore:return_value_discarded
	connect("show_message", receiver_node, "message_show", [], CONNECT_DEFERRED)
	
	
# to show messages to user
func send_message(msg: String) -> void:
	emit_signal("show_message", msg)


