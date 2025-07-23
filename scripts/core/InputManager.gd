class_name InputManager
extends Node

## Centralized input handling with proper priority and context management
## Prevents input conflicts between UI and game

signal input_handled(event: InputEvent, context: String)

enum InputContext {
	MENU,
	GAME,
	UI_OVERLAY,
	PAUSED
}

var current_context: InputContext = InputContext.MENU
var input_stack: Array[InputContext] = []

# Input actions registry
var input_actions: Dictionary = {}

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	set_process_unhandled_input(true)
	_register_default_actions()

func _unhandled_input(event: InputEvent) -> void:
	# Handle input based on current context
	match current_context:
		InputContext.MENU:
			_handle_menu_input(event)
		InputContext.GAME:
			_handle_game_input(event)
		InputContext.UI_OVERLAY:
			_handle_ui_overlay_input(event)
		InputContext.PAUSED:
			_handle_paused_input(event)

func push_context(context: InputContext) -> void:
	input_stack.append(current_context)
	current_context = context

func pop_context() -> void:
	if input_stack.size() > 0:
		current_context = input_stack.pop_back()

func set_context(context: InputContext) -> void:
	current_context = context
	input_stack.clear()

func register_action(action_name: String, callback: Callable, context: InputContext = InputContext.GAME) -> void:
	if not input_actions.has(context):
		input_actions[context] = {}
	input_actions[context][action_name] = callback

func unregister_action(action_name: String, context: InputContext = InputContext.GAME) -> void:
	if input_actions.has(context) and input_actions[context].has(action_name):
		input_actions[context].erase(action_name)

func _register_default_actions() -> void:
	# Register default game actions
	register_action("toggle_pause", _toggle_pause, InputContext.GAME)
	register_action("toggle_pause", _toggle_pause, InputContext.PAUSED)
	register_action("open_inventory", _open_inventory, InputContext.GAME)
	register_action("close_ui", _close_ui, InputContext.UI_OVERLAY)

func _handle_menu_input(event: InputEvent) -> void:
	# Menu input is handled by UI directly
	pass

func _handle_game_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_execute_action("toggle_pause", InputContext.GAME)
				get_viewport().set_input_as_handled()
			KEY_I:
				_execute_action("open_inventory", InputContext.GAME)
				get_viewport().set_input_as_handled()

func _handle_ui_overlay_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_execute_action("close_ui", InputContext.UI_OVERLAY)
				get_viewport().set_input_as_handled()

func _handle_paused_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_execute_action("toggle_pause", InputContext.PAUSED)
				get_viewport().set_input_as_handled()

func _execute_action(action_name: String, context: InputContext) -> void:
	if input_actions.has(context) and input_actions[context].has(action_name):
		var callback = input_actions[context][action_name]
		callback.call()

func _toggle_pause() -> void:
	var game_manager = get_node("/root/GameManager") as GameManager
	if game_manager:
		game_manager.toggle_pause()

func _open_inventory() -> void:
	var ui_manager = get_node("/root/UIManager") as UIManager
	if ui_manager:
		ui_manager.show_ui("inventory", UIManager.UILayer.OVERLAYS)
		push_context(InputContext.UI_OVERLAY)

func _close_ui() -> void:
	var ui_manager = get_node("/root/UIManager") as UIManager
	if ui_manager:
		# Close top-most UI
		ui_manager.hide_ui("inventory")
		pop_context()