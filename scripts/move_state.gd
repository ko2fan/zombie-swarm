extends State
class_name MoveState

@onready var state_machine : StateMachine = get_parent()
@onready var idle_state : IdleState = get_parent().get_node("IdleState")
@onready var attack_state : AttackState = get_parent().get_node("AttackState")

func enter(_node: Node):
	pass
	
func exit(_node: Node):
	pass
	
func update(node: Node, delta: float):
	node.move(delta)
	if node.is_target_in_visible_range():
		if node.is_facing_target():
			if node.is_target_in_attack_range():
				state_machine.change_to_state(attack_state)
		else:
			node.face_target(delta)
	else:
		node.set_target(null)
		state_machine.change_to_state(idle_state)
