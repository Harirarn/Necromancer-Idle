class_name game_state extends Node

var game_speed:float = 10.0
var resources:Dictionary
var knowledge:Array[String]
var rng = RandomNumberGenerator.new()
var action_bar = load("res://action_bar.tscn")
@onready var action_tabs = %"Action Tabs"
@onready var action_queue = %action_queue
var minion_template = load("res://minion.tscn")
var minion_count:int = 0

func _ready():
	resources["grave"] = 20
	resources["bones"] = 0
	resources["skull"] = 0
	add_action(load("res://actions/exhume.tres"), "Labour")
	add_action(load("res://actions/resurrect_simple_skeleton.tres"), "Necromancy")
	#action_tabs.set_tab_hidden(2, true)

func log_message(message:String):
	%LogText.text += "\n" + message

func check_costs(costs, deduct=false):
	for item in costs:
		if item not in resources or resources[item] < costs[item]:
			return false
	if deduct:
		for item in costs:
			resources[item] -= costs[item]
	return true

func refund(costs):
	for item in costs:
		resources[item] += costs[item]



func add_tab(name:String):
	pass

func learn(skill:String):
	if skill not in knowledge:
		knowledge.append(skill)
		match skill:
			"bone_shovel":
				add_action(load("res://actions/bone_shovel.tres"), "Labour")
				add_action(load("res://actions/assemble_simple_skeleton.tres"), "Labour")

func skill_level(skill:String):
	match skill:
		"shovel":
			if resources.get("bone_shovel", 0) >= 1:
				return 5.0
	return 1.0

func add_action(action:Action, tab="Labour"):
	var tab_panel = action_tabs.find_child(tab, false).find_child("Action List", false)
	var action_instance:Action_bar = action_bar.instantiate()
	tab_panel.add_child(action_instance)
	action_instance.game_state = self
	action_instance.action = action
	action_instance._button.connect("pressed",func():queue_action(action))

func add_minion():
	var tab_panel = action_tabs.find_child("Minions").find_child("Minion List", false)
	var minion_instance = minion_template.instantiate()
	tab_panel.add_child(minion_instance)
	minion_instance.game_state = self
	minion_instance.minion_id = minion_count
	minion_count += 1

func queue_action(action:Action):
	action_queue.add_queue(action)

func perform(action:Action):
	match action.recall:
		"dig":
			resources["bones"] += rng.randi_range(8, 50)
			resources["skull"] += rng.randi_range(0, 1)
			log_message("You found some bones")
			learn("bone_shovel")
		"bone_shovel":
			resources["bone_shovel"] = resources.get("bone_shovel", 0) + 1
		"assemble_skel_s":
			resources["skel_s"] = resources.get("skel_s", 0) + 1
		"res_skel_s":
			add_minion()
		_:
			print("Unexpected action.")

