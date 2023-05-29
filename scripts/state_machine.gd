extends Node
class_name StateMachine

@export var node : Node

var state_queue = []
var current_state : State

func change_to_state(state: State):
	if current_state:
		current_state.exit(node)
	current_state = state
	current_state.enter(node)
	
func _process(delta):
	current_state.update(node, delta)
