extends Node

var levelScores: Dictionary[String,int]
var currentScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the current levels name
	var currentScenePath = get_tree().current_scene.scene_file_path
	currentScene = currentScenePath.get_file().get_basename()
	# Load any data to level, if existing
	if loadData() != null:
		levelScores = loadData()
	
	print("Prior Best: ")
	print(levelScores.get(currentScene))
	print(currentScene)

func _on_grid_clear_score(rating: int) -> void:
	#Add the current levels score to the dictionary if it is a new high score or no score exists
	if levelScores.get(currentScene) != null &&  rating > levelScores.get(currentScene):
		var scoreEntry: Dictionary[String, int] = {currentScene: rating}
		levelScores.assign(scoreEntry)
	elif levelScores.get(currentScene) == null:
		var scoreEntry: Dictionary[String, int] = {currentScene: rating}
		levelScores.assign(scoreEntry)
	saveData()

func saveData():
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	# Save level Scores
	for i in levelScores.size():
		saveFile.store_line(str(levelScores.keys()[i],":",levelScores.values()[i],"\r").replace(" ",""))
	saveFile.close()
	# TODO save item usages and coins

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
