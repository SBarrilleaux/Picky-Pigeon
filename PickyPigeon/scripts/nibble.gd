extends Node2D

@export var nibbleType:String 

var sprite
var effectScaleAmount = Vector2(.3,.3)

var matched = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = $Sprite2D
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# animates nibble movement
func move(target):
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",target, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func dim():
	#var sprite = get_node("Sprite2D")
	#currentScale = scale
	sprite.modulate = Color(1.5,1.5,1.5, .5)
	var tween: Tween = create_tween()
	tween.tween_property(self,"scale",scale + effectScaleAmount, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
