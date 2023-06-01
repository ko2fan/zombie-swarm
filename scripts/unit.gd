extends CharacterBody2D

@export var visible_range : float = 750
@export var max_shoot_time : float = 0.8
@onready var state_machine : StateMachine = $StateMachine
@onready var idle_state : IdleState = $StateMachine/IdleState

var enemy_target
var time_to_shoot

func _ready():
	state_machine.change_to_state(idle_state)
	time_to_shoot = max_shoot_time

func _process(delta):
	time_to_shoot -= delta
	time_to_shoot = max(0, time_to_shoot)
	
# look for enemy
func get_first_visible_enemy() -> Node2D:
	for enemy in GameState.enemy_nodes:
		if enemy.position.distance_to(self.position) < visible_range:
			return enemy
	return null
	
func set_target(target):
	enemy_target = target

# Unit should turn towards enemy
func is_facing_target() -> bool:
	return (get_angle_to(enemy_target.position) < 0.01)

func face_target(delta: float):
	rotate(get_angle_to(enemy_target.position) * delta)
	
# Unit should shoot enemy when in range
func is_target_in_range() -> bool:
	return (enemy_target.position.distance_to(self.position) < visible_range)

func shoot():
	if time_to_shoot <= 0:
		print("Bang")
		time_to_shoot = max_shoot_time
