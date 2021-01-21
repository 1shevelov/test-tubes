extends Control

var menu

var game: Game

const TUBE_SCENE := preload("res://scenes/TubeScene.tscn")
#var tubes: Array = [] # of TUBE_SCENE

var BORDER := 0.1 # in %

onready var instruction: Label = $MarginMain/VBoxMain/Help/Instruction
onready var message: Label = $MarginMain/VBoxMain/ErrorMessages/Message
onready var counters: Label = $MarginMain/VBoxMain/CountersCont/Counters

#const TUBE_SIZE := Vector2(50, 250)
onready var tubes_margins: MarginContainer = $MarginMain/VBoxMain/MarginTubes
onready var tubes: GridContainer = $MarginMain/VBoxMain/MarginTubes/GridTubes
const TUBES_GAP := 0.1 # in %
const TUBES_MARGIN := 0.25

const BUTTON:= preload("res://scenes/TubeButton.tscn")
var tube_buttons: Array = []
var bottom_buttons: Array = [] # for bottom faucets

# the tube with a source portion
var source_tube: int = -1
var source_bottom_faucet: bool = false

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
		
	game = Game.new()
	instruction.set_text("""Click the button above the tube to take a portion from
and a button above the other to pour the portion to.""")
	Globals.set_message_receiver(self)
	tubes_number = Globals.get_level().get_tubes_number()
	tubes.set_columns(tubes_number)
	show_tubes()
	update_counters()


func _on_root_size_changed() -> void:
	var ROOT_SIZE: Vector2 = $"/root".get_size()
	#print_debug("tubes= %s, root.x= %s, gap= %s" % [tubes_number, ROOT_SIZE.x,
	#		ROOT_SIZE.x * TUBES_GAP * (1 - tubes_number / Globals.MAX_TUBES)])
	var tubes_num_coeff: float = (1 - float(tubes_number) / Globals.MAX_TUBES)
	tubes_margins.add_constant_override("margin_left", ROOT_SIZE.x \
			* TUBES_MARGIN * tubes_num_coeff * tubes_num_coeff)
	tubes_margins.add_constant_override("margin_right", ROOT_SIZE.x \
			* TUBES_MARGIN * tubes_num_coeff * tubes_num_coeff)
	tubes.add_constant_override("hseparation", ROOT_SIZE.x * TUBES_GAP * tubes_num_coeff)


func show_tubes() -> void:
	#var ROOT_SIZE : Vector2 = $"/root".get_size()
	
#	var instructions_for_drain: bool = false
	for i in tubes_number:
		#var screen_part : float = (ROOT_SIZE.x - ROOT_SIZE.x * BORDER * 2) / tubes_number
		#var tube_center_x : float = ROOT_SIZE.x * BORDER + screen_part * (0.5 + i)
		#print_debug("Root.x = %s, center = %s" % [ROOT_SIZE.x, tube_center_x])
		#var tube_position := Vector2(tube_center_x - TUBE_SIZE.x / 2, \
		#		ROOT_SIZE.y * BORDER * 3)
		var a_tube := TUBE_SCENE.instance()
		#a_tube.set_coords(tube_position, TUBE_SIZE)
		a_tube.init(Globals.get_level().get_tube(i).get_content())
		#add_child(tubes[i])
		a_tube.update_tube(Globals.get_level().get_tube(i).get_content())
		tubes.add_child(a_tube)
		
#		var cr := ColorRect.new()
#		cr.set_frame_color(Color.red)
#		cr.set_h_size_flags(SIZE_EXPAND_FILL)
#		cr.set_v_size_flags(SIZE_EXPAND_FILL)
#		#cr.set_custom_minimum_size(Vector2(100, 100))
#		tubes.add_child(cr)
#		if Globals.get_level().get_tube(i).drains != Tube.DRAINS.BOTTOM:
#			var button_center_pos := Vector2(tube_center_x, ROOT_SIZE.y \
#					* BORDER * 2.5)
#			tube_buttons.append(add_button(i, false, button_center_pos))
		
#		if Globals.get_level().get_tube(i).drains != Tube.DRAINS.NECK:
#			if !instructions_for_drain:
#				instruction.set_text(instruction.get_text() + \
#					"\nButton at the bottom of a tube allows to drain a portion, but not pour in")
#				instructions_for_drain = true
#			var bottom_button_pos := Vector2(tube_center_x, ROOT_SIZE.y \
#					* BORDER * 3.7 + TUBE_SIZE.y)
#			bottom_buttons.append(add_button(i, true, bottom_button_pos))
	
	#message._set_global_position(Vector2(200, ROOT_SIZE.y * BORDER * 0.7))
	#instruction._set_global_position(Vector2(ROOT_SIZE.x / 2 \
	#		- 170, ROOT_SIZE.y * BORDER * 4.5 + TUBE_SIZE.y))
	#counters._set_global_position(Vector2(ROOT_SIZE.x / 2 - 70, 25))
	_on_root_size_changed()


func update_tubes() -> void:
	for i in tubes.size():
		tubes[i].update_tube(Globals.get_level().get_tube(i).get_content())


func add_button(num: int, is_bottom: bool, center_pos: Vector2) -> Button:
	var button: Button = BUTTON.instance()
	button.num = num
	button.is_bottom = is_bottom
	button.set_coords(center_pos)
	add_child(button)
	return button


func _on_but_pressed(num: int, is_bottom: bool) -> void:
	if source_tube == -1:
		source_tube = num
		source_bottom_faucet = is_bottom
		message_clear()
	elif source_tube == num:
		source_tube = -1
		source_bottom_faucet = false
		reset_buttons()
		message_clear()
	elif source_tube != -1 && is_bottom:
		source_tube = -1
		source_bottom_faucet = false
		reset_buttons()
		print_debug("Bottom faucets can only drain liquids")
		Globals.send_message("Bottom faucets can only drain liquids")
	else:
		if !game.pour(source_tube, source_bottom_faucet, num):
			print_debug("Can't pour from %s to %s" % [source_tube, num])
			Globals.send_message("Can't pour from %s to %s" % [source_tube, num])
		else:
			update_tubes()
			update_counters()
		source_tube = -1
		source_bottom_faucet = false
		reset_buttons()
		if Globals.get_level().check_win_condition():
			#print_debug("GAME IS WON!")
			Globals.send_message("GAME IS WON!")
			end_game()
		elif game.get_pours() > Globals.MAX_MOVES:
			#print_debug("GAME IS LOST: TOO MANY MOVES!")
			Globals.send_message("GAME IS LOST: TOO MANY MOVES!")
			end_game()
	
	
func reset_buttons() -> void:
	for each in tube_buttons:
		each.set_pressed(false)
	for each in bottom_buttons:
		each.set_pressed(false)


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



