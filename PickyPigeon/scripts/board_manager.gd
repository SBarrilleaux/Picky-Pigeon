extends Node2D

# Board Grid Height and Width
@export var width: int
@export var height: int
@export var xStart: int
@export var yStart: int
@export var offset: int

# Board customizations
## Locations on board which nibbles can't land on
@export var emptySpaces: PackedVector2Array
## custom signal used to send all currently used board spaces to the tilsetlayer.
## This allows background tiles to automatically be placed to match the board spaces
signal validTiles(boardSpace: Vector2)

## Takes an int that should be 0-3 in score rating. 0 being fail and 3 being perfect.
signal clearScore(rating: int)
# state machine
enum {wait, move, item, gameOver}
var state
var recentItem: String

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

# Level Objectives
## Should contain the names of types of nibbles to be cleared
@export var objectiveItems: Array[String]
## Should contain the amount of types of nibble to be cleared, and be the same size as objectiveItems
@export var objectiveGoalTotal: Array[int]

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


# searches board for matches
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
		
		$Sounds/MoveSound.play(0)
		if !moveChecked:
			findMatches()
			turnRemaining -= 1
		updateMenus()

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
					updateObjectives(Vector2(i,j))
					wasMatched = true
					boardNibbles[i][j].queue_free()
					boardNibbles[i][j] = null				
					updateMenus()
					
					
	moveChecked = true
	
	if wasMatched:
		$Sounds/DestroySound.play(0)
		$CollapseTimer.start()
	else:
		swapBack()
## Check if match is part of any collection objectives and subtract if so and don't go below 0
func updateObjectives(gridPosition: Vector2):
	if boardNibbles[gridPosition.x][gridPosition.y] != null:
		if objectiveItems.has(boardNibbles[gridPosition.x][gridPosition.y].nibbleType):
			var itemIndex = objectiveItems.find(boardNibbles[gridPosition.x][gridPosition.y].nibbleType)
			if objectiveGoalTotal[itemIndex] > 0:
				objectiveGoalTotal[itemIndex] -= 1
			elif objectiveGoalTotal[itemIndex] <= 0:
				objectiveGoalTotal[itemIndex] = 0


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

func updateMenus():
	# update text for turns remaining
	turnText.text = "Turns \n Remaining \n" + str(turnRemaining)
	var counter = 0

	# update objectives to current amounts			
	for i in objectiveItems.size():
		%ObjectivesList.set_item_text(i, str(objectiveGoalTotal[i]))


func endLevel():
	state = gameOver
	await waitTimer(1)
	get_parent().get_node("GameOver").visible = true
	
	# get the amount of objectives completed
	var goalsComplete: int = 0
	for i in objectiveItems.size():
		if objectiveGoalTotal[i] == 0:
			goalsComplete += 1
	# Determine the level rating based on number of goals complete out of total amount of goals
	if goalsComplete == objectiveItems.size():
		emit_signal("clearScore", 3)
	elif goalsComplete == 0:
		emit_signal("clearScore", 0)
	elif goalsComplete <= objectiveItems.size()/2.00:
		emit_signal("clearScore", 1)
	elif goalsComplete >= objectiveItems.size()/2.00:
		emit_signal("clearScore", 2)


func waitTimer(seconds: float):
	await get_tree().create_timer(seconds).timeout


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = move
	# seeds the random generation
	randomize()
	# intial board setup
	boardNibbles = make2dArray()
	spawnNibbles()
	turnRemaining = turnMax
	turnText = %TurnTextLabel
	
	# Add current level objectives to the list on the right side of screen
	for i in objectiveItems.size():
		while objectiveItems.size() < objectiveGoalTotal.size():
			objectiveGoalTotal.pop_back()
			
		var iconTexture = load("res://Nibbles/NibbleArt/nibble_" + objectiveItems[i] + ".png")
		if iconTexture != null:
			%ObjectivesList.add_item(str(objectiveGoalTotal[i]),iconTexture,false)
		
	# Sends what tiles aren't restricted and should have background tiles placed for them as a signal.
	for i in width:
		for j in height:
			if boardNibbles[i][j] != null && !restictedMovement(Vector2(i,j)):
				validTiles.emit(pixelToGrid(boardNibbles[i][j].position.x,boardNibbles[i][j].position.y))
	
	updateMenus()
	# Start pickyPigeon's idle
	%PickyPigeon.play("PigeonIdle", 1.0, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if turnRemaining > 0 && state == move:
		mouseInput()
	elif turnRemaining == 0 && state == move:
			endLevel() # TODO
	elif state == item:
		itemMouseInput(recentItem)

"""
# Signal receivers for the different level items 

#func _on_item_remove_nibble_toggled(toggled_on: bool) -> void:
		#itemTrigger(1)
#func _on_item_clear_row_pressed() -> void:
	#itemTrigger(2)
#
#func _on_item_clear_column_pressed() -> void:
	#itemTrigger(4)

## Makes sure the button is displaying correctly and updates what currentItem is in use
#func itemTrigger(whatItem: int):
	#if state == move:
		#state = item
		#currentItem = whatItem
	## if button is pressed again without doing action, cancel
	#elif state == item:
		#state = move
	#elif state == wait:
		#updateItemButtonsDisplay()
"""
# Gets input when in the item state, and calling the correct function for each item
func itemMouseInput(currentItem: String):
	state = item
	recentItem = currentItem
	if Input.is_action_just_pressed("click"):
		if isInGrid(pixelToGrid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_click = pixelToGrid(get_global_mouse_position().x, get_global_mouse_position().y)
			match currentItem:
				"singleClear":
					destroySingularNibble(first_click)
				"rowClear":
					clearRow(first_click)
				"columnClear":
					clearColumn(first_click)
				"typeClear":
					clearAllOfType(first_click)
				_:
					print("Item select error in board Manager")
		else:
			updateItemButtonsDisplay()
			state = move

# Destroys a singular nibble at given grid position
func destroySingularNibble(gridPosition: Vector2):
	if boardNibbles[gridPosition.x][gridPosition.y] != null:
		updateObjectives(gridPosition)	
		boardNibbles[gridPosition.x][gridPosition.y].matched = true
		boardNibbles[gridPosition.x][gridPosition.y].dim()
		$DestroyTimer.start()	
		boardUpdate()
# clears the row of given grid position
func clearRow(gridPosition: Vector2):
	if boardNibbles[gridPosition.x][gridPosition.y] != null:
		for i in width:
			for j in height:
				if boardNibbles[i][gridPosition.y] != null:
					boardNibbles[i][gridPosition.y].matched = true
					updateObjectives(Vector2(i, gridPosition.y))	
					boardNibbles[i][gridPosition.y].dim()
				$DestroyTimer.start()
				boardUpdate()

# clears the column of given grid position
func clearColumn(gridPosition: Vector2):
	if boardNibbles[gridPosition.x][gridPosition.y] != null:
		for i in width:
			for j in height:
				if boardNibbles[gridPosition.x][j] != null:
					boardNibbles[gridPosition.x][j].matched = true
					updateObjectives(Vector2(gridPosition.x, j))
					boardNibbles[gridPosition.x][j].dim()
				$DestroyTimer.start()
				boardUpdate()
# clears all of the nibbleType specified by given grid position
func clearAllOfType(gridPosition: Vector2):
	if boardNibbles[gridPosition.x][gridPosition.y] != null:
		var typeSelected = boardNibbles[gridPosition.x][gridPosition.y].nibbleType
		for i in width:
			for j in height:
				if typeSelected != null && boardNibbles[i][j] != null:
					if typeSelected == boardNibbles[i][j].nibbleType:
						print("here!")
						boardNibbles[i][j].matched = true
						boardNibbles[i][j].dim()
						$DestroyTimer.start()
						boardUpdate()

# update board, usually needed after removing nibbles with items
func boardUpdate():
	updateMenus()
	$CollapseTimer.start()
	updateItemButtonsDisplay()
	state = wait
# Untoggles all buttons in itemButtons after an action
func updateItemButtonsDisplay():
	for i in get_tree().get_nodes_in_group("itemButtons"):
		i.itemButton.button_pressed = false
