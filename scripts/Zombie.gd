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
@export var attack_range : float = 105
@export var time_between_attacks : float = 1.2

@onready var state_machine : StateMachine = $StateMachine
@onready var idle_state : IdleState = $StateMachine/IdleState
@onready var move_state : MoveState = $StateMachine/MoveState
@onready var hunt_state : HuntState = $StateMachine/HuntState
@onready var raycast_middle = $Raycast1
@onready var raycast_left = $Raycast2
@onready var raycast_right = $Raycast3
@onready var raycast_visible = $Raycast4
@onready var avoidance_area = $AvoidanceArea

var enemy_target
var random_amount
var attack_timer
var elapsed = 0
var cached_index = -1

var nearby_allies = []

var interests = []
var dangers = []

signal enemy_died

func _init():
	add_to_group("enemies")
	random_amount = 999
	attack_timer = 0
	randomize()
	
func _ready():
	state_machine.change_to_state(idle_state)
	for i in range(0, 8):
		interests.append(0)
		dangers.append(0)
	
#func _draw():
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(0), Color.RED)
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(0.78), Color.DARK_RED)
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(1.5), Color.ROSY_BROWN)
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(2.38), Color.REBECCA_PURPLE)
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(3.141), Color.ROYAL_BLUE)
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(-2.38), Color.LAWN_GREEN)
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(-1.5), Color.GHOST_WHITE)
#	draw_line(raycast_visible.position, Vector2(visible_range, 0).rotated(-0.78), Color.YELLOW)

func get_first_visible_enemy() -> Node2D:
	raycast_middle.target_position = Vector2(visible_range, 0).rotated(rotation)
	if raycast_middle.is_colliding():
		var collider = raycast_middle.get_collider()
		if collider != null && not collider.is_in_group("enemies"):
			return collider
	raycast_left.target_position = Vector2(visible_range, 0).rotated(rotation - 1.25)
	if raycast_left.is_colliding():
		var collider = raycast_left.get_collider()
		if collider != null && not collider.is_in_group("enemies"):
			return collider
	raycast_right.target_position = Vector2(visible_range, 0).rotated(rotation + 1.25)
	if raycast_right.is_colliding():
		var collider = raycast_right.get_collider()
		if collider != null && not collider.is_in_group("enemies"):
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
	return (angle < 0.15 && angle > -0.15)

func face_target(delta: float):
	rotate(get_angle_to(enemy_target.global_position) * delta)
	#avoid_allies()
	
# Unit should shoot enemy when in range
func is_target_in_visible_range() -> bool:
	return enemy_target != null && (enemy_target.global_position.distance_to(self.global_position) <= visible_range)
	
func is_target_in_attack_range() -> bool:
	return enemy_target != null && (enemy_target.global_position.distance_to(self.global_position) <= attack_range)

func steer(delta):
	elapsed += delta
	
	var areas = avoidance_area.get_overlapping_areas()
	for area in areas:
		# get direction to each area, set as danger
		pass
		
	# reset interests and dangers
	for interest in interests:
		interest = 0
	for danger in dangers:
		danger = 0
	
	if enemy_target != null:
		interests[0] = find_target(0)		
		interests[1] = find_target(0.78)
		interests[2] = find_target(1.5)
		interests[3] = find_target(2.38)
		interests[4] = find_target(PI)
		interests[5] = find_target(-2.38)
		interests[6] = find_target(-1.5)
		interests[7] = find_target(-0.78)
				
		if interests.filter(func(number): return number > 0) == []:
			pass#print("Target not found")
	
	var steering = []
	for index in range(0, 8):
		steering.append(interests[index] - dangers[index])
		
	if steering.filter(func(number): return number > 0) != []:
		print("Steering: " + str(steering))
	
	var best_dir = 0
	var best_index = -1
	var index = 0
	for dir in steering:
		if dir > best_dir:
			best_dir = dir
			best_index = index
		index += 1
	if best_index != -1:
		print("Found new best index: " + str(best_index))
		cached_index = best_index
	else:
		best_index = cached_index
	
	var new_dir = -PI
	match best_index:
		0:
			new_dir = 0
		1:
			new_dir = 0.78
		2:
			new_dir = 1.5
		3:
			new_dir = 2.38
		4:
			new_dir = PI
		5:
			new_dir = -2.38
		6:
			new_dir = -1.5
		7:
			new_dir = -0.78
	
	if new_dir != -PI:
		if elapsed > 1:
			elapsed = 0
		rotation = lerp_angle(rotation, new_dir + rotation, elapsed)
	
func move(delta: float):
	position += Vector2(speed * delta, 0).rotated(rotation)
	
func attack(delta: float):
	attack_timer += delta
	if attack_timer < time_between_attacks:
		return
	attack_timer = 0
	raycast_middle.target_position = Vector2(attack_range + 100, 0).rotated(rotation)
	raycast_middle.force_raycast_update()
	if raycast_middle.is_colliding():
		var collider = raycast_middle.get_collider()
		collider.take_damage(15)
		print("Zombie " + name + " ate the player!")
	
func look_around(delta):
	if random_amount == 999 or random_amount == rotation:
		random_amount = randf_range(0, PI * 2)
		elapsed = 0
	#rotate(random_amount * delta)
	elapsed += delta
	rotation = lerp_angle(rotation, random_amount, elapsed)

func avoid_allies():
	for ally in nearby_allies:
		rotation = lerp_angle(rotation, ally.rotation + PI, 0.6)

func _on_avoidance_area_body_entered(body):
	if body.is_in_group("enemies"):
		nearby_allies.append(body)
	
func _on_avoidance_area_body_exited(body):
	if body.is_in_group("enemies"):
		nearby_allies.erase(body)
		
func find_target(angle: float) -> int:
	raycast_visible.target_position = Vector2(visible_range, 0).rotated(angle)
	raycast_visible.force_raycast_update()
	if raycast_visible.is_colliding():
		if not raycast_visible.get_collider().is_in_group("enemies"):
			return 100
	return 0
