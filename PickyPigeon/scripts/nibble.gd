extends Node2D

@export var nibbleType:String 
@export var rowBomb: Texture
@export var colBomb: Texture
@export var typeBomb: Texture
@export var bigBomb: Texture

var isRowBomb = false
var isColBomb = false
var isTypeBomb = false
var isBigBomb = false
var sprite
var outline
var effectScaleAmount = Vector2(.3,.3)

var matched = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = $Sprite2D
	outline = $Outline
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
	$GPUParticles2D.restart()
	sprite.modulate = Color(1.5,1.5,1.5, .5)
	var tween: Tween = create_tween()
	tween.tween_property(self,"scale",scale + effectScaleAmount, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)



func makeColBomb():
	isColBomb = true
	sprite.texture = colBomb
	sprite.modulate = Color(1,1,1,1)
	outline.modulate = Color(0,0,0,0)
	nibbleType = "colBomb"
func makeRowBomb():
	isRowBomb = true
	sprite.texture = rowBomb
	sprite.modulate = Color(1,1,1,1)
	outline.modulate = Color(0,0,0,0)
	nibbleType = "rowBomb"
func makeTypeBomb():
	isTypeBomb = true
	sprite.texture = typeBomb
	sprite.modulate = Color(1,1,1,1)
	outline.modulate = Color(0,0,0,0)
	nibbleType = "typeBomb"
	
func makeBigBomb():
	isBigBomb = true
	sprite.texture = bigBomb
	sprite.modulate = Color(1,1,1,1)
	outline.modulate = Color(0,0,0,0)
	nibbleType = "bigBomb"
