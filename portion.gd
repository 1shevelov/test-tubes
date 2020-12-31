extends GDScript
class_name Portion
	
var _color: int = 0
var _size: int = 0


func set_portion(new_portion: Dictionary) -> bool:
	if !new_portion.has("color") || !new_portion.has("size"):
		print_debug("Input argument doesn't have 'color' or 'size' property")
		return false
	if new_portion.color < 0 || new_portion.color > Globals.MAX_COLORS:
		print_debug("Invalid color value: ", new_portion.color)
		return false
	if new_portion.size < 0 || new_portion.size > Globals.MAX_TUBE_VOLUME:
		print_debug("Invalid size value: ", new_portion.size)
		return false
	
	_color = new_portion.color
	_size = new_portion.size
	return true


func get_portion() -> Dictionary:
	return {"color": _color, "size": _size}
	
	
func is_empty() -> bool:
	if _color == 0 || _size == 0:
		return true
	return false




