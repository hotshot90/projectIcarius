class_name SceneManager
extends Node

## Handles scene transitions and management
## Provides smooth transitions and proper cleanup

signal scene_changing(from_scene: String, to_scene: String)
signal scene_changed(scene_name: String)

var current_scene_name: String = ""
var is_transitioning: bool = false

# Scene registry
var scenes: Dictionary = {
	"main_menu": "res://scenes/MainMenu.tscn",
	"game": "res://scenes/Game.tscn"
}

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	# Get the current scene name
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene_name = current_scene.scene_file_path.get_file().get_basename()

func change_scene(scene_name: String, transition_data: Dictionary = {}) -> void:
	if is_transitioning or scene_name == current_scene_name:
		return
	
	if not scenes.has(scene_name):
		push_error("Scene not registered: " + scene_name)
		return
	
	is_transitioning = true
	var old_scene_name = current_scene_name
	
	scene_changing.emit(old_scene_name, scene_name)
	
	# Clean up current scene
	_cleanup_current_scene()
	
	# Load new scene
	var scene_path = scenes[scene_name]
	var result = get_tree().change_scene_to_file(scene_path)
	
	if result == OK:
		current_scene_name = scene_name
		scene_changed.emit(scene_name)
		
		# Update game state based on scene
		var game_manager = get_node("/root/GameManager") as GameManager
		if game_manager:
			match scene_name:
				"main_menu":
					game_manager.change_game_state(GameManager.GameState.MENU)
				"game":
					game_manager.change_game_state(GameManager.GameState.PLAYING)
	else:
		push_error("Failed to change scene to: " + scene_name)
	
	is_transitioning = false

func reload_current_scene() -> void:
	if current_scene_name != "":
		change_scene(current_scene_name)

func register_scene(scene_name: String, scene_path: String) -> void:
	scenes[scene_name] = scene_path

func _cleanup_current_scene() -> void:
	# Clean up any global references or persistent data
	var entity_manager = get_node("/root/EntityManager") as EntityManager
	if entity_manager:
		entity_manager.clear_all_entities()
	
	# Clear UI
	var ui_manager = get_node("/root/UIManager") as UIManager
	if ui_manager:
		ui_manager.clear_layer(UIManager.UILayer.GAME_HUD)