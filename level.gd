extends GDScript
class_name Level

var TUBES: Array = []

enum WIN_CONDITIONS {GATHER_ALL, GATHER_ONE}
const WIN_CONDITIONS_HINTS := [
	"Gather all colors, each in it's own container, to win",
	"Gather %s color in any one container to win"
]
var win_condition: int = 0

var rating: Dictionary = {"stars": 0, "moves": 0, "vol": 0}
var performance_ratings: Array = [] # of rating

# func checkTUBES

