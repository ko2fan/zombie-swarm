extends Node2D

@onready var zombie_prefab = preload("res://scenes/zombie.tscn")

func _on_timer_timeout():
	var zombie = zombie_prefab.instantiate()
	add_child(zombie)
	GameState.enemy_nodes.append(zombie)
