class_name Game
extends Node2D

## Main game scene controller
## Initializes the game world and entities

@onready var player = $Player
@onready var base = $Base
@onready var world = $World

func _ready() -> void:
	_initialize_game()

func _initialize_game() -> void:
	# Register entities with the entity manager
	var entity_manager = get_node("/root/EntityManager") as EntityManager
	if entity_manager:
		# The entities will self-register through their BaseEntity._ready() method
		pass
	
	# Set up player reference for other systems
	if player:
		player.add_to_group("player")
	
	# Initialize UI
	var ui_manager = get_node("/root/UIManager") as UIManager
	if ui_manager:
		ui_manager.show_ui("minimap", UIManager.UILayer.GAME_HUD)
		ui_manager.show_ui("info_panel", UIManager.UILayer.GAME_HUD)