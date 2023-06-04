extends State
class_name HuntState

@onready var state_machine : StateMachine = get_parent()
@onready var attack_state : AttackState = get_parent().get_node("AttackState")

func enter(node: Node):
	print(node.name + " has entered the hunt state")
	
func exit(node: Node):
	print(node.name + " has exited the hunt state")
	
func update(node: Node, delta: float):
	if node.get_first_visible_enemy() == null:
		node.look_around(delta)
	else:
		state_machine.change_to_state(attack_state)
