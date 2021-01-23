extends Control

var menu

var game: Game

const TUBE_SCENE := preload("res://scenes/TubeScene.tscn")

var BORDER := 0.1 # in %

onready var counters: Label = $MarginMain/VBoxMain/CountersCont/Counters
onready var message_cont := $MarginMain/VBoxMain/ErrorMessages
onready var message: Label = $MarginMain/VBoxMain/ErrorMessages/Message
onready var instruction_cont := $MarginMain/VBoxMain/Help
onready var instruction: Label = $MarginMain/VBoxMain/Help/Instruction

onready var tubes: GridContainer = $MarginMain/VBoxMain/MarginTubes/GridTubes
const TUBES_GAP := 0.1 # in %
const TUBES_MARGIN := 0.25

var tube_buttons: Array = []
var bottom_buttons: Array = [] # for bottom faucets

# the tube with a source portion
var source_tube: int = -1
var source_neck: bool = false

var tubes_number: int = 0


func init(parent) -> void:
	menu = parent


func _ready():
	if !is_instance_valid(Globals.get_level()):
		print_debug("Level wasn't initialized")
		menu.close_game()
	# warning-ignore:return_value_discarded
	$"/root".connect("size_changed", self, "_on_root_size_changed", [], \
			CONNECT_DEFERRED)
	Globals.game_scene = self
		
	game = Game.new()
	instruction.set_text("""Click the tube to take a portion from
and any other to pour this portion to.""")
	Globals.set_message_receiver(self)
	tubes_number = Globals.get_level().get_tubes_number()
	tubes.set_columns(tubes_number)
	show_tubes()
	update_counters()


func _on_root_size_changed() -> void:
	var ROOT_SIZE: Vector2 = $"/root".get_size()
	var tubes_num_coeff: float = (1 - float(tubes_number) / Globals.MAX_TUBES)

	tubes.add_constant_override("hseparation", int(ROOT_SIZE.x * TUBES_GAP \
			* tubes_num_coeff))
	for each in tubes.get_children():
		each.set_custom_minimum_size(Vector2(ROOT_SIZE.x * 0.15 * tubes_num_coeff,
				ROOT_SIZE.y * 0.53))
			
	var font: DynamicFont = counters.get_font("string_name", "")
	var coeff: int = 3
	if ROOT_SIZE.y > 1000:
		coeff = 5
	font.set_size(int(ROOT_SIZE.y / 30) - coeff)
	
	message_cont.set_custom_minimum_size(Vector2(0, ROOT_SIZE.y / 8.4))
	instruction_cont.set_custom_minimum_size(Vector2(0, ROOT_SIZE.y / 8))


func show_tubes() -> void:
	var instructions_for_drain: bool = false
	for i in tubes_number:
		var a_tube := TUBE_SCENE.instance()
		tubes.add_child(a_tube)
		a_tube.init(i + 1, Globals.get_level().get_tube(i).get_content())
		a_tube.update_tube(Globals.get_level().get_tube(i).get_content())
		a_tube.set_pointers(Globals.get_level().get_tube(i).drains)
		
		if Globals.get_level().get_tube(i).drains != Tube.DRAINS.NECK:
			if !instructions_for_drain:
				instruction.set_text(instruction.get_text() + \
					"\nIf a tube has a faucet at the bottom you can drain a portion from it,\nbut you can't pour in through it")
				instructions_for_drain = true
	
	_on_root_size_changed()


func update_tubes() -> void:
	var all_tubes: Array = tubes.get_children()
	for i in all_tubes.size():
		all_tubes[i].update_tube(Globals.get_level().get_tube(i).get_content())


func _on_tube_clicked(num: int, is_neck: bool) -> void:
	if source_tube == -1:
		source_tube = num - 1
		source_neck = is_neck
		message_clear()
	elif source_tube == num - 1:
		source_tube = -1
		source_neck = true
		reset_pointers()
		message_clear()
	elif source_tube != -1 && !is_neck:
		source_tube = -1
		source_neck = true
		reset_pointers()
		print_debug("Bottom faucets can only drain liquids")
		Globals.send_message("Bottom faucets can only drain liquids")
	else:
		if !game.pour(source_tube, source_neck, num - 1):
			print_debug("Can't pour from %s to %s" % [source_tube + 1, num])
			Globals.send_message("Can't pour from %s to %s" % [source_tube + 1, num])
		else:
			update_tubes()
			update_counters()
		source_tube = -1
		source_neck = true
		reset_pointers()
		if Globals.get_level().check_win_condition():
			#print_debug("GAME IS WON!")
			Globals.send_message("GAME IS WON!")
			end_game()
		elif game.get_pours() > Globals.MAX_MOVES:
			#print_debug("GAME IS LOST: TOO MANY MOVES!")
			Globals.send_message("GAME IS LOST: TOO MANY MOVES!")
			end_game()
	
	
func reset_pointers() -> void:
	var all_tubes: Array = tubes.get_children()
	for i in all_tubes.size():
		all_tubes[i].reset_pointers()


func message_show(msg: String) -> void:
	message.set_text("%s\n%s" % [message.get_text(), msg])
	
	
func message_clear() -> void:
	message.set_text("")
	

func update_counters() -> void:
	counters.set_text("MOVES: %2d,  VOLUME: %3d" % [game.get_pours(), \
			game.get_pours_volume()])


func end_game() -> void:
	$FinishPopup.get_close_button().set_visible(false)
	$FinishPopup.set_text("%s\n%s" % [get_game_rating(), $FinishPopup.get_text()])
	$FinishPopup.set_title("Game finished")
	$FinishPopup.popup_centered()


func _on_FinishPopup_confirmed():
	menu.close_game()


func get_game_rating() -> String:
	var rating: int = Globals.get_level().get_performance(game.get_pours(), game.get_pours_volume())
	var stars: String = ""
	if rating == 1:
		stars = "a ONE STAR"
	elif rating == 0:
		stars = "NO STARS"
	elif rating == -1:
		stars = "NO LEVEL RATINGS"
	else:
		stars = "%s STARS" % rating
	return """%s moves and %s liquid portions poured
earn you %s.""" % [game.get_pours(), game.get_pours_volume(), stars]


func _on_ButtonMenu_pressed():
	Globals.get_level().reset_level()
	menu.close_game()


func _on_ButtonRestart_pressed():
	menu.restart_game()



