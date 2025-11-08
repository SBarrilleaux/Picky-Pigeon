extends Node2D

@export var boardGrid: Node2D

var mainBoardLayer: TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainBoardLayer = $BoardTiles
	#boardGrid.emptySpaces

# Receives signal of spaces on current board to place background tiles
func _on_grid_valid_tiles(boardSpace: Vector2) -> void:
# places tiles with a -8 offset to account for grid misalignment, the tilemaplayer itself is also scaled by -1 to account for it
	mainBoardLayer.set_cell(Vector2(boardSpace.x,boardSpace.y - 8),0,Vector2i(1,1))
