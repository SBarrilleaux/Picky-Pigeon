extends Node2D

# Board Grid Height and Width
@export var width: int
@export var height: int
@export var xStart: int
@export var yStart: int
@export var offset: int

# Board customizations
@export var emptySpaces: PackedVector2Array
signal validTiles(boardSpace: Vector2)


# state machine
enum {wait, move, gameOver}
var state
# how much nibble should drop from
@export var yNibbleOffset: int
# load the different nibble types so they can be used later
var possibleNibbles = [
	preload("res://Nibbles/NibbleScenes/nibble_blueberry.tscn"),
	preload("res://Nibbles/NibbleScenes/nibble_popcorn.tscn"),
	preload("res://Nibbles/NibbleScenes/nibble_sunflower.tscn"),
	preload("res://Nibbles/NibbleScenes/nibble_peanut.tscn")
]
# the board / nibbles on the board
var boardNibbles = []

# Variables used for swapping back when a swap doesn't creeate a match
var nibbleOne = null
var nibbleTwo = null
var lastPlace = Vector2.ZERO
var lastDirection = Vector2.ZERO
var moveChecked = false

@export var turnMax: int = 0
var turnRemaining: int = 0


# Input Variables
var first_click = Vector2.ZERO
var final_click = Vector2.ZERO
var controlling = false


var turnText = ""

# check if a tile isn't factored into nibble movements
func restictedMovement(place: Vector2):
	# check empty
	for i in emptySpaces.size():
		if emptySpaces[i] == place:
			return true
	return false

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
			if !restictedMovement(Vector2(i,j)):
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
func isInGrid(gridPosition):
	if gridPosition.x >= 0 && gridPosition.x < width:
		if gridPosition.y >= 0 && gridPosition.y < height:
			return true
	return false

# handles storing inputs and converts mouse positions to its grid position
func mouseInput():
	if Input.is_action_just_pressed("click"):
		if isInGrid(pixelToGrid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_click = pixelToGrid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = true
			
	if Input.is_action_just_released("click"):
		if isInGrid(pixelToGrid(get_global_mouse_position().x, get_global_mouse_position().y)) && controlling == true:
			controlling = false
			final_click = pixelToGrid(get_global_mouse_position().x, get_global_mouse_position().y)
			touchDifference(first_click, final_click)
			controlling = false
# Takes the position in the grid of a piece, and then direction to swap it
func swapNibble(column, row, direction: Vector2):
	var firstNibble = boardNibbles[column][row]
	var secondNibble = boardNibbles[column + direction.x][row + direction.y]
	
	if firstNibble != null && secondNibble != null:
		storeInfo(firstNibble, secondNibble, Vector2(column,row), direction)
		# Swaps the pieces in the grid
		state = wait
		boardNibbles[column][row] = secondNibble
		boardNibbles[column + direction.x][row + direction.y] = firstNibble
		# Swaps the pieces actual visual position
		firstNibble.move(gridToPixel(column + direction.x, row + direction.y))
		secondNibble.move(gridToPixel(column, row))
		
		if !moveChecked:
			findMatches()
			turnRemaining -= 1
		updateText()

# Store the nibbles to be matched in case swap back is needed
func storeInfo(firstNibble,secondNibble, place, direction):
	nibbleOne = firstNibble
	nibbleTwo = secondNibble
	lastPlace = place
	lastDirection = direction

# move previously swapped pieces back if no match is made
func swapBack():
	if nibbleOne != null && nibbleTwo != null:
		turnRemaining += 1
		swapNibble(lastPlace.x,lastPlace.y, lastDirection)
	state = move
	moveChecked = false


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
	$DestroyTimer.start()

func destroyMatched():
	var wasMatched = false
	for i in width:
		for j in height:
			if boardNibbles[i][j] != null:
				if boardNibbles[i][j].matched:
					wasMatched = true
					boardNibbles[i][j].queue_free()
					boardNibbles[i][j] = null
	moveChecked = true
	if wasMatched:
		$CollapseTimer.start()
	else:
		swapBack()

# Makes nibbles "fall" by searching above to the height for a moveable nibble
func collapseColumns():
	for i in width:
		for j in height:
			if boardNibbles[i][j] == null && !restictedMovement(Vector2(i,j)):
				for k in range(j + 1, height):
					if boardNibbles[i][k] != null:
						boardNibbles[i][k].move(gridToPixel(i,j))
						boardNibbles[i][j] = boardNibbles[i][k]
						boardNibbles[i][k] = null
						break
	$RefillTimer.start()


func refillColumns():
	for i in width:
		for j in height:
			if boardNibbles[i][j] == null && !restictedMovement(Vector2(i,j)):
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
				newNibble.set_position(gridToPixel(i,height))
				newNibble.move(gridToPixel(i,j))
				boardNibbles[i][j] = newNibble # change to new array if this isnt
	afterRefill()

func afterRefill():
	for i in width:
		for j in height:
			if boardNibbles[i][j] != null:
				if matchAt(i,j, boardNibbles[i][j].nibbleType):
					findMatches()
					$DestroyTimer.start()
					return
	state = move
	moveChecked = false


func _on_destroy_time_timeout() -> void:
	destroyMatched()

func _on_collapse_timer_timeout() -> void:
	collapseColumns()

func _on_refill_timer_timeout() -> void:
	refillColumns()
	#findMatches()

func updateText():
	turnText.text = "Turns \n Remaining \n" + str(turnRemaining)
	
func endLevel():
	state = gameOver
	await waitTimer(1)
	get_parent().get_node("GameOver").visible = true
# Called when the node enters the scene tree for the first time.

func waitTimer(seconds: float):
	await get_tree().create_timer(seconds).timeout

func _ready() -> void:
	state = move
	# seeds the random generation
	randomize()
	# intial board setup
	boardNibbles = make2dArray()
	spawnNibbles()
	turnRemaining = turnMax
	turnText = %TurnTextLabel
	updateText()
	
	for i in width:
		for j in height:
			if boardNibbles[i][j] != null && !restictedMovement(Vector2(i,j)):
				validTiles.emit(pixelToGrid(boardNibbles[i][j].position.x,boardNibbles[i][j].position.y))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if turnRemaining > 0 && state == move:
		mouseInput()
	elif turnRemaining == 0 && state == move:
			endLevel() # TODO move this around
