extends Control

@export var clearIconTexture: Texture2D
@export var lossIconTexture: Texture2D
@export var scoreStartPoint: Vector2
@export var scoreHorizontalOffset: float
var scoreIconsArray: Array[TextureRect]

# Allows the main menu scene to be specified in editor
#@export var mainMenuScene: PackedScene
@export_file("*.tscn") var mainMenuScenePath: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Creates the icons for the rating visual
	for i in 3:
		var scoreIcon = TextureRect.new()
		scoreIcon.texture = lossIconTexture
		scoreIcon.position = Vector2(scoreStartPoint.x + (scoreHorizontalOffset * i), scoreStartPoint.y)
		# set scale to account for textures size
		scoreIcon.scale = Vector2(.2,.2)
		add_child(scoreIcon)
		scoreIconsArray.append(scoreIcon)


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_grid_clear_score(rating: int) -> void:
	# ensure rating is in correct range
	if rating > 3:
		rating = 3
	elif rating < 0:
		rating = 0
	
	else:
		for i in range(0,rating):
			# replace icons in clear visual based on score
			scoreIconsArray[i].texture = clearIconTexture
		


func _on_return_to_main_pressed() -> void:
	get_tree().change_scene_to_file(mainMenuScenePath)
