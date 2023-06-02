extends Node2D

signal enemy_spawned

@onready var zombie_prefab = preload("res://scenes/zombie.tscn")

func _on_timer_timeout():
	var zombie = zombie_prefab.instantiate()
	add_child(zombie)
	emit_signal("enemy_spawned", zombie)
