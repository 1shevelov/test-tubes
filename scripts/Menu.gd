extends Control

const GAME_SCENE := preload("res://scenes/GameScene.tscn")
var game_scene

const LEVEL_LABEL := preload("res://scenes/LevelLabel.tscn")
var ready_levels: Array = [] # of Level
onready var ready_levels_list: VBoxContainer = $MainHBox/MainVBox/ScrollContainer/LevelSelection

onready var main_vbox: VBoxContainer = $MainHBox/MainVBox
onready var title: RichTextLabel = $MainHBox/MainVBox/VBoxTitle/RTLTitle
onready var import_text_control: TextEdit = $DialogImport/MarginCont/VBoxCont/InputText


func _ready():
	OS.set_min_window_size(Globals.VPS_MIN)
	make_ready_levels_list()
	load_import_help()
	# warning-ignore:return_value_discarded
	$"/root".connect("size_changed", self, "_on_root_size_changed", [], \
			CONNECT_DEFERRED)
	_on_root_size_changed()


func _on_root_size_changed() -> void:
	var ROOT_SIZE: Vector2 = $"/root".get_size()
	
	main_vbox.set_custom_minimum_size(Vector2(ROOT_SIZE.x * 0.75, ROOT_SIZE.y * 0.9))
	var coeff: int = 3
	if ROOT_SIZE.y > 1000:
		coeff = 5
		
	var font: DynamicFont = title.get_font("string_name", "")
	font.set_size(int(ROOT_SIZE.y / 18))
	title._set_size(Vector2(title.get_size().x, font.get_size() + coeff))
	
	var sample_label = ready_levels_list.get_child(0)
	font = sample_label.get_font("string_name", "")
	font.set_size(int(ROOT_SIZE.y / 30) - coeff)
	#print_debug("%s - %s" % [int(ROOT_SIZE.y / 30), font.get_size()])
	
	$DialogImport._set_size(ROOT_SIZE * 0.8)
	font = import_text_control.get_font("string_name", "")
	font.set_size(int(ROOT_SIZE.x / 55) - coeff)


func close_game() -> void:
	if is_instance_valid(game_scene):
		game_scene.queue_free()
	set_visible(true)
	
	
func restart_game() -> void:
	close_game()
	run_game()


func make_ready_levels_list() -> void:
	load_levels()
	for i in ready_levels.size():
		var l := LEVEL_LABEL.instance()
		l.label_text = ready_levels[i].description
		l.menu = self
		l.set_name("LevelLabel_%s" % [i + 1])
		ready_levels_list.add_child(l)

	
func run_game() -> void:
	#set_level2()
	if is_instance_valid(Globals.get_level()):
		self.set_visible(false)
		game_scene = GAME_SCENE.instance()
		game_scene.init(self)
		$"/root".add_child(game_scene)
	else:
		print_debug("Game initialization failed")
	#game_scene.set_visible(true)


func _on_label_clicked(label_num: int) -> void:
	Globals.set_level(ready_levels[label_num - 1])
	run_game()


#func set_level1() -> void:
#	var l := Level.new()
#	if l.set_tubes([
#		[0, 1, 2, 5],
#		[0, 5, 2, 1],
#		[0, 0, 0],
#		[5, 2, 5, 1]
#	]):
#		l.description = "[center][color=lime]EASY[/color]\n4 tubes, 3 colors - 8 moves[/center]"
#		if !l.add_rating({"stars": 3, "moves": 8, "vol": 11}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 2, "moves": 9, "vol": 13}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 1, "moves": 9, "vol": 15}):
#			print_debug("Invalid rating")
#		ready_levels.append(l)
#	else:
#		print_debug("Error while activating level 1")


func load_levels() -> void:
	if !ready_levels.empty():
		ready_levels.clear()
	var files_list: Array = get_ready_levels_list()
	if files_list.empty():
		print_debug("No level files found")
		return
	for each_file in files_list:
		var level_data: Dictionary = load_level(each_file)
		var l := Level.new()
		if l.import_level(level_data):
			ready_levels.append(l)
		else:
			print_debug("Was unable to load level '%s'" % each_file)


func load_level(path: String) -> Dictionary:
	var file: File = File.new()
	if !file.file_exists(path):
		print_debug("File '%s' was not found" % path)
		return {}
	var err: int = file.open(path, file.READ)
	if err != OK:
		print_debug("Error while opening file: ", path)
		print_debug("Error message: ", err)
		file.close()
		return {}
	var level_str: String = file.get_as_text()
	return level_str2dic(level_str)


func level_str2dic(level_str: String) -> Dictionary:
	var err2: String = validate_json(level_str)
	if err2 != "":
		print_debug("Invalid JSON data, error: ", err2)
		return {}
	var level_data = parse_json(level_str)
	if typeof(level_data) != TYPE_DICTIONARY:
		print_debug("JSON data is of invalid type: ", typeof(level_data))
		return {}
	if level_data.empty():
		print_debug("Level data is empty")
		return {}
	return level_data
	

func get_ready_levels_list() -> Array:
	var LEVEL_EXT: String = "json"
	
	var err: int
	var dir: Directory = Directory.new()
	if !dir.dir_exists(Globals.READY_LEVELS_PATH):
		print_debug("Ready levels directory not found!?")
		return []
	err = dir.open(Globals.READY_LEVELS_PATH)
	if err != OK:
		print_debug("Error accessing ready levels directory: ", err)
		return []
	err = dir.list_dir_begin(true, false)
	if err != OK:
		print_debug("Error while reading dir content: ", err)
		return []
	var file_name: String = dir.get_next()
	var files_list: Array = []
	while file_name != "":
		if  file_name.get_extension() == LEVEL_EXT:
			files_list.append(Globals.READY_LEVELS_PATH + "/" + file_name)
		file_name = dir.get_next()
	files_list.sort()
	return files_list
		

func _on_ButtonImport_pressed():
	$DialogImport.popup_centered()


func _on_ButtonPlay_pressed():
	var level_data: Dictionary = level_str2dic(import_text_control.get_text())
	var l := Level.new()
	if l.import_level(level_data):
		$DialogImport.hide()
		Globals.set_level(l)
		run_game()
	

#func show_import_error(error_str: String) -> void:
#	import_text_control.set_text("%s\n   ---------   \n%s" % [error_str.to_upper(), \
#			import_text_control.get_text()])


func load_import_help() -> void:
	var help_text_file: String = "%s/level_help.txt" % Globals.LEVELS_PATH
	var help_examples_file: String = "%s/level_examples.txt" % Globals.LEVELS_PATH
	
	var file: File = File.new()
	var err: int = 0
	var help_text_str: String = ""
	if !file.file_exists(help_text_file):
		print_debug("File '%s' was not found" % help_text_file)
	else:
		err = file.open(help_text_file, file.READ)
		if err != OK:
			print_debug("Error while opening file: ", help_text_file)
			print_debug("Error message: ", err)
		else:
			help_text_str = file.get_as_text()
	file.close()
	
	file = File.new()
	var help_examples_str: String = ""
	if !file.file_exists(help_examples_file):
		print_debug("File '%s' was not found" % help_examples_file)
	else:
		err = file.open(help_examples_file, file.READ)
		if err != OK:
			print_debug("Error while opening file: ", help_examples_file)
			print_debug("Error message: ", err)
		else:
			help_examples_str = file.get_as_text()
	file.close()
	
	var help_help: String = """\nBEFORE PRESSING 'PLAY' DELETE EVERYTING HERE EXCEPT LEVEL JSON CODE
(it starts with '{' and ends with '}')
(if your level wasn't started check for errors in browser's console)
__________________________\n\n"""
	import_text_control.set_text(help_help + help_examples_str + help_text_str)
	

func _on_ButtonHelp_pressed():
	load_import_help()


func _unhandled_input(event):
	if event is InputEventKey and event.get_scancode() == KEY_ESCAPE \
			&& event.is_pressed():
		if $DialogImport.is_visible():
			$DialogImport.hide()
		elif is_instance_valid(Globals.game_scene):
			close_game()


func _on_ButtonRLG_pressed():
	var TEMPLATE_FILE := Globals.TEMPLATES_PATH + "/classic.json"
	var template_data: Dictionary = load_level(TEMPLATE_FILE)
	var t := Level.new()
	if t.import_template(template_data):
		Globals.set_level(t)
	else:
		print_debug("Was unable to load template '%s'" % TEMPLATE_FILE)
	run_game()


