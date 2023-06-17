extends State
class_name AttackState

@onready var state_machine : StateMachine = get_parent()
@onready var idle_state : IdleState = get_parent().get_node("IdleState")
@onready var move_state : MoveState = get_parent().get_node("MoveState")

func enter(node: Node):
	print(node.name + " has entered the attack state")
	
func exit(node: Node):
	print(node.name + " has exited the attack state")
	
func update(node: Node, delta: float):
	if node.is_target_in_visible_range():
		if node.is_target_in_attack_range():
			if node.is_facing_target():
				node.attack(delta)
			else:
				node.face_target(delta)
		else:
			state_machine.change_to_state(move_state)	
	else:
		node.set_target(null)
		state_machine.change_to_state(idle_state)
