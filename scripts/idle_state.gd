extends State
class_name IdleState

@onready var state_machine : StateMachine = get_parent()
@onready var attack_state : AttackState = get_parent().get_node("AttackState")

func enter(node: Node):
	print(node.name + " has entered the idle state")
	
func exit(node: Node):
	print(node.name + " has exited the idle state")
	
func update(node: Node, delta: float):
	# Look for enemy
	var target = node.get_first_visible_enemy()
	if target != null:
		print("Enemy found")
		node.set_target(target)
		state_machine.change_to_state(attack_state)

