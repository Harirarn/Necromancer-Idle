extends VBoxContainer

@onready var game_state:game_state = %GameState
@onready var idle:Action = load("res://actions/empty.tres")
var current_label:Label
var queued:Array[Action] = []
@onready var queue_labels_container = $"Queue Labels"
var queue_labels:Array[Label] = []
const max_queue:int = 3
var reserved:Dictionary

var progress_bar:ProgressBar
var progress:float = 0.0:
	get:
		return progress_bar.value
	set(value):
		progress_bar.value = value
var total_time:float:
	get:
		return progress_bar.max_value
	set(value):
		progress_bar.max_value = value

var _current:Action
var current:Action:
	get:
		return _current
	set(value):
		_current = value
		total_time = value.time/game_state.skill_level(value.skill)
		current_label.text = value.working_description
		if game_state.check_costs(value.cost, true):
			reserved = value.cost.duplicate()
		else:
			cancel()

func _ready():
	current_label = find_child("current_label")
	progress_bar = find_child("ProgressBar")
	current = idle
	for i in range(max_queue):
		queue_labels.append(queue_labels_container.get_child(i))
	queued.resize(max_queue)
	clear_queue()


func _process(delta):
	progress += delta * game_state.game_speed
	while progress > total_time and current != idle:
		game_state.perform(current)
		reserved.clear()
		progress -= total_time
		next_task()
	if progress > total_time:
		progress = total_time

func cancel():
	progress = 0.0
	game_state.refund(reserved)
	reserved.clear()
	next_task()

func next_task():
	current = clear_queue(0)

func clear_queue(at = -1):
	if at == -1:
		for i in range(max_queue):
			_set_queued(i, idle)
	else:
		if queued[at] != idle:
			var ret = queued[at]
			for i in range(at, max_queue - 1):
				_set_queued(i, queued[i+1])
			_set_queued(-1, idle)
			return ret
		else:
			return idle

func _set_queued(index:int, action:Action):
	queued[index] = action
	queue_labels[index].text = action.queue_description

func add_queue(action:Action):
	if current == idle:
		current = action
		progress = 0.0
		return 0
	else:
		for i in range(max_queue):
			if queued[i] == idle:
				_set_queued(i, action)
				return i+1
	return -1
