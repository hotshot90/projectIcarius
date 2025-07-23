class_name GameManager
extends Node

## Central game manager handling global state and coordination between systems
## Singleton pattern for global access

signal game_paused
signal game_resumed
signal game_state_changed(new_state: GameState)

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
var is_paused: bool = false

# Manager references - lazy loaded
var _ui_manager: UIManager
var _scene_manager: SceneManager
var _entity_manager: EntityManager
var _input_manager: InputManager

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	process_priority = 100  # High priority for manager

func _get_ui_manager() -> UIManager:
	if not _ui_manager:
		_ui_manager = get_node("/root/UIManager") as UIManager
	return _ui_manager

func _get_scene_manager() -> SceneManager:
	if not _scene_manager:
		_scene_manager = get_node("/root/SceneManager") as SceneManager
	return _scene_manager

func _get_entity_manager() -> EntityManager:
	if not _entity_manager:
		_entity_manager = get_node("/root/EntityManager") as EntityManager
	return _entity_manager

func _get_input_manager() -> InputManager:
	if not _input_manager:
		_input_manager = get_node("/root/InputManager") as InputManager
	return _input_manager

func change_game_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	var old_state = current_state
	current_state = new_state
	
	match new_state:
		GameState.MENU:
			_handle_menu_state()
		GameState.PLAYING:
			_handle_playing_state()
		GameState.PAUSED:
			_handle_paused_state()
		GameState.GAME_OVER:
			_handle_game_over_state()
	
	game_state_changed.emit(new_state)
	print("Game state changed: ", GameState.keys()[old_state], " -> ", GameState.keys()[new_state])

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		change_game_state(GameState.PAUSED)
	elif current_state == GameState.PAUSED:
		change_game_state(GameState.PLAYING)

func _handle_menu_state() -> void:
	get_tree().paused = false
	is_paused = false

func _handle_playing_state() -> void:
	get_tree().paused = false
	is_paused = false
	game_resumed.emit()

func _handle_paused_state() -> void:
	get_tree().paused = true
	is_paused = true
	game_paused.emit()

func _handle_game_over_state() -> void:
	get_tree().paused = true
	is_paused = true

# Global access methods
func get_ui_manager() -> UIManager:
	return _get_ui_manager()

func get_scene_manager() -> SceneManager:
	return _get_scene_manager()

func get_entity_manager() -> EntityManager:
	return _get_entity_manager()

func get_input_manager() -> InputManager:
	return _get_input_manager()