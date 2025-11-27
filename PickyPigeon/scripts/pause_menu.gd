extends Control
var musicVolumeDisplay: ProgressBar
var musicVolumeSlider: HSlider
var effectsVolumeDisplay: ProgressBar
var effectsVolumeSlider: HSlider
var playerNode
var boardManagerNode
## 0 would be the default pause menu for in levels, 1 is main menu version of the pause menu
@export var menuVersion: int

@export_file("*.tscn") var mainMenuScenePath: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicVolumeDisplay = $Menu/MusicValueDisplay
	musicVolumeSlider = $Menu/MusicValueDisplay/MusicValueSlider
	effectsVolumeDisplay = $Menu/EffectsValueDisplay
	effectsVolumeSlider = $Menu/EffectsValueDisplay/EffectsValueSlider
	$Menu.visible = false
	
	if menuVersion == null:
		menuVersion = 0

	playerNode = get_tree().get_first_node_in_group("playerDataGroup")
	boardManagerNode = get_tree().get_nodes_in_group("boardController")
	# make sure the player node has initialzed
	while playerNode == null:
		playerNode = get_tree().get_first_node_in_group("playerDataGroup")
		
	musicVolumeDisplay.value = playerNode.getSetting("musicVolume")
	if musicVolumeDisplay.value == null:
		musicVolumeDisplay.value = 100
	musicVolumeSlider.value =	musicVolumeDisplay.value

	effectsVolumeDisplay.value = playerNode.getSetting("effectsVolume")
	if effectsVolumeDisplay.value == null:
		effectsVolumeDisplay.value = 100
	effectsVolumeSlider.value = effectsVolumeDisplay.value
	
	get_tree().set_group("soundMusic", "volume_db", musicVolumeDisplay.value)
	get_tree().set_group("soundEffect", "volume_db", effectsVolumeDisplay.value)
	
func _on_music_value_slider_value_changed(value: float) -> void:
	# change visual slider bar
	musicVolumeDisplay.value = musicVolumeSlider.value
	# save the volume preference, as an int
	playerNode.updateSetting("musicVolume", int(musicVolumeDisplay.value))
	# adjust volume in level
	get_tree().set_group("soundMusic", "volume_db", toDecibel(musicVolumeDisplay.value))


func _on_effects_value_slider_value_changed(value: float) -> void:
	# change visual slider bar
	effectsVolumeDisplay.value = effectsVolumeSlider.value
	# save the volume preference, as an int
	playerNode.updateSetting("effectsVolume", int(effectsVolumeDisplay.value))
	# adjust volume in level
	get_tree().set_group("soundEffect", "volume_db", toDecibel(effectsVolumeDisplay.value))

# Converts slider values to decibel equivalent
func toDecibel(value: float) -> float:
	return 20 * log(value) / log(10)

func _on_settings_button_pressed() -> void:
	$Menu.visible = !$Menu.visible
	# set game to wait while menu is open
	if $Menu.visible:
		get_tree().call_group("boardController", "setState", 0)
	else:
		get_tree().call_group("boardController", "setState",1)


func _on_exit_pressed() -> void:
	# if the menu is the main menu version, exit quits the games
	if menuVersion == 1:
		# data doesn't need saved on main menu, so just exits
		get_tree().quit(0)
	else:
		# return to main menu
		playerNode.saveData()
		get_tree().change_scene_to_file(mainMenuScenePath)


func _on_resume_pressed() -> void:
	# hide menu and set game back to move
	$Menu.visible = false
	get_tree().call_group("boardController", "setState",1)
