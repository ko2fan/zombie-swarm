extends Node

var enemy_nodes = []
var bullet_pool = []

@onready var bullet_prefab = preload("res://scenes/bullet.tscn")

func _ready():
	randomize()
	get_node("/root/Game/ZombieSpawner").enemy_spawned.connect(on_enemy_spawn)
	for bullet in range(20):
		var bullet_instance = bullet_prefab.instantiate()
		bullet_pool.append(bullet_instance)

func get_bullet() -> Bullet:
	for bullet in bullet_pool:
		if bullet.alive == false:
			bullet.alive = true
			add_child(bullet)
			return bullet
	print ("ERROR: No bullets left!")
	return null
	
func on_enemy_spawn(enemy):
	enemy_nodes.append(enemy)
	enemy.enemy_died.connect(on_enemy_death)

func on_enemy_death(enemy):
	enemy_nodes.erase(enemy)
