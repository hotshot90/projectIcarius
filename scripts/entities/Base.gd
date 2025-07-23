class_name Base
extends Node2D

## Base building entity - player's main structure
## Shows basic information when clicked

signal selected(base: Base)
signal interacted(base: Base, interactor: Node2D)

@export var entity_id: String = ""
@export var display_name: String = "Main Base"
@export var description: String = "Your primary base of operations."

var interaction_area: Area2D
var is_selected: bool = false

func _ready() -> void:
	add_to_group("entities")
	add_to_group("buildings")
	add_to_group("bases")
	
	entity_id = "base_" + str(get_instance_id())
	_setup_interaction_area()

func _setup_interaction_area() -> void:
	interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(150, 120)  # Large clickable area
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, -10)
	interaction_area.add_child(collision_shape)
	
	interaction_area.input_event.connect(_on_interaction_area_input_event)
	interaction_area.mouse_entered.connect(_on_mouse_entered)
	interaction_area.mouse_exited.connect(_on_mouse_exited)

func _on_interaction_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()
		get_viewport().set_input_as_handled()

func _handle_click() -> void:
	print("Base clicked!")
	_show_info_panel()
	selected.emit(self)

func _show_info_panel() -> void:
	# Show info using the old info manager system for compatibility
	var info_manager = get_tree().get_first_node_in_group("info_manager")
	if info_manager and info_manager.has_method("show_element_info"):
		info_manager.show_element_info(self, display_name, description)
	else:
		print("Info manager not found - using fallback")
		print("Base Info: ", display_name, " - ", description)

func _on_mouse_entered() -> void:
	# Show hover effect
	modulate = Color(1.1, 1.1, 1.1)

func _on_mouse_exited() -> void:
	# Remove hover effect
	modulate = Color.WHITE

func select() -> void:
	is_selected = true
	modulate = Color(1.2, 1.2, 1.2)

func deselect() -> void:
	is_selected = false
	modulate = Color.WHITE
