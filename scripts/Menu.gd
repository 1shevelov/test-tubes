extends Control

const GAME_SCENE := preload("res://scenes/GameScene.tscn")
var game_scene: Node2D

const LEVEL_LABEL := preload("res://scenes/LevelLabel.tscn")
var levels: Array = []
onready var levels_list: VBoxContainer = $CenterContainer/MainVBox/LevelSelection


func _ready():
	make_levels_list()


func close_game() -> void:
	if is_instance_valid(game_scene):
		game_scene.queue_free()
	set_visible(true)
	init_levels()
	
	
# doesn't work
func restart_game() -> void:
	close_game()
	run_game()
	

func init_levels() -> void:
	if !levels.empty():
		levels.clear()
#	set_level1()
#	set_level2()
#	set_level3()
#	set_level4()
#	set_level5()


func make_levels_list() -> void:
	#init_levels()
	load_levels()
	for i in levels.size():
		var l := LEVEL_LABEL.instance()
		l.label_text = levels[i].description
		l.menu = self
		l.set_name("LevelLabel_%s" % [i + 1])
		levels_list.add_child(l)
		

func _on_Button_pressed():
	pass

	
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
	Globals.set_level(levels[label_num - 1])
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
#		levels.append(l)
#	else:
#		print_debug("Error while activating level 1")


#func set_level1() -> void:
#	var l := Level.new()
#	if l.set_tubes([
#		[5],
#		[4, 3],
#		[0, 5],
#		[3, 2, 4],
#		[5, 3, 2, 4],
#		[0, 4, 5, 1, 5],
#		[0, 0, 0, 0]
#	]):
#		l.description = "[center][color=lime]EASY[/color] Varying tubes and liquids' volumes\n7 tubes, 5 colors - 15 moves[/center]"
#		if !l.add_rating({"stars": 3, "moves": 15, "vol": 19}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 2, "moves": 15, "vol": 20}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 1, "moves": 15, "vol": 21}):
#			print_debug("Invalid rating")
#		levels.append(l)
#		#Globals.set_level(l)
#	else:
#		print_debug("Error while activating level 1")
#
#
#func set_level2() -> void:
#	var l := Level.new()
#	if l.set_tubes([
#		[5],
#		[4, 3],
#		[0, 5],
#		[3, 2, 4],
#		[5, 3, 2, 4],
#		[0, 4, 5, 1, 5],
#		[0, 0, 0, 0]
#	]):
#		l.description = "[center][color=lime]EASY[/color] Same as #1 but gather only [color=lime]GREEN[/color]\n7 moves[/center]"
#		l.win_condition = l.WIN_CONDITIONS.GATHER_ONE
#		l.win_color = 5
#		if !l.add_rating({"stars": 3, "moves": 7, "vol": 9}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 2, "moves": 8, "vol": 11}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 1, "moves": 8, "vol": 12}):
#			print_debug("Invalid rating")
#		levels.append(l)
#		#Globals.set_level(l)
#	else:
#		print_debug("Error while activating level 2")
#
#
#func set_level3() -> void:
#	var l := Level.new()
#	if l.set_tubes([
#		[1, 2, 3, 4],
#		[5, 6, 7, 8],
#		[8, 6, 6, 1],
#		[5, 3, 2, 7],
#		[2, 5, 8, 1],
#		[9, 3, 5, 2],
#		[4, 9, 9, 8],
#		[6, 7, 1, 7],
#		[3, 9, 4, 4],
#		[0, 0, 0, 0],
#		[0, 0, 0, 0]
#	]):
#		l.description = "[center][color=red]HARD[/color] Water Sort Puzzle classic\n11 tubes, 9 colors - 36 moves[/center]"
#		if !l.add_rating({"stars": 3, "moves": 15, "vol": 19}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 2, "moves": 15, "vol": 20}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 1, "moves": 16, "vol": 22}):
#			print_debug("Invalid rating")
#		levels.append(l)
#		#Globals.set_level(l)
#	else:
#		print_debug("Error while activating level 3")
#
#
#func set_level4() -> void:
#	var l := Level.new()
#	if l.set_tubes([
#		[0, 5, 8, 8],
#		[3, 6, 5, 3],
#		[3, 8, 2, 2],
#		[6, 4, 7, 7],
#		[8, 7, 2, 6],
#		[7, 2, 4, 4],
#		[4, 3, 5, 5],
#		[0, 0, 0, 6]
#	]):
#		l.description = "[center][color=yellow]MEDIUM[/color] Hoops: one way to solve\n8 tubes, 7 colors - 16 moves[/center]"
#		if !l.add_rating({"stars": 3, "moves": 16, "vol": 20}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 2, "moves": 16, "vol": 21}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 1, "moves": 17, "vol": 22}):
#			print_debug("Invalid rating")
#		levels.append(l)
#		#Globals.set_level(l)
#	else:
#		print_debug("Error while activating level 4")
#
#
#func set_level5() -> void:
#	var l := Level.new()
#	if l.set_tubes([
#		[0, 0, 1, 2, 5],
#		[0, 0, 5, 2, 1],
#		[0, 5, 1, 5, 2]
#	]):
#		if !l.set_drains([Tube.DRAINS.BOTH, Tube.DRAINS.BOTH, Tube.DRAINS.BOTH]):
#			print_debug("Invalid drains array")
#		l.description = "[center][color=lime]EASY[/color] All tubes has bottom faucets\n3 tubes, 3 colors - 7 moves[/center]"
#		if !l.add_rating({"stars": 3, "moves": 7, "vol": 7}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 2, "moves": 7, "vol": 8}):
#			print_debug("Invalid rating")
#		if !l.add_rating({"stars": 1, "moves": 8, "vol": 9}):
#			print_debug("Invalid rating")
#		levels.append(l)
#	else:
#		print_debug("Error while activating level 5")


func load_levels() -> void:
	if !levels.empty():
		levels.clear()
	var files_list: Array = get_levels_list()
	if files_list.empty():
		print_debug("No level files found")
		return
	for each_file in files_list:
		var level_data: Dictionary = load_level(each_file)
		var l := Level.new()
		if l.import_level(level_data):
			levels.append(l)
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


func get_levels_list() -> Array:
	var LEVEL_EXT: String = "json"
	
	var err: int
	var dir: Directory = Directory.new()
	if !dir.dir_exists(Globals.LEVELS_PATH):
		print_debug("Levels directory not found!?")
		return []
	err = dir.open(Globals.LEVELS_PATH)
	if err != OK:
		print_debug("Error accessing levels directory: ", err)
		return []
	err = dir.list_dir_begin(true, false)
	if err != OK:
		print_debug("Error while reading dir content: ", err)
		return []
	var file_name: String = dir.get_next()
	var files_list: Array = []
	while file_name != "":
		if  file_name.get_extension() == LEVEL_EXT:
			files_list.append(Globals.LEVELS_PATH + "/" + file_name)
		file_name = dir.get_next()
	files_list.sort()
	return files_list
		
