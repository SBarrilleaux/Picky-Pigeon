extends Node2D

# Board Grid Height and Width
@export var width: int
@export var height: int
@export var xStart: int
@export var yStart: int
@export var offset: int



# load the different nibble types so they can be used later
var possibleNibbles = [
	preload("res://Nibbles/NibbleScenes/nibble_blueberry.tscn"),
	preload("res://Nibbles/NibbleScenes/nibble_popcorn.tscn"),
	preload("res://Nibbles/NibbleScenes/nibble_sunflower.tscn"),
	preload("res://Nibbles/NibbleScenes/nibble_peanut.tscn")
]
# the board / nibbles on the board
var boardNibbles = []

# Input Variables
var first_click = Vector2.ZERO
var final_click = Vector2.ZERO
var controlling = false


# this turns an array into a 2D array
func make2dArray():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

# chooses a random piece and spawns it on the board
# uses pixelToGrid
func spawnNibbles():
	for i in width:
		for j in height:
			# choose random nibble type to spawn
			var rand = floor(randf_range(0,possibleNibbles.size()))
			
			var newNibble = possibleNibbles[rand].instantiate()
			
			# Check if new nibble will create a match
			# if it would, reroll to different piece
			var loops = 0
			while(matchAt(i,j,newNibble.nibbleType) && loops < 100):
				rand = floor(randf_range(0,possibleNibbles.size() - 1))
				loops += 1
				newNibble = possibleNibbles[rand].instantiate()
			# spawn the chosen nibble in the scene
			add_child(newNibble) # new nodes need to be parented
			newNibble.set_position(gridToPixel(i,j))
			boardNibbles[i][j] = newNibble # change to new array if this isnt


# searches board for matches of three
func matchAt(column,row, nibbleType):
	
	if column > 1:
		if boardNibbles[column - 1][row] != null && boardNibbles[column-2][row] != null:
			if boardNibbles[column - 1][row].nibbleType == nibbleType && boardNibbles[column -2][row].nibbleType == nibbleType:
				return true
	if row > 1:
		if boardNibbles[column][row - 1] != null && boardNibbles[column][row - 2] != null:
			if boardNibbles[column][row - 1].nibbleType == nibbleType && boardNibbles[column][row - 2].nibbleType == nibbleType:
				return true

# these two functions convert grid space to pixel and pixel to grid space
# pixel is the screen space and actual mouse positions
# grid space is relating to how pieces are stored on the board

# grid positions to pixel
func gridToPixel(column, row):
	var newX = xStart + offset * column
	var newY = yStart + -offset * row
	return Vector2(newX, newY)
# pixel positions to grid
func pixelToGrid(pixelX, pixelY):
	var newX = round((pixelX - xStart) / offset)
	var newY = round((pixelY - yStart) / -offset)
	return Vector2(newX, newY)
	
# Checks if a position is a valid space on the board
func isInGrid(column, row):
	if column >= 0 && column < width:
		if row >= 0 && row < height:
			return true
	return false

# handles storing inputs and converts mouse positions to its grid position
# Uses pixelToGrid
func mouseInput():
	if Input.is_action_just_pressed("click"):
		#if isInGrid(pixelToGrid(get_global_mouse_position().x, get_global_mouse_position().y):
			#pass



		first_click = get_global_mouse_position()
		var gridPosition = pixelToGrid(first_click.x, first_click.y)
		if isInGrid(gridPosition.x,gridPosition.y):
			controlling = true
		else:
			controlling = false
			
	if Input.is_action_just_released("click"):
		final_click = get_global_mouse_position()
		var gridPosition = pixelToGrid(final_click.x, final_click.y)
		if isInGrid(gridPosition.x, gridPosition.y) && controlling == true:
			touchDifference(pixelToGrid(first_click.x, first_click.y), gridPosition)
			controlling = false
# Takes the position in the grid of a piece, and then direction to swap it
func swapNibble(column, row, direction: Vector2):
	var firstNibble = boardNibbles[column][row]
	var secondNibble = boardNibbles[column + direction.x][row + direction.y]
	
	# Swaps the pieces in the grid
	boardNibbles[column][row] = secondNibble
	boardNibbles[column + direction.x][row + direction.y] = firstNibble
	
	# Swaps the pieces actual visual position
	firstNibble.move(gridToPixel(column + direction.x, row + direction.y))
	secondNibble.move(gridToPixel(column, row))
	findMatches()
# Finds the direction to swap pieces in
func touchDifference(gridOne, gridTwo):
	var difference = gridTwo - gridOne
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swapNibble(gridOne.x, gridOne.y, Vector2(1,0))
		elif difference.x < 0:
			swapNibble(gridOne.x, gridOne.y, Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swapNibble(gridOne.x, gridOne.y, Vector2(0,1))
		elif difference.y < 0:
			swapNibble(gridOne.x, gridOne.y, Vector2(0,-1))
			
			


# Handles finding matches on the board during gameplay
# TODO refactor later
func findMatches():
	for column in width:
		for row in height:
			if boardNibbles[column][row] != null:
				var currentColor = boardNibbles[column][row].nibbleType
				if column > 0 && column < width - 1:
					if boardNibbles[column - 1][row] != null && boardNibbles[column + 1][row] != null:
						if boardNibbles[column - 1][row].nibbleType == currentColor && boardNibbles[column + 1][row].nibbleType == currentColor:
							boardNibbles[column - 1][row].matched = true
							boardNibbles[column - 1][row].dim()
							boardNibbles[column][row].matched = true
							boardNibbles[column][row].dim()
							boardNibbles[column + 1][row].matched = true
							boardNibbles[column + 1][row].dim()
							
							
				if row > 0 && row < height - 1:
					if boardNibbles[column][row - 1] != null && boardNibbles[column][row + 1] != null:
						if boardNibbles[column][row - 1].nibbleType == currentColor && boardNibbles[column][row + 1].nibbleType == currentColor:
							boardNibbles[column][row - 1].matched = true
							boardNibbles[column][row - 1].dim()
							boardNibbles[column][row].matched = true
							boardNibbles[column][row].dim()
							boardNibbles[column][row + 1].matched = true
							boardNibbles[column][row + 1].dim()
							
							
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# seeds the random generation
	randomize()
	# intial board setup
	boardNibbles = make2dArray()
	spawnNibbles()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouseInput()
	pass
