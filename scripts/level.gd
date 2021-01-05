extends GDScript
class_name Level

var _tubes: Array = [] setget set_tubes

enum WIN_CONDITIONS {GATHER_ALL, GATHER_ONE}
const WIN_CONDITIONS_HINTS := [
	"Gather all colors, each in it's own container, to win",
	"Gather %s color in any one container to win"
]
var win_condition: int = 0
# only for win_condition = 1
var win_color: int = 0

var _performance_ratings: Array = [] # of ratings

var completion_table: Array = []

var description: String = ""


# new_rating = {"stars": 0, "moves": 0, "vol": 0}
func add_rating(new_rating: Dictionary) -> bool:
	if !new_rating.has("stars") || !new_rating.has("moves") || !new_rating.has("vol"):
		print_debug("Error setting rating: missing a property")
		return false
	if typeof(new_rating.stars) != TYPE_INT || new_rating.stars < 1 || new_rating.stars > 3:
		print_debug("Error setting rating: wrong stars")
		return false
	if typeof(new_rating.moves) != TYPE_INT || new_rating.moves < 1 || new_rating.moves > Globals.MAX_MOVES:
		print_debug("Error setting rating: wrong moves")
		return false
	if typeof(new_rating.vol) != TYPE_INT || new_rating.vol < 1:
		print_debug("Error setting rating: wrong vol")
		return false
		
	if _performance_ratings.empty():
		_performance_ratings.resize(3)
		_performance_ratings[new_rating.stars - 1] = new_rating
	else:
		for each in _performance_ratings:
			if !is_instance_valid(each):
				continue
			if each.stars == new_rating.stars:
				print_debug("%s-star rating is already added" % each.stars)
				return false
		_performance_ratings[new_rating.stars - 1] = new_rating
	return true


func get_performance(moves: int = Globals.MAX_MOVES, vol: int = 0) -> int:
	var rating: int = 0
	for each in _performance_ratings:
		if moves <= each.moves && vol <= each.vol:
			rating = each.stars
	return rating


func set_tubes(input_tubes: Array) -> bool:
	if !check_input(input_tubes):
		print_debug("Level initialization failed")
		return false
	else:
		for t in input_tubes:
			var tube := Tube.new()
			tube.set_volume(t.size())
			if !tube.set_content(t):
				print_debug("Error setting tube content: ", t)
				return false
			_tubes.append(tube)
		build_completion_table()
		return true
	
	
func get_all_tubes_content() -> Array:
	var all_tubes_content: Array = []
	for each in _tubes:
		all_tubes_content.append(each.get_content())
	return all_tubes_content
	
	
func get_tube(tube_num: int) -> Tube:
	return _tubes[tube_num]
	
	
func check_input(tubes_2_check: Array) -> bool:
	for i in tubes_2_check.size():
		if typeof(tubes_2_check[i]) != TYPE_ARRAY ||tubes_2_check[i].empty():
			print_debug("Tube data is of wrong type or empty")
			return false
		if tubes_2_check[i].size() < 1 || tubes_2_check[i].size() > Globals.MAX_TUBE_VOLUME:
			print_debug("Invalid size of TUBE #", i)
			return false
		for j in tubes_2_check[i].size():
			if tubes_2_check[i][j] < 0 || tubes_2_check[i][j] > Globals.MAX_COLORS:
				print_debug("Invalid color %s in TUBE #%s" % [tubes_2_check[i][j], tubes_2_check[i]])
				return false
	return true


# number of portions for every color
func build_completion_table() -> void:
	completion_table.resize(Globals.MAX_COLORS)
	for i in completion_table.size():
		completion_table[i] = 0
	for each in _tubes:
		var tube: Array = each.get_content()
		for j in tube.size():
			if tube[j] > 0:
				completion_table[tube[j] - 1] += 1
				

# for GATHER_ALL
func check_win_condition() -> bool:
	if win_condition == 0:
		var full_color: int = 0
		for each_tube in _tubes:
			var summ: int = 0
			var num: int = 0
			for each_part in each_tube.get_content():
				if each_part != 0:
					summ += each_part
					num += 1
			# warning-ignore:integer_division
			if num == 0 || (summ / num == each_tube.get_top_color() \
					&& completion_table[each_tube.get_top_color() - 1] == num):
				full_color += 1
		if full_color == _tubes.size():
			return true
		return false
	elif win_condition == 1:
		var wrong_tube: bool = false
		for each_tube in _tubes:
			if !wrong_tube && each_tube.get_top_color() == win_color:
				var num: int = 0
				for each_part in each_tube.get_content():
					if each_part == 0:
						continue
					if each_part == win_color:
						num += 1
					if each_part != win_color:
						wrong_tube = true
						break
				if !wrong_tube && num == completion_table[win_color - 1]:
					return true
		return false
	else:
		print_debug("You shouldn't be there")
		return false

