extends CharacterBody2D

# have a number of rays that points out from the enemy
# have an array of interest
# have an array of danger
# avoid danger, which can be colliders of its own type, as well as walls
# point towards highest interest
# smooth the final direction of interest
# experiment, have fun
# http://www.gameaipro.com/GameAIPro2/GameAIPro2_Chapter18_Context_Steering_Behavior-Driven_Steering_at_the_Macro_Scale.pdf
@export var health : float = 100
@export var speed : float = 25
@export var visible_range : float = 1000
@export var attack_range : float = 100
@export var time_between_attacks : float = 1.2

@onready var state_machine : StateMachine = $StateMachine
@onready var idle_state : IdleState = $StateMachine/IdleState
@onready var move_state : MoveState = $StateMachine/MoveState
@onready var hunt_state : HuntState = $StateMachine/HuntState
@onready var raycast_middle = $Raycast1
@onready var raycast_left = $Raycast2
@onready var raycast_right = $Raycast3

var enemy_target
var random_amount
var attack_timer

var nearby_allies = []

var interests = []
var dangers = []

signal enemy_died

func _init():
	add_to_group("enemies")
	random_amount = 999
	attack_timer = 0
	
func _ready():
	state_machine.change_to_state(idle_state)
	
#func _draw():
#	draw_line(self.position, Vector2(visible_range, 0).rotated(rotation), Color.RED)
#	draw_line(self.position, Vector2(visible_range, 0).rotated(rotation - 1.25), Color.YELLOW)
#	draw_line(self.position, Vector2(visible_range, 0).rotated(rotation + 1.25), Color.CYAN)

func get_first_visible_enemy() -> Node2D:
	raycast_middle.target_position = Vector2(visible_range, 0).rotated(rotation)
	if raycast_middle.is_colliding():
		print("Found enemy with middle raycast")
		var collider = raycast_middle.get_collider()
		return collider
	raycast_left.target_position = Vector2(visible_range, 0).rotated(rotation - 1.25)
	if raycast_left.is_colliding():
		print("Found enemy with left raycast")
		var collider = raycast_left.get_collider()
		return collider
	raycast_right.target_position = Vector2(visible_range, 0).rotated(rotation + 1.25)
	if raycast_right.is_colliding():
		print("Found enemy with right raycast")
		var collider = raycast_right.get_collider()
		return collider
	return null
	
func take_damage(damage_amount):
	health = health - damage_amount
	if health <= 0:
		emit_signal("enemy_died", self)
		queue_free()
	elif enemy_target == null:
		state_machine.change_to_state(hunt_state)

func set_target(target):
	enemy_target = target

func is_facing_target() -> bool:
	var angle = get_angle_to(enemy_target.global_position)
	return (angle < 0.01 && angle > -0.01)

func face_target(delta: float):
	rotate(get_angle_to(enemy_target.global_position) * delta)
	avoid_allies()
	
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
	attack_timer += delta
	if attack_timer < time_between_attacks:
		return
	attack_timer = 0
	raycast_middle.target_position = Vector2(attack_range, 0).rotated(rotation)
	if raycast_middle.is_colliding():
		var collider = raycast_middle.get_collider()
		collider.take_damage(15)
	
func look_around(delta):
	if random_amount == 999 or random_amount == rotation:
		random_amount = randf_range(-1.25, 1.25)
	rotate(random_amount * delta)
	pass

func avoid_allies():
	for ally in nearby_allies:
		lerp_angle(rotation, ally.rotation * PI, 0.6)

func _on_avoidance_area_body_entered(body):
	if body.is_in_group("enemies"):
		nearby_allies.append(body)
	
func _on_avoidance_area_body_exited(body):
	if body.is_in_group("enemies"):
		nearby_allies.erase(body)
