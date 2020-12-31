extends GDScript
class_name Tube

# number of portions can contain
var _volume: int = 0 setget set_volume, get_volume
var has_drain: bool = false

var _content: Array = [] setget set_content, get_content

# to restore if pouring unsuccessful
var _previous_state: Array = []


func _init():
	randomize()


func set_volume(volume: int = 0) -> void:
	if volume < 0:
		print_debug("Invalid volume (%s), setting to random" % volume)
		volume = 0
	if volume > Globals.MAX_TUBE_VOLUME:
		print_debug("Invalid volume (%s), setting to max" % volume)
		volume = Globals.MAX_TUBE_VOLUME
	if volume == 0:
		_volume = randi() % Globals.MAX_TUBE_VOLUME + 1
	_volume = volume
	if !is_empty():
		print_debug("This tube is not empty, couldn't change it's size")
		return
	_content.resize(_volume)
	_previous_state.resize(_volume)
	
	
func get_volume() -> int:
	return _volume
	
	
func is_empty() -> bool:
	#print_debug(get_content())
	if _content.empty() || _content.back() == null || _content.back() == 0:
		return true
	return false
	
	
func set_content(new_content: Array) -> bool:
	if new_content.empty():
		print_debug("New content is empty")
		return false
	if new_content.size() != get_volume():
		print_debug("Invalid content size, it's doesn't match tube's volume")
		return false
	for each in new_content:
		if each < 0 || each > Globals.MAX_COLORS:
			print_debug("Invalid color value: ", each)
			return false
#	if !is_empty():
#		print_debug("The tube is not empty, couldn't set it's content")
#		return false
		
	_content.resize(new_content.size())
	_content = new_content.duplicate()
	return true
	
		
func get_content() -> Array:
	if _content.empty():
		_content.resize(get_volume())
		for each in _content:
			each = 0
	return _content
	
	
# portion = {color: int, size: int}
func add_a_portion(p: Portion) -> bool:
	if p.get_portion().size == 0:
		print_debug("Empty portion")
		Globals.send_message("This portion is empty")
		return true
	if p.get_portion().size < 0 || p.get_portion().size > get_volume():
		print_debug("Portion size is invalid or bigger than tube's size: ", \
				p.get_portion().size)
		return false
	if p.get_portion().size > get_empty_volume():
		print_debug("There is not enough empty volume to add such size")
		return false
	if get_top_color() != 0 && get_top_color() != p.get_portion().color:
		print_debug("Source portion color doesn't match target's top color")
		Globals.send_message("Portion color doesn't match tube's top color")
		return false
		
	var empty_space: int = 0
	for i in get_volume():
		if _content[i] == 0:
			empty_space += 1
		else:
			break
	#var before: Array = get_content()
	var start_fill_index: int = empty_space - p.get_portion().size
	for i in range(start_fill_index, start_fill_index + p.get_portion().size):
		_content[i] = p.get_portion().color
	return true


func drain_a_portion() -> Portion: # {color: int, size: int}
	var p := Portion.new()
	if is_empty():
		return p
	var p_color: int = get_top_color()
	var p_size: int = 0
	var before: Array = get_content()
	_previous_state = before.duplicate()
	for each in before:
		if each == 0:
			continue
		if each == p_color:
			p_size += 1
		else:
			break
	if p.set_portion({"color": p_color, "size": p_size}):
		for i in before.size():
			if before[i] == 0:
				continue
			if before[i] == p_color:
				before[i] = 0
			else:
				break
		if !set_content(before):
			print_debug("Error while draining")
		return p
	else:
		print_debug("Error making a portion")
		return null
	

func get_empty_volume() -> int:
	if is_empty():
		return get_volume()
	var empty_space: int = 0
	for each in get_content():
		if each == 0:
			empty_space += 1
		else:
			return empty_space
	# shouldn't be there
	return -1


func get_top_color() -> int:
	if is_empty():
		return 0
	for each in get_content():
		if each == 0:
			continue
		return each
	return 0


func restore_portion() -> void:
	if !set_content(_previous_state):
		print_debug("Error restoring portion")


