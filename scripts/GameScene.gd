extends Node2D

var menu

var game : Game
const TUBE_SCENE := preload("res://scenes/TubeScene.tscn")
var tubes: Array = [] # of TUBE

var BORDER := 0.2 # in %

const TUBE_SIZE := Vector2(70, 250)

const BUTTON:= preload("res://scenes/TubeButton.tscn")
var tube_buttons: Array = []
onready var instruction: Label = $Instruction
onready var message: Label = $Message

# the tube with a source portion
var source_tube: int = -1


func init(parent) -> void:
	menu = parent


func _ready():
	game = Game.new()
	instruction.set_text("""Click the button under the tube to take a portion from
and a button under the other to pour the portion to.""")
	Globals.set_message_receiver(self)
	if game.init():
		tubes.resize(game.get_tubes_number())
		tube_buttons.resize(game.get_tubes_number())
		show_tubes()
		update_counters()


func show_tubes() -> void:
	var ROOT_SIZE : Vector2 = $"/root".get_size()
	
	for i in tubes.size():
		var screen_part : float = (ROOT_SIZE.x - ROOT_SIZE.x * BORDER * 2) / tubes.size()
		var tube_center_x : float = ROOT_SIZE.x * BORDER + screen_part * (0.5 + i)
		#print_debug("Root.x = %s, center = %s" % [ROOT_SIZE.x, tube_center_x])
		var tube_position := Vector2(tube_center_x - TUBE_SIZE.x / 2, ROOT_SIZE.y * BORDER)
		var a_tube := TUBE_SCENE.instance()
		a_tube.set_coords(tube_position, TUBE_SIZE)
		tubes[i] = a_tube
		tubes[i].init(game.TUBES[i])
		add_child(tubes[i])
		tubes[i].update_tube(game.TUBES[i])
		var button_center_pos := Vector2(tube_center_x, ROOT_SIZE.y * BORDER * 1.7 + TUBE_SIZE.y)
		tube_buttons[i] = add_button(i, button_center_pos)
	
	message._set_global_position(Vector2(250, ROOT_SIZE.y * BORDER * 0.4))
	instruction._set_global_position(Vector2(ROOT_SIZE.x / 2 \
			- 170, ROOT_SIZE.y * BORDER * 2 + TUBE_SIZE.y))
	$Counters._set_global_position(Vector2(ROOT_SIZE.x / 2 - 70, 25))


func update_tubes() -> void:
	for i in tubes.size():
		tubes[i].update_tube(game.tubes[i].get_content())


func add_button(num: int, center_pos: Vector2) -> Button:
	var button: Button = BUTTON.instance()
	button.num = num
	button.set_coords(center_pos)
	add_child(button)
	return button


func _on_but_pressed(num: int) -> void:
	if source_tube == -1:
		source_tube = num
		message_clear()
	elif source_tube == num:
		source_tube = -1
		message_clear()
	else:
		if !game.pour(source_tube, num):
			print_debug("Can't pour from %s to %s" % [source_tube, num])
			Globals.send_message("Can't pour from %s to %s" % [source_tube, num])
		else:
			update_tubes()
			update_counters()
		source_tube = -1
		reset_buttons()
		if game.check_if_complete():
			print_debug("GAME IS WON!")
			Globals.send_message("GAME IS WON!")
			end_game()
	
	
func reset_buttons() -> void:
	for each in tube_buttons:
		each.set_pressed(false)


func message_show(msg: String) -> void:
	message.set_text("%s\n%s" % [message.get_text(), msg])
	
	
func message_clear() -> void:
	message.set_text("")
	

func update_counters() -> void:
	$Counters.set_text("MOVES: %2d,  VOLUME: %3d" % [game.get_pours(), game.get_pours_volume()])


func end_game() -> void:
	$FinishPopup.get_close_button().set_visible(false)
	$FinishPopup.set_title("Game finished")
	$FinishPopup.popup_centered()


func _on_FinishPopup_confirmed():
	menu.close_game()


