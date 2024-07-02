class_name Action_bar extends HBoxContainer

var game_state:game_state
@onready var _button:Button = $Button
@onready var _cost_label:Label = $"Cost Label"

var _action:Action
var action:Action:
	get:
		return _action
	set(value):
		_action = value
		_button.text = value.name
		_button.tooltip_text = value.description
		refresh_cost()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _action != null:
		refresh_cost()

func refresh_cost():
	var text:String = ""
	for item in _action.cost:
		text += item + ": " + str(game_state.resources.get(item,0)) + "/" + str(_action.cost[item]) + "  "
	_cost_label.text = text
		
func set_action(value:Action):
	action = value
