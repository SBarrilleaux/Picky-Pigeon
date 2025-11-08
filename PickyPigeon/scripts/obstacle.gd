extends Node2D

# How many matches to destroy
@export var health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func takeDamage(damage):
	health -= damage
	print(health)
	# TODO damage effect

func getHealth() -> int:
	return health
