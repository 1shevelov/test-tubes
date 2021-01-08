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
	set_level1()
	set_level2()
	set_level3()
	set_level4()
	set_level5()


func make_levels_list() -> void:
	init_levels()
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


func set_level1() -> void:
	var l := Level.new()
	if l.set_tubes([
		[5],
		[4, 3],
		[0, 5],
		[3, 2, 4],
		[5, 3, 2, 4],
		[0, 4, 5, 1, 5],
		[0, 0, 0, 0]
	]):
		l.description = "[center][color=lime]EASY[/color] Varying tubes and liquids' volumes\n7 tubes, 5 colors - 15 moves[/center]"
		if !l.add_rating({"stars": 3, "moves": 15, "vol": 19}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 2, "moves": 15, "vol": 20}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 1, "moves": 15, "vol": 21}):
			print_debug("Invalid rating")
		levels.append(l)
		#Globals.set_level(l)
	else:
		print_debug("Error while activating level 1")
		

func set_level2() -> void:
	var l := Level.new()
	if l.set_tubes([
		[5],
		[4, 3],
		[0, 5],
		[3, 2, 4],
		[5, 3, 2, 4],
		[0, 4, 5, 1, 5],
		[0, 0, 0, 0]
	]):
		l.description = "[center][color=lime]EASY[/color] Same as #1 but gather only [color=lime]GREEN[/color]\n7 moves[/center]"
		l.win_condition = l.WIN_CONDITIONS.GATHER_ONE
		l.win_color = 5
		if !l.add_rating({"stars": 3, "moves": 7, "vol": 9}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 2, "moves": 8, "vol": 11}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 1, "moves": 8, "vol": 12}):
			print_debug("Invalid rating")
		levels.append(l)
		#Globals.set_level(l)
	else:
		print_debug("Error while activating level 2")


func set_level3() -> void:
	var l := Level.new()
	if l.set_tubes([
		[1, 2, 3, 4],
		[5, 6, 7, 8],
		[8, 6, 6, 1],
		[5, 3, 2, 7],
		[2, 5, 8, 1],
		[9, 3, 5, 2],
		[4, 9, 9, 8],
		[6, 7, 1, 7],
		[3, 9, 4, 4],
		[0, 0, 0, 0],
		[0, 0, 0, 0]
	]):
		l.description = "[center][color=red]HARD[/color] Water Sort Puzzle classic\n11 tubes, 9 colors - 36 moves[/center]"
		if !l.add_rating({"stars": 3, "moves": 15, "vol": 19}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 2, "moves": 15, "vol": 20}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 1, "moves": 36, "vol": 50}):
			print_debug("Invalid rating")
		levels.append(l)
		#Globals.set_level(l)
	else:
		print_debug("Error while activating level 3")


func set_level4() -> void:
	var l := Level.new()
	if l.set_tubes([
		[0, 5, 8, 8],
		[3, 6, 5, 3],
		[3, 8, 2, 2],
		[6, 4, 7, 7],
		[8, 7, 2, 6],
		[7, 2, 4, 4],
		[4, 3, 5, 5],
		[0, 0, 0, 6]
	]):
		l.description = "[center][color=yellow]MEDIUM[/color] Hoops: one way to solve\n8 tubes, 7 colors - 16 moves[/center]"
		if !l.add_rating({"stars": 3, "moves": 16, "vol": 20}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 2, "moves": 16, "vol": 21}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 1, "moves": 17, "vol": 22}):
			print_debug("Invalid rating")
		levels.append(l)
		#Globals.set_level(l)
	else:
		print_debug("Error while activating level 4")


func set_level5() -> void:
	var l := Level.new()
	if l.set_tubes([
		[0, 0, 1, 2, 5],
		[0, 0, 5, 2, 1],
		[0, 5, 1, 5, 2]
	]):
		if !l.set_drains([false, false, true]):
			print_debug("Invalid drains array")
		l.description = "[center][color=lime]EASY[/color] One tube has a bottom faucet\n3 tubes, 3 colors - 8 moves[/center]"
		if !l.add_rating({"stars": 3, "moves": 8, "vol": 11}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 2, "moves": 9, "vol": 13}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 1, "moves": 9, "vol": 15}):
			print_debug("Invalid rating")
		levels.append(l)
	else:
		print_debug("Error while activating level 5")
