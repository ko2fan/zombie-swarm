extends Node2D

signal enemy_spawned

@onready var timer = $Timer
@onready var spawn_points = $SpawnPoints.get_children()

var spawned = 0
var spawns_in_area = []

@onready var zombie_prefab = preload("res://scenes/zombie.tscn")

func _on_timer_timeout():
	if spawned > 10:
		timer.stop()
		return
	var zombie = zombie_prefab.instantiate()
	var zombie_spawn_location := Vector2.ZERO
	for spawn_point in spawn_points:
		zombie_spawn_location = spawn_point.position
		var location_taken = false
		for spawn in spawns_in_area:
			if spawn_point.global_position.distance_to(spawn.global_position) <= 25:
				#print("Found inside")
				location_taken = true
				break
		if not location_taken:
			zombie.position = zombie_spawn_location
			spawned += 1
			add_child(zombie)
			emit_signal("enemy_spawned", zombie)
			break
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemies"):
		spawns_in_area.append(body)


func _on_area_2d_body_exited(body):
	if body.is_in_group("enemies"):
		spawns_in_area.erase(body)
