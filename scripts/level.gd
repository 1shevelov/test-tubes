extends GDScript
class_name Level

var _tubes: Array = [] setget set_tubes
#var _tubes_with_drain: Array = [] setget set_drains
var _tubes_reset_copy: Array = []
var _drains_reset_copy: Array = []

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


func set_drains(drains: Array) -> bool:
	if _tubes.empty():
		print_debug("Tubes array wasn't set, can't set drains")
		return false
	if drains.size() != _tubes.size():
		print_debug("Drains array doesn't equal to tubes array")
		return false
	for i in drains.size():
		if !(typeof(drains[i]) == TYPE_REAL || typeof(drains[i]) == TYPE_INT):
			print_debug("Invalid type of drain array member: ", typeof(drains[i]))
			return false
		if drains[i] in Tube.DRAINS.values():
			get_tube(i).drains = drains[i]
		else:
			print_debug("Drains array member' value is invalid: ", drains[i])
			return false
	return true


# new_rating = {"stars": 0, "moves": 0, "vol": 0}
func add_rating(new_rating: Dictionary) -> bool:
#	if !new_rating.has("stars") || !new_rating.has("moves") || !new_rating.has("vol"):
#		print_debug("Error setting rating: missing a property")
#		return false
#	if typeof(new_rating.stars) != TYPE_INT || new_rating.stars < 1 || new_rating.stars > 3:
#		print_debug("Error setting rating: wrong stars")
#		return false
#	if typeof(new_rating.moves) != TYPE_INT || new_rating.moves < 1 || new_rating.moves > Globals.MAX_MOVES:
#		print_debug("Error setting rating: wrong moves")
#		return false
#	if typeof(new_rating.vol) != TYPE_INT || new_rating.vol < 1:
#		print_debug("Error setting rating: wrong vol")
#		return false
		
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
	if _performance_ratings.empty():
		return -1
	else:
		for each in _performance_ratings:
			if moves <= each.moves && vol <= each.vol:
				rating = each.stars
	return rating


func set_tubes(input_tubes: Array) -> bool:
	if !check_input_tubes(input_tubes):
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
		var drain_tubes: Array = []
		drain_tubes.resize(input_tubes.size())
		for i in drain_tubes.size():
			drain_tubes[i] = false
		return true
	
	
func get_all_tubes_content() -> Array:
	var all_tubes_content: Array = []
	for each in _tubes:
		all_tubes_content.append(each.get_content())
	return all_tubes_content
	
	
func get_tubes_number() -> int:
	return _tubes.size()


func get_tube(tube_num: int) -> Tube:
	return _tubes[tube_num]
	
	
func check_input_tubes(tubes_2_check: Array) -> bool:
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


# input argument is a Dictionary
func import_level(data) -> bool:
	var MAX_DESC_SIZE: int = 160
	
	if typeof(data) != TYPE_DICTIONARY || data.empty():
		print_debug("Wrong data type or empty")
		return false

	if !data.has("tubes") || typeof(data.tubes) != TYPE_ARRAY || data.tubes.empty():
		print_debug("No 'tubes' property or invalid type")
		return false
	if data.tubes.size() > Globals.MAX_TUBES:
		print_debug("More then %s tubes is not allowed in level, found %s tubes" \
				% [Globals.MAX_TUBES, data.tubes.size()])
		return false
	for i in data.tubes.size():
		if typeof(data.tubes[i]) != TYPE_ARRAY || data.tubes[i].empty():
			print_debug("Tube data is of wrong type or empty")
			return false
		if data.tubes.size() < 1 || data.tubes[i].size() > Globals.MAX_TUBE_VOLUME:
			print_debug("Tube #%s has invalid size of %s" % [i, data.tubes[i].size()])
			return false
		for each in data.tubes[i]:
			if typeof(each) != TYPE_REAL:
				print_debug("Tube #%s has value of invalid type: %s" \
						% [i, typeof(each)])
				return false
			if int(each) < 0 || int(each) > Globals.MAX_COLORS:
				print_debug("Tube #%s has invalid color value %s" % [i, each])
				return false
	
	if data.has("drains"):
		if typeof(data.drains) != TYPE_ARRAY:
			print_debug("'drains' property is of invalid type")
			return false
		if data.drains.size() != data.tubes.size():
			print_debug("'drains' property is of invalid type")
			return false
		for each in data.drains:
			if typeof(each) != TYPE_REAL:
				print_debug("'drains' has value of invalid type: ", typeof(each))
				return false
			if int(each) < 0 || int(each) > 2:
				print_debug("'drains' has invalid value of ", each)
				return false
	
	if data.has("desc"):
		if typeof(data.desc) != TYPE_STRING:
			print_debug("'desc' property is of invalid type")
			return false
		if data.desc.length() > MAX_DESC_SIZE:
			print_debug("'desc' will be truncated to %s symbols" % MAX_DESC_SIZE)
			data.desc = data.desc.substr(0, MAX_DESC_SIZE)

	if data.has("win_color"):
		if typeof(data.win_color) != TYPE_REAL:
			print_debug("'win_color' property is of invalid type")
			return false
		if data.win_color < 0 || data.win_color > Globals.MAX_COLORS:
			print_debug("'win_color' value is invalid")
			return false
		var win_color_present: bool = false
		for i in data.tubes.size():
			for each in data.tubes[i]:
				if each == data.win_color:
					win_color_present = true
		if !win_color_present:
			print_debug("'win_color' value was not found in tubes")
			return false
	
	if data.has("ratings"):
		if typeof(data.ratings) != TYPE_ARRAY:
			print_debug("'ratings' property is of invalid type")
			return false
		if data.ratings.size() > 3:
			print_debug("'ratings' property can have no more than 3 records")
			return false
		if !data.ratings.empty():
			for each in data.ratings:
				if typeof(each) != TYPE_DICTIONARY:
					print_debug("A record has an invalid type")
					return false
				if !each.has("stars") || !each.has("moves"):
					print_debug("A record should have 'stars' and 'moves' properties")
					return false
				if typeof(each.stars) != TYPE_REAL || typeof(each.moves) != TYPE_REAL:
					print_debug("A record's 'stars' or 'moves' property has invalid type")
					return false
				if int(each.stars) < 1 || int(each.stars) > 3:
					print_debug("A record's 'stars' property is invalid: ", each.stars)
					return false
				if int(each.moves) < 1:
					print_debug("A record's 'moves' property is invalid: ", each.moves)
					return false
				if int(each.moves) > Globals.MAX_MOVES:
					print_debug("A record's 'moves' property is invalid: %s, setting to max" % each.moves)
					each.moves = Globals.MAX_MOVES
				if each.has("vol"):
					if typeof(each.vol) != TYPE_REAL:
						print_debug("A record's 'vol' property has invalid type - setting to 0")
						each.vol = 0
					if int(each.vol) < 0:
						print_debug("A record's 'vol' property is too small: %s, setting to 0" % each.vol)
						each.vol = 0
					if int(each.vol) > Globals.MAX_TUBE_VOLUME * Globals.MAX_MOVES:
						print_debug("A record's 'vol' property is too big: %s, setting to max" % each.vol)
						each.vol = Globals.MAX_TUBE_VOLUME * Globals.MAX_MOVES
						
	if !set_tubes(data.tubes):
		print_debug("Error while setting tubes, import aborted")
		return false
	if data.has("drains") && !set_drains(data.drains):
		print_debug("Error while setting drains, import aborted")
		return false
	if data.has("desc"):
		description = data.desc
	if data.has("win_color"):
		if data.win_color != 0:
			win_condition = WIN_CONDITIONS.GATHER_ONE
		win_color = data.win_color
	if data.has("ratings"):
		for each in data.ratings:
			if !add_rating(each):
				print_debug("Error while adding rating")
	make_reset_copy()
	return true


#func import_template(data) -> bool:
#	var MAX_DESC_SIZE: int = 160
#	var MIN_COLORS: int = 3
#	var MIN_PORTIONS: int = 1
#	var MAX_PORTIONS: int = Globals.MAX_TUBE_VOLUME
#
#	if typeof(data) != TYPE_DICTIONARY || data.empty():
#		print_debug("Wrong data type or empty")
#		return false
#
#	if !data.has("tubes") || typeof(data.tubes) != TYPE_ARRAY || data.tubes.empty():
#		print_debug("No 'tubes' property or invalid type")
#		return false
#	if data.tubes.size() > Globals.MAX_TUBES:
#		print_debug("More then %s tubes is not allowed in level, found %s tubes" \
#				% [Globals.MAX_TUBES, data.tubes.size()])
#		return false
#	for i in data.tubes.size():
#		if typeof(data.tubes[i]) != TYPE_ARRAY || data.tubes[i].empty():
#			print_debug("Tube data is of wrong type or empty")
#			return false
#		if data.tubes.size() < 1 || data.tubes[i].size() > Globals.MAX_TUBE_VOLUME:
#			print_debug("Tube #%s has invalid size of %s" % [i, data.tubes[i].size()])
#			return false
#		for each in data.tubes[i]:
#			if typeof(each) != TYPE_REAL:
#				print_debug("Tube #%s has value of invalid type: %s" \
#						% [i, typeof(each)])
#				return false
#			if int(each) < 0 || int(each) > Globals.MAX_COLORS:
#				print_debug("Tube #%s has invalid color value %s" % [i, each])
#				return false
#
#	if data.has("drains"):
#		if typeof(data.drains) != TYPE_ARRAY:
#			print_debug("'drains' property is of invalid type")
#			return false
#		if data.drains.size() != data.tubes.size():
#			print_debug("'drains' property is of invalid type")
#			return false
#		for each in data.drains:
#			if typeof(each) != TYPE_REAL:
#				print_debug("'drains' has value of invalid type: ", typeof(each))
#				return false
#			if int(each) < 0 || int(each) > 2:
#				print_debug("'drains' has invalid value of ", each)
#				return false
#
#	if !data.has("colors") || typeof(data.colors) != TYPE_REAL:
#		print_debug("Invalid 'colors' template property, setting to MIN")
#		data.colors = MIN_COLORS
#	elif int(data.colors) < MIN_COLORS:
#		print_debug("'colors' template value is less than MIN, setting to MIN")
#		data.colors = MIN_COLORS
#	elif int(data.colors) > Globals.MAX_COLORS:
#		print_debug("'colors' template value exceeds MAX, setting to MAX")
#		data.colors = Globals.MAX_COLORS
#
#	if !data.has("portions") || typeof(data.portions) != TYPE_REAL:
#		print_debug("Invalid 'portions' template property, setting to MIN")
#		data.portions = MIN_PORTIONS
#	elif int(data.portions) < MIN_PORTIONS:
#		print_debug("'portions' template value is less than MIN, setting to MIN")
#		data.portions = MIN_PORTIONS
#	elif int(data.portions) > MAX_PORTIONS:
#		print_debug("'portions' template value exceeds MAX, setting to MAX")
#		data.portions = MAX_PORTIONS
#
#	if data.has("desc"):
#		if typeof(data.desc) != TYPE_STRING:
#			print_debug("'desc' property is of invalid type")
#			return false
#		if data.desc.length() > MAX_DESC_SIZE:
#			print_debug("'desc' will be truncated to %s symbols" % MAX_DESC_SIZE)
#			data.desc = data.desc.substr(0, MAX_DESC_SIZE)
#
##	print_debug("Template data: ", data)
#	if !init_template(data):
#		return false
#	return true


# fill template with random colors
# and init level like in the last part of import_level
#func init_template(data: Dictionary) -> bool:
#	# fill the data.tubes with colors
#	var colors: Array = []
#	for i in Globals.MAX_COLORS:
#		if i == 0:
#			continue
#		colors.append(i)
#	randomize()
#	colors.shuffle()
#	colors.resize(data.colors)
#	var portions: Array = []
#	portions.resize(data.colors)
#	portions.fill(data.portions)
##	print(colors, portions)
#
#	var iter := colors.size() * portions.size()
#	var tube_por: int
#	var tube_num: int
#	var random_color_index: int
#	for i in iter:
#		tube_por = i % 5
#		tube_num = int((i - tube_por) / 5)
##		print("%s / %s" % [tube_num, tube_por])
#		random_color_index = randi() % colors.size()
#		portions[random_color_index] -= 1
#		data.tubes[tube_num][tube_por] = colors[random_color_index]
#		if portions[random_color_index] == 0:
#			colors.remove(random_color_index)
#			portions.remove(random_color_index)
#
#	if !set_tubes(data.tubes):
#		print_debug("Error while setting template tubes, import aborted")
#		return false
#	if data.has("drains") && !set_drains(data.drains):
#		print_debug("Error while setting drains, import aborted")
#		return false
#	if data.has("desc"):
#		description = data.desc
#	make_reset_copy()
#	return true


# generate classic water pour puzzle level:
# all tubes are of the same volume
# each color has the same volume randomly portioned and poured in all tubes
# except two which are empty
# so the number of colors is equal to number of tubes minus two
func make_random_classic_level(colors: int, volume: int) -> bool:
	var MIN_COLORS := 3
	var MIN_VOLUME := 2
	if colors < MIN_COLORS:
		print_debug("Wrong 'colors' number, setting to MIN")
		colors = MIN_COLORS
	if colors > Globals.MAX_COLORS || colors > Globals.MAX_TUBES - 2:
		print_debug("Wrong 'colors' number, setting to MAX")
		colors = Globals.MAX_COLORS
	if volume < MIN_VOLUME:
		print_debug("Wrong 'volume', setting to MIN")
		colors = MIN_VOLUME
	if volume > Globals.MAX_TUBE_VOLUME:
		print_debug("Wrong 'volume', setting to MAX")
		colors = Globals.MAX_TUBE_VOLUME

	# make empty tubes
	var tube: Array
	var tubes: Array = []
	for i in colors + 2:
		tube = []
		tube.resize(volume)
		tube.fill(0)
		tubes.append(tube)

	# make random palette
	var palette: Array = []
	for i in Globals.MAX_COLORS + 1:
		if i == 0:
			continue
		palette.append(i)
	randomize()
	palette.shuffle()
	palette.resize(colors)
	var portions: Array = []
	portions.resize(colors)
	portions.fill(volume)
#	print(palette, portions)

	# fill tubes with colors from palette
	var iterations := colors * volume
	var tube_por: int
	var tube_num: int
	var random_color_index: int
	for i in iterations:
		tube_por = i % volume
		tube_num = int((i - tube_por) / volume)
#		print("%s / %s" % [tube_num, tube_por])
		random_color_index = randi() % palette.size()
		portions[random_color_index] -= 1
		tubes[tube_num][tube_por] = palette[random_color_index]
		if portions[random_color_index] == 0:
			palette.remove(random_color_index)
			portions.remove(random_color_index)
#	print_debug(tubes)
	
	# init level
	if !set_tubes(tubes):
		print_debug("Error while setting random tubes, classic level generation aborted")
		return false
#	if data.has("drains") && !set_drains(data.drains):
#		print_debug("Error while setting drains, import aborted")
#		return false
	make_reset_copy()
	return true


# generate classic water pour puzzle level
# where every tube has only faucets
func make_random_classic_faucet_level(colors: int, volume: int) -> bool:
	if make_random_classic_level(colors, volume):
		var drains: Array = []
		drains.resize(get_tubes_number())
		drains.fill(2)
		# set two tubes to '1', but not last two empty tubes
		var t1 = randi() % (drains.size() - 3)
		drains[t1] = 1
		var t2 = randi() % (drains.size() - 3)
		if t2 == t1:
			if t2 % 2 == 0 && t2 > 0:
				t2 -= 1
			else:
				t2 += 1
		drains[t2] = 1
			
		if set_drains(drains):
			return true
		else:
			print_debug("Error while setting drains for random classic faucet level")
			return false
	else:
		return false


func make_reset_copy() -> void:
	if _tubes.empty():
		print_debug("The tubes array is empty!")
	elif !_tubes_reset_copy.empty():
		print_debug("The reset copy was already made!")
	else:
		for i in _tubes.size():
			_tubes_reset_copy.append(get_tube(i).get_content().duplicate())
	if !_drains_reset_copy.empty():
		print_debug("Drains reset copy was already made!")
	else:
		for i in _tubes.size():
			_drains_reset_copy.append(get_tube(i).drains)


func reset_level() -> void:
	if _tubes_reset_copy.empty():
		print_debug("Reset copy is empty!")
	elif _drains_reset_copy.empty():
		print_debug("Drains reset copy is empty!")
	else:
		_tubes.clear()
#		for t in _tubes_reset_copy:
#			var tube := Tube.new()
#			tube.set_volume(t.size())
#			if !tube.set_content(t):
#				print_debug("Error restoring tube content: ", t)
#			else:
#				_tubes.append(tube)
		if !set_tubes(_tubes_reset_copy):
			print_debug("Wrong tube data in reset copy")
		if !set_drains(_drains_reset_copy):
			print_debug("Wrong drains data in reset copy")

