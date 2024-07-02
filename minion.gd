extends HBoxContainer

var game_state:game_state
var minion_id:int

# Called when the node enters the scene tree for the first time.
func _ready():
	$Command.get_popup().connect("index_pressed", rename)

func rename(i):
	$Name.text = str(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


