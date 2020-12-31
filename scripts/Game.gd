extends Node
class_name Game

var TUBES := [
	[0, 1, 2, 5],
	[0, 5, 2, 1],
	[0, 0, 0],
	[5, 2, 5, 1]
]
#const COLORS := 2
var tubes: Array = []
var completion_table: Array = []

var _operations_counter: int = 0 setget , get_pours
var _volume_counter: int = 0 setget , get_pours_volume


func add_a_pour() -> void:
	_operations_counter += 1


func get_pours() -> int:
	return _operations_counter
	
	
func add_a_pour_volume(addition: int) -> void:
	if addition < 0 || addition > Globals.MAX_TUBE_VOLUME:
		print_debug("Invalid argument for adding pour volume")
		return
	_volume_counter += addition
	

func get_pours_volume() -> int:
	return _volume_counter


func init() -> bool:
	if check_TUBES():
		for t in TUBES:
			var tube := Tube.new()
			tube.set_volume(t.size())#Globals.MAX_TUBE_VOLUME)
#			while t.size() < Globals.MAX_TUBE_VOLUME:
#				t.push_front(0)
			if !tube.set_content(t):
				print_debug("Error setting tube content: ", t)
				return false
			tubes.append(tube)
		find_completion_condition()
		return true
	else:
		return false


func check_TUBES() -> bool:
	for i in TUBES.size():
		if typeof(TUBES[i]) != TYPE_ARRAY ||TUBES[i].empty():
			print_debug("Tube data is of wrong type or empty")
			return false
		if TUBES[i].size() < 1 || TUBES[i].size() > Globals.MAX_TUBE_VOLUME:
			print_debug("Invalid size of TUBE #", i)
			return false
		for j in TUBES[i].size():
			if TUBES[i][j] < 0 || TUBES[i][j] > Globals.MAX_COLORS:
				print_debug("Invalid color %s in TUBE #%s" % [TUBES[i][j], TUBES[i]])
				return false
	return true
	
	
func get_tubes_number() -> int:
	return TUBES.size()
	
	
func pour(source: int, target: int) -> bool:
	print_debug(" -- %s -> %s --" % [source, target])
	print_debug("Source: ", tubes[source].get_content())
	print_debug("Target before: ", tubes[target].get_content())
	var pouring: Portion = tubes[source].drain_a_portion()
	if tubes[target].add_a_portion(pouring):
		print_debug("Source after: ", tubes[source].get_content())
		print_debug("Target after: ", tubes[target].get_content())
		add_a_pour()
		add_a_pour_volume(pouring.get_portion().size)
		return true
	else:
		tubes[source].restore_portion()
		#tubes[source].add_a_portion(pouring)
	print_debug("Source after: ", tubes[source].get_content())
	print_debug("Target after: ", tubes[target].get_content())
	return false
		

func check_if_complete() -> bool:
	var full_color: int = 0
	for t in tubes:
		var summ: int = 0
		var num: int = 0
		for each in t.get_content():
			if each != 0:
				summ += each
				num += 1
		# warning-ignore:integer_division
		if num == 0 || (summ / num == t.get_top_color() \
				&& completion_table[t.get_top_color() - 1] == num):
			full_color += 1
	if full_color == tubes.size():
		return true
	return false
	
	
func find_completion_condition() -> void:
	completion_table.resize(Globals.MAX_COLORS)
	for i in completion_table.size():
		completion_table[i] = 0
	for i in TUBES.size():
		for j in TUBES[i].size():
			if TUBES[i][j] > 0:
				completion_table[TUBES[i][j] - 1] += 1
				
