extends CharacterBody2D

# have a number of rays that points out from the enemy
# have an array of interest
# have an array of danger
# avoid danger, which can be colliders of its own type, as well as walls
# point towards highest interest
# smooth the final direction of interest
# experiment, have fun
# http://www.gameaipro.com/GameAIPro2/GameAIPro2_Chapter18_Context_Steering_Behavior-Driven_Steering_at_the_Macro_Scale.pdf
@export var health = 100

signal enemy_died

func _init():
	add_to_group("enemies")

func take_damage(damage_amount):
	health = health - damage_amount
	if health <= 0:
		emit_signal("enemy_died", self)
		queue_free()
