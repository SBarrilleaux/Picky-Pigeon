extends Control

var itemButton: Button
@export var itemType: String
@export var itemCost: int
# Get a reference to the board manager / grid in a level scene to figure out the game state
@export var gameManager: Node2D
var uses: int
var lastState: bool = false
# references for purchasing more items uses
var purchaseMenu
var costText: Label
# Subtracts from item uses, and then updates text to reflect the change.
func setUse(value: int):
	
	uses -= abs(value)
	updateText()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	itemButton = $ItemButton
	purchaseMenu = $buyItemMenu
	costText = $buyItemMenu/OutOfItemText/CostText
	purchaseMenu.visible = false
	costText.text = "Buy for " + str(itemCost) + " Coins?"
	# Button data should have been loaded from the PlayerData node.

# Triggers whenver button is pressed
func _on_item_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if gameManager != null:
			# make sure that the game is in the move state when the item is used, and that item still has used
			if gameManager.getState() == 1  && uses > 0:
				gameManager.itemMouseInput(itemType)
				updateText()
			# Let player buy another item if they are out of the item
			elif gameManager.state == 1 && uses == 0:
				purchaseMenu.visible = true
			else:
				itemButton.button_pressed = false

func updateText():
	itemButton.text = "\n" + str(uses)

# Saves the button info and sends it as a string, so that it can be stored in file then loaded into dictionary.
func saveButton() -> String:
	var buttonData: String
	buttonData = itemType + ":" + str(uses)
		#saveFile.store_line(str(playerSaveStats.keys()[i],":",playerSaveStats.values()[i],"\r").replace(" ",""))
	return buttonData
# Loads data from the dictionary, based on the itemType name as the key it is looking for
func loadButton(data: Dictionary[String, int]):
	if data.has(itemType):
		uses = data[itemType]
	else:
		print("no such item saved:")
		uses = 1
	updateText()

# Handles purchasing item uses and calls both board manager and playerData.
func _on_buy_button_pressed() -> void:
	if get_tree().has_group("playerDataGroup"):
		var playerDataNode = get_tree().get_nodes_in_group("playerDataGroup")
		if playerDataNode[0].useCoins(itemCost):
			uses += 1
			updateText()
			if %Grid != null:
				%Grid.updateMenus()
			$ItemButton.button_pressed = false
	purchaseMenu.visible = false


func _on_cancel_button_pressed() -> void:
	purchaseMenu.visible = false
