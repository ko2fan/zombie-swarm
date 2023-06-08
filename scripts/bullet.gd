extends Area2D
class_name Bullet

@onready var raycast = $RayCast2D

@export var speed = 700
@export var lifetime = 4

var alive = false

func _physics_process(delta):
	position += Vector2(speed * delta, 0).rotated(rotation)
	lifetime -= delta
	if lifetime <= 0:
		die()
	raycast.target_position = Vector2(speed * delta, 0).rotated(rotation)
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("enemies"):
			collider.take_damage(20)
			die()
		
func die():
	reset()
	call_deferred("remove_from_parent")

func remove_from_parent():
	get_parent().remove_child(self)

func reset():
	lifetime = 4;
	alive = false
