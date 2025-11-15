extends Node2D

# How many matches to destroy
@export var maxHealth: int
# Organize from full sprite as start of array, and damage variants incrementing
@export var stateSprites: Array[Texture2D]
@export var nibbleType: String

var health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = maxHealth
	pass # Replace with function body.

func takeDamage(damage):
	health -= damage
	# If damaged, replace with a 'damaged sprite in the array
	if health < maxHealth && stateSprites.size() > 1:
		$Sprite2D.texture = stateSprites[1]

func getHealth() -> int:
	return health
