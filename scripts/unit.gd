extends CharacterBody2D

@export var visible_range : float = 750
@export var attack_range : float = 750
@export var max_shoot_time : float = 0.8
@export var damage_dealt : float = 20
@export var health : float = 100
@export var speed : float = 15

@onready var state_machine : StateMachine = $StateMachine
@onready var idle_state : IdleState = $StateMachine/IdleState

var enemy_target
var time_to_shoot

signal player_died

func _ready():
	state_machine.change_to_state(idle_state)
	time_to_shoot = 0
	
#func _draw():
#	draw_line(Vector2(0.0, 0.0), Vector2(length, 0).rotated(rotation), Color.WHITE, 3.0)
	
# look for enemy
func get_first_visible_enemy() -> Node2D:
	for enemy in GameState.enemy_nodes:
		if enemy.global_position.distance_to(self.global_position) < visible_range:
			return enemy
	return null
	
func set_target(target):
	enemy_target = target
	
func take_damage(damage_amount):
	health = health - damage_amount
	if health <= 0:
		emit_signal("player_died")
		queue_free()

# Unit should turn towards enemy
func is_facing_target() -> bool:
	var angle = get_angle_to(enemy_target.global_position)
	return (angle < 0.01 && angle > -0.01)

func face_target(delta: float):
	rotate(get_angle_to(enemy_target.global_position) * delta)
	
# Unit should shoot enemy when in range
func is_target_in_visible_range() -> bool:
	return enemy_target != null && (enemy_target.global_position.distance_to(self.global_position) <= visible_range)
	
func is_target_in_attack_range() -> bool:
	return enemy_target != null && (enemy_target.global_position.distance_to(self.global_position) <= attack_range)

func move_to_target():
	pass
	
func move(delta: float):
	position += Vector2(speed * delta, 0).rotated(rotation)
	
func attack(delta: float):
	time_to_shoot += delta
	if time_to_shoot < max_shoot_time:
		return
	time_to_shoot = 0
	var bullet = GameState.get_bullet()
	if bullet:
		bullet.global_position = self.global_position
		bullet.rotation = bullet.get_angle_to(enemy_target.global_position)

func look_around():
	pass
	
