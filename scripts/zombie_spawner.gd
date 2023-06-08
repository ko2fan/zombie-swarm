extends Node2D

signal enemy_spawned

@onready var timer = $Timer
var spawned = 0

@onready var zombie_prefab = preload("res://scenes/zombie.tscn")

func _on_timer_timeout():
	if spawned > 10:
		timer.stop()
		return
	var zombie = zombie_prefab.instantiate()
	spawned += 1
	add_child(zombie)
	emit_signal("enemy_spawned", zombie)
