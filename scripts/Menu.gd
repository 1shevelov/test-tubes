extends Control

const GAME_SCENE := preload("res://scenes/GameScene.tscn")
var game_scene: Node2D

var curr_level: Level


func _ready():
	# warning-ignore:return_value_discarded
	#get_tree().change_scene_to(game_scene)
	pass


func close_game() -> void:
	# warning-ignore:return_value_discarded
	game_scene.queue_free()
	set_visible(true)


func _on_Button_pressed():
	game_scene = GAME_SCENE.instance()
	self.set_visible(false)
	game_scene.init(self)
	$"/root".add_child(game_scene)
	#game_scene.set_visible(true)


func set_level1() -> Level:
	var l := Level.new()
	l.TUBES = [
		[0, 1, 2, 5],
		[0, 5, 2, 1],
		[0, 0, 0],
		[5, 2, 5, 1]
	]
	
	return l
