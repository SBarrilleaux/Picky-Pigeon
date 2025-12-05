# Logic for the board Nibbles / pieces
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
# Keeps the base scale each nibble should display as
var defaultScale: Vector2
var matched = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = $Sprite2D
	outline = $Outline
	defaultScale = scale
# animates nibble movement
func move(target):
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",target, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# handles any special effects around matching nibbles
func dim():
	$GPUParticles2D.restart()
	sprite.modulate = Color(1.5,1.5,1.5, .5)
	var tween: Tween = create_tween()
	tween.tween_property(self,"scale",scale + effectScaleAmount, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# When nibble is changed to item remove its outline and undo effect from dim
func resetScaleAndSetModulate():
	scale = defaultScale
	sprite.scale = Vector2(0.08,0.08)
	sprite.modulate = Color(1,1,1,1)
	outline.modulate = Color(0,0,0,0)

# All four turn nibble into a kind of item, same logic on each currently except the kind of nibble they are be converted to
func makeColBomb():
	isColBomb = true
	sprite.texture = colBomb
	nibbleType = "colBomb"
	resetScaleAndSetModulate()
func makeRowBomb():
	isRowBomb = true
	sprite.texture = rowBomb
	nibbleType = "rowBomb"
	resetScaleAndSetModulate()
func makeTypeBomb():
	isTypeBomb = true
	sprite.texture = typeBomb
	nibbleType = "typeBomb"
	resetScaleAndSetModulate()
	
func makeBigBomb():
	isBigBomb = true
	sprite.texture = bigBomb
	nibbleType = "bigBomb"
	resetScaleAndSetModulate()
