extends Node2D

# Groups for controlling visibility
var logoGroup
var levelsGroup

var startupTimer
@export var levelIcon: GradientTexture2D
@export var levels: Array[PackedScene]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	seed(12345)
	
	logoGroup = $Control/Logo
	startupTimer = $Startup
	levelsGroup = $"Control/LevelSelect"
	logoGroup.visible = true
	levelsGroup.visible = false
	
	for i in levels.size():
		print(i)
		levelIcon.gradient = randomIconColor()
		$"Control/LevelSelect/LevelList".add_item("Level " + str(i + 1), levelIcon, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	
func randomIconColor() -> Gradient:
	var ranNum: int = randi_range(0,255)
	var ranNumTwo: int = randi_range(0,255)
	var gradientData := {
	 0.49: Color(ranNum,ranNumTwo,255,1),
	0.50: Color(0,0, 0, 0),
}
	var gradientRandom: Gradient = Gradient.new()
	gradientRandom.offsets = gradientData.keys()
	gradientRandom.colors = gradientData.values()
	return gradientRandom

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
	
