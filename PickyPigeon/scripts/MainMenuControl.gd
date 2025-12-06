# Manages everything main-menu related, mostly creating the level list and things like fading out the main logo
extends Node2D

# Groups for controlling visibility
var logoGroup
var levelsGroup
var playerInfo
var startupTimer
var levelList
var levelRatingList
@export var levelIcon: GradientTexture2D
@export var levels: Array[PackedScene]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logoGroup = $MainMenu/Logo
	startupTimer = $Startup
	levelsGroup = $"MainMenu/LevelSelect"
	playerInfo = $PlayerData
	levelsGroup.modulate = Color(0,0,0,0)
	logoGroup.visible = true
	levelsGroup.visible = false
	levelList = $MainMenu/LevelSelect/LevelScroll/LevelList
	levelList.max_columns = levels.size() + 1
	# generate an item in the list for each level
	for i in levels.size():
		var levelName = levels[i].resource_path.get_basename().split("Levels/")
		# add level to selection menu
		levelList.add_item("Level " + str(i + 1) + '\n' + str(playerInfo.getLevelScore(levelName[1])) + "/3", randomIconColor(i), true)

	$MainMenu/LevelSelect/CoinText.text = "Coins \n" + str(playerInfo.coins)
	$MainMenu/LevelSelect/PickyPigeon.play("PigeonOther")
	$BackgroundMusic.play()
# Generate a random circle icon for each level
# Color is random from the seed it is called with, but is it being called with the same seed on each run of the game so that it looks conistent
func randomIconColor(iconSeed: int) -> GradientTexture2D:
	seed(iconSeed)
	#var ranNum: int = randi_range(0,255)
	var ranNum: float = randf()
	#var ranNumTwo: int = randi_range(0,255)
	var ranNumTwo: float = randf()
	var gradientData = {
	 0.49: Color(ranNum,ranNumTwo,1,1),
	0.50: Color(0,0, 0, 0),
	}
	# Create the texture from random generation
	var gradientRandom: Gradient = Gradient.new()
	gradientRandom.offsets = gradientData.keys()
	gradientRandom.colors = gradientData.values()
	var newTexture = GradientTexture2D.new()
	newTexture.gradient = gradientRandom
	newTexture.width = 256
	newTexture.height = 256
	newTexture.fill = GradientTexture2D.FILL_RADIAL
	newTexture.fill_from = Vector2(0.5,0.5)
	newTexture.fill_to = Vector2(0,0)
	return newTexture

# Fade out logo
func _on_startup_timeout() -> void:
	logoGroup.modulate = Color(1,1,1,.5)
	var tween: Tween = create_tween()
	tween.tween_property(logoGroup,"modulate", Color(1,1,1, 0), .7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(tweenDone)

# Fade in menus
func tweenDone():
	logoGroup.visible = false
	levelsGroup.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(levelsGroup,"modulate", Color(1,1,1, 1), .4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	

# Changes scene to selected level
func _on_level_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	playerInfo.saveData()
	if levels[index] != null && mouse_button_index == 1:
		get_tree().change_scene_to_packed(levels[index])
