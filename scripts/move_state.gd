extends State
class_name MoveState

@onready var state_machine : StateMachine = get_parent()
@onready var idle_state : IdleState = get_parent().get_node("IdleState")
@onready var attack_state : AttackState = get_parent().get_node("AttackState")

func enter(node: Node):
	print(node.name + " has entered the move state")
	
func exit(node: Node):
	print(node.name + " has exited the move state")
	
func update(node: Node, delta: float):
	node.move(delta)
	if node.is_target_in_visible_range():
		node.steer(delta)
		if node.is_target_in_attack_range():
			if node.is_facing_target():
				state_machine.change_to_state(attack_state)
			else:
				node.face_target(delta)
	else:
		node.set_target(null)
		state_machine.change_to_state(idle_state)
