extends CharacterBody2D

@onready var state_machine : StateMachine = $StateMachine
@onready var idle_state : IdleState = $StateMachine/IdleState

func _ready():
	state_machine.change_to_state(idle_state)
	
# Unit should turn towards enemy

# Unit should shoot enemy when in range
