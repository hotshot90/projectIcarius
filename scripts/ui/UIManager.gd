class_name UIManager
extends CanvasLayer

## Centralized UI management with consistent theming and layering
## Handles all UI interactions and state management

signal ui_opened(ui_name: String)
signal ui_closed(ui_name: String)

enum UILayer {
	BACKGROUND = 0,
	GAME_HUD = 1,
	MENUS = 2,
	OVERLAYS = 3,
	NOTIFICATIONS = 4
}

# UI Theme Configuration
const UI_THEME = {
	"colors": {
		"primary_bg": Color(0.1, 0.1, 0.15, 0.95),
		"secondary_bg": Color(0.15, 0.15, 0.2, 1.0),
		"border": Color(0.7, 0.7, 0.9, 1.0),
		"text_primary": Color(0.9, 0.9, 1.0, 1.0),
		"text_secondary": Color(0.7, 0.7, 0.8, 1.0),
		"text_accent": Color(1.0, 0.9, 0.4, 1.0),
		"button_normal": Color(0.2, 0.2, 0.3, 1.0),
		"button_hover": Color(0.3, 0.3, 0.4, 1.0),
		"success": Color(0.4, 1.0, 0.4, 1.0),
		"warning": Color(1.0, 0.8, 0.4, 1.0),
		"danger": Color(1.0, 0.6, 0.6, 1.0)
	},
	"margins": {
		"small": 4,
		"medium": 8,
		"large": 12,
		"xlarge": 16
	},
	"font_sizes": {
		"small": 10,
		"normal": 12,
		"medium": 14,
		"large": 16,
		"xlarge": 20,
		"title": 24
	}
}

# UI Containers by layer
var ui_containers: Dictionary = {}
var active_uis: Dictionary = {}

# Preloaded UI scenes
var ui_scenes: Dictionary = {
	"main_menu": preload("res://scenes/ui/MainMenu.tscn"),
	"pause_menu": preload("res://scenes/ui/PauseMenu.tscn"),
	"game_hud": preload("res://scenes/ui/GameHUD.tscn"),
	"inventory": preload("res://scenes/ui/Inventory.tscn"),
	"info_panel": preload("res://scenes/ui/InfoPanel.tscn"),
	"minimap": preload("res://scenes/ui/Minimap.tscn")
}

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_setup_ui_layers()
	_connect_game_manager()

func _setup_ui_layers() -> void:
	# Create containers for each UI layer
	for layer_name in UILayer:
		var layer_value = UILayer[layer_name]
		var container = Control.new()
		container.name = layer_name.capitalize() + "Layer"
		container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(container)
		ui_containers[layer_value] = container
		container.z_index = layer_value

func _connect_game_manager() -> void:
	var game_manager = GameManager.new()
	if game_manager:
		game_manager.game_state_changed.connect(_on_game_state_changed)
		game_manager.game_paused.connect(_on_game_paused)
		game_manager.game_resumed.connect(_on_game_resumed)

func show_ui(ui_name: String, layer: UILayer = UILayer.MENUS, data: Dictionary = {}) -> Node:
	if active_uis.has(ui_name):
		# UI already active, just bring to front
		var ui_node = active_uis[ui_name]
		ui_node.get_parent().move_child(ui_node, -1)
		return ui_node
	
	if not ui_scenes.has(ui_name):
		push_error("UI scene not found: " + ui_name)
		return null
	
	var ui_scene = ui_scenes[ui_name].instantiate()
	var container = ui_containers[layer]
	container.add_child(ui_scene)
	active_uis[ui_name] = ui_scene
	
	# Apply theme if UI supports it
	if ui_scene.has_method("apply_theme"):
		ui_scene.apply_theme(UI_THEME)
	
	# Pass initialization data
	if ui_scene.has_method("initialize") and not data.is_empty():
		ui_scene.initialize(data)
	
	ui_opened.emit(ui_name)
	return ui_scene

func hide_ui(ui_name: String) -> void:
	if active_uis.has(ui_name):
		var ui_node = active_uis[ui_name]
		ui_node.queue_free()
		active_uis.erase(ui_name)
		ui_closed.emit(ui_name)

func is_ui_active(ui_name: String) -> bool:
	return active_uis.has(ui_name)

func get_active_ui(ui_name: String) -> Node:
	return active_uis.get(ui_name, null)

func clear_layer(layer: UILayer) -> void:
	var container = ui_containers[layer]
	for child in container.get_children():
		var ui_name = ""
		for name in active_uis.keys():
			if active_uis[name] == child:
				ui_name = name
				break
		if ui_name != "":
			hide_ui(ui_name)

func apply_theme_to_control(control: Control, theme_path: String = "") -> void:
	if not control:
		return
	
	var theme_data = UI_THEME
	if theme_path != "":
		theme_data = _get_nested_theme_data(theme_path)
	
	# Apply colors if control supports them
	if control.has_theme_color_override("font_color"):
		control.add_theme_color_override("font_color", theme_data.get("text_primary", Color.WHITE))

func _get_nested_theme_data(path: String) -> Dictionary:
	var parts = path.split(".")
	var current = UI_THEME
	for part in parts:
		if current.has(part):
			current = current[part]
		else:
			return {}
	return current

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.MENU:
			clear_layer(UILayer.GAME_HUD)
			clear_layer(UILayer.MENUS)
			show_ui("main_menu", UILayer.MENUS)
		GameManager.GameState.PLAYING:
			clear_layer(UILayer.MENUS)
			show_ui("game_hud", UILayer.GAME_HUD)
			show_ui("minimap", UILayer.GAME_HUD)
			show_ui("info_panel", UILayer.GAME_HUD)
		GameManager.GameState.PAUSED:
			show_ui("pause_menu", UILayer.OVERLAYS)

func _on_game_paused() -> void:
	show_ui("pause_menu", UILayer.OVERLAYS)

func _on_game_resumed() -> void:
	hide_ui("pause_menu")