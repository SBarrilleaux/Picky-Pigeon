extends Node

var playerSaveStats: Dictionary[String,int]
var currentScene
var allButtonsToSave
var coins: int =  200
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the current levels name
	var currentScenePath = get_tree().current_scene.scene_file_path
	allButtonsToSave = get_tree().get_nodes_in_group("itemButtons")
	currentScene = currentScenePath.get_file().get_basename()
	# Load any data to level, if existing
	if loadData() != null:
		playerSaveStats = loadData()
		for i in allButtonsToSave.size():
			allButtonsToSave[i].loadButton(loadData())

	print("Prior Best: ")
	print(playerSaveStats.get(currentScene))
	print(currentScene)

# Reads the given folder to find out how many files are in it
func getFileCount(path: String) -> Array:
	var levelList = []
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			# Exclude "." and ".." which represent the current and parent directories
			if not fileName.begins_with("."):
				# Check if it's a file (not a directory)
				if not dir.current_is_dir():
					levelList.append(fileName.substr(0, fileName.length() - 5))
			fileName = dir.get_next()
		dir.list_dir_end()
	else:
		print("Could not open directory: ", path)

	return levelList



func _on_grid_clear_score(rating: int) -> void:
	#Add the current levels score to the dictionary if it is a new high score
	if playerSaveStats.get(currentScene) != null:
		if playerSaveStats[currentScene] < rating:
			playerSaveStats[currentScene] = rating
	saveData()

func saveData():
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if saveFile:
		print("Saving")
		# Save level Scores
		var allLevels = getFileCount("res://Levels/")
		
		for i in allLevels.size():
			if playerSaveStats.has(allLevels[i]):
				var foundKey = playerSaveStats[allLevels[i]]
				saveFile.store_line(str(allLevels[i],":",foundKey,"\r").replace(" ",""))
				
			else:
				# If the level has no entry, set it to a score of 0
				saveFile.store_line(str(allLevels[i],":",0,"\r").replace(" ",""))
		
		# save item uses
		allButtonsToSave = get_tree().get_nodes_in_group("itemButtons")
		for i in allButtonsToSave.size():
			saveFile.store_line(allButtonsToSave[i].saveButton())
		# save coins
		saveFile.store_line(str("coins",":",coins,"\r").replace(" ",""))

		saveFile.close()
	
	
# Loads data into a dictionary of string: int to return
func loadData():
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.READ)
	var content: Dictionary[String, int] = {}
	if saveFile != null:
		for i in saveFile.get_as_text().count(":"):
			var line = saveFile.get_line()
			var key = line.split(":")[0]
			var value = line.split(":")[1]
			if value.is_valid_int():
				value = int(value)
			elif value.is_valid_float():
				value = float(value)
			elif value.begins_with("["):
				value = value.trim_prefix("[")
				value = value.trim_suffix("]")
				value = value.split(",")
			content[key] = value
		saveFile.close()
		return content

func useCoins(coinCost: int) -> bool:
	if (coins - coinCost) > 0:
		coins -= coinCost
		print(coins)
		return true
	return false
