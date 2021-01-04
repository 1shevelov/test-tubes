extends Control

const GAME_SCENE := preload("res://scenes/GameScene.tscn")
var game_scene: Node2D


func _ready():
	# warning-ignore:return_value_discarded
	#get_tree().change_scene_to(game_scene)
	pass


func close_game() -> void:
	if is_instance_valid(game_scene):
		game_scene.queue_free()
	set_visible(true)


func _on_Button_pressed():
	set_level2()
	if is_instance_valid(Globals.get_level()):
		self.set_visible(false)
		game_scene = GAME_SCENE.instance()
		game_scene.init(self)
		$"/root".add_child(game_scene)
	else:
		print_debug("Game initialization failed")
	#game_scene.set_visible(true)


func set_level1() -> void:
	var l := Level.new()
	if l.set_tubes([
		[0, 1, 2, 5],
		[0, 5, 2, 1],
		[0, 0, 0],
		[5, 2, 5, 1]
	]):
		if !l.add_rating({"stars": 3, "moves": 8, "vol": 11}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 2, "moves": 9, "vol": 13}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 1, "moves": 9, "vol": 15}):
			print_debug("Invalid rating")
		Globals.set_level(l)
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
		if !l.add_rating({"stars": 3, "moves": 1, "vol": 1}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 2, "moves": 15, "vol": 21}):
			print_debug("Invalid rating")
		if !l.add_rating({"stars": 1, "moves": 1, "vol": 1}):
			print_debug("Invalid rating")
		Globals.set_level(l)
	else:
		print_debug("Error while activating level 2")
		

