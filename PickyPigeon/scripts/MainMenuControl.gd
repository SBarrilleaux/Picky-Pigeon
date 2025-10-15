extends Node2D

# Groups for controlling visibility
var logoGroup
var levelsGroup

var startupTimer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logoGroup = $Control/Logo
	startupTimer = $Startup
	levelsGroup = $"Control/Level Select"
	logoGroup.visible = true
	levelsGroup.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


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
	
