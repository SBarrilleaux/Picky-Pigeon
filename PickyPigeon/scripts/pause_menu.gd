# Manages the pause and exit level / game menu
# Manages game volume
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
	$SettingsButton.visible = true
	
	if menuVersion == null:
		menuVersion = 0

	playerNode = get_tree().get_first_node_in_group("playerDataGroup")
	boardManagerNode = get_tree().get_nodes_in_group("boardController")
	# Set slider displays
	musicVolumeDisplay.value = playerNode.getSetting("soundMusic")
	effectsVolumeDisplay.value = playerNode.getSetting("soundEffect")
	
	if musicVolumeDisplay.value == null:
		musicVolumeDisplay.value = musicVolumeDisplay.max_value
	if effectsVolumeDisplay.value == null:
		effectsVolumeDisplay.value = effectsVolumeDisplay.max_value
	
	get_tree().set_group("soundMusic", "volume_db", 0)
	# Set all related groups to have the correct volume on start
	fade(musicVolumeDisplay.value,"soundMusic")
	get_tree().set_group("soundEffect", "volume_db", effectsVolumeDisplay.value)
	if musicVolumeSlider.value == 0:
		get_tree().call_group("soundMusic", "set_volume_db", -1000)
	if effectsVolumeSlider.value == 0:
		get_tree().call_group("soundEffect", "set_volume_db", -1000)
# Fades in or out audio
func fade(value, groupName):
	var tween: Tween = create_tween()
	tween.finished.connect(on_tween_finished)
	for i in get_tree().get_nodes_in_group(groupName):
		tween.tween_property(i,"volume_db",value, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
func on_tween_finished():
	musicVolumeSlider.value =	musicVolumeDisplay.value
	effectsVolumeSlider.value = effectsVolumeDisplay.value
	if musicVolumeSlider.value == 0:
		get_tree().call_group("soundMusic", "set_volume_db", -1000)
	if effectsVolumeSlider.value == 0:
		get_tree().call_group("soundEffect", "set_volume_db", -1000)
		
func _on_music_value_slider_value_changed(value: float) -> void:
	# change visual slider bar
	musicVolumeDisplay.value = value
	# save value and update sounds
	playerNode.updateSetting("soundMusic", "volume_db", value)

func _on_effects_value_slider_value_changed(value: float) -> void:
	# change visual slider bar
	effectsVolumeDisplay.value = effectsVolumeSlider.value
	# save value and update sounds
	playerNode.updateSetting("soundEffect","volume_db",value)
	
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
		fade(musicVolumeSlider.value/2, "soundMusic")
		await get_tree().create_timer(.2).timeout
		# return to main menu
		playerNode.saveData()
		get_tree().change_scene_to_file(mainMenuScenePath)


func _on_resume_pressed() -> void:
	# hide menu and set game back to move
	$Menu.visible = false
	get_tree().call_group("boardController", "setState",1)
