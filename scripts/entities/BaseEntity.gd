class_name BaseEntity
extends Node2D

## Base class for all game entities (buildings, characters, resources)
## Provides common functionality and component system

signal position_changed(entity: BaseEntity, old_position: Vector2, new_position: Vector2)
signal destroyed(entity: BaseEntity)
signal selected(entity: BaseEntity)
signal interacted(entity: BaseEntity, interactor: BaseEntity)

@export var entity_id: String = ""
@export var entity_type: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var max_health: float = 100.0
@export var selectable: bool = true
@export var interactable: bool = true

var current_health: float
var is_selected: bool = false
var groups: Array[String] = []

# Component system
var components: Dictionary = {}

# Interaction area
var interaction_area: Area2D

func _ready() -> void:
	current_health = max_health
	_setup_interaction_area()
	_initialize_components()
	add_to_group("entities")

func _setup_interaction_area() -> void:
	if not interactable:
		return
	
	interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)
	
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 32.0  # Default interaction radius
	collision_shape.shape = shape
	interaction_area.add_child(collision_shape)
	
	interaction_area.input_event.connect(_on_interaction_area_input_event)
	interaction_area.mouse_entered.connect(_on_mouse_entered)
	interaction_area.mouse_exited.connect(_on_mouse_exited)

func _initialize_components() -> void:
	# Override in derived classes to add specific components
	pass

func initialize(data: Dictionary) -> void:
	# Initialize entity with specific data
	if data.has("display_name"):
		display_name = data["display_name"]
	if data.has("description"):
		description = data["description"]
	if data.has("max_health"):
		max_health = data["max_health"]
		current_health = max_health

func reset_entity() -> void:
	# Reset entity state for pooling
	current_health = max_health
	is_selected = false
	position = Vector2.ZERO

func add_component(component_type: String, component: Node) -> void:
	if components.has(component_type):
		remove_component(component_type)
	
	components[component_type] = component
	add_child(component)

func remove_component(component_type: String) -> void:
	if components.has(component_type):
		var component = components[component_type]
		component.queue_free()
		components.erase(component_type)

func get_component(component_type: String) -> Node:
	return components.get(component_type, null)

func has_component(component_type: String) -> bool:
	return components.has(component_type)

func add_to_entity_group(group_name: String) -> void:
	if group_name not in groups:
		groups.append(group_name)
		add_to_group(group_name)

func remove_from_entity_group(group_name: String) -> void:
	if group_name in groups:
		groups.erase(group_name)
		remove_from_group(group_name)

func get_groups() -> Array[String]:
	return groups

func take_damage(amount: float, source: BaseEntity = null) -> void:
	current_health = max(0, current_health - amount)
	if current_health <= 0:
		die()

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)

func die() -> void:
	destroyed.emit(self)
	queue_free()

func select() -> void:
	if not selectable:
		return
	
	is_selected = true
	_update_selection_visual()
	selected.emit(self)

func deselect() -> void:
	is_selected = false
	_update_selection_visual()

func interact(interactor: BaseEntity) -> void:
	if not interactable:
		return
	
	interacted.emit(self, interactor)
	_handle_interaction(interactor)

func _handle_interaction(interactor: BaseEntity) -> void:
	# Override in derived classes
	pass

func _update_selection_visual() -> void:
	# Override in derived classes to show selection visual
	modulate = Color.WHITE if not is_selected else Color(1.2, 1.2, 1.2)

func _on_interaction_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selectable:
			var entity_manager = get_node("/root/EntityManager") as EntityManager
			if entity_manager:
				entity_manager.select_entity(entity_id)
		
		if interactable:
			var player = get_tree().get_first_node_in_group("player") as BaseEntity
			if player:
				interact(player)

func _on_mouse_entered() -> void:
	# Show hover effect
	if selectable or interactable:
		modulate = Color(1.1, 1.1, 1.1)

func _on_mouse_exited() -> void:
	# Remove hover effect
	_update_selection_visual()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		var old_pos = global_position
		position_changed.emit(self, old_pos, global_position)