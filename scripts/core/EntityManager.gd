class_name EntityManager
extends Node

## Entity Component System for managing buildings, characters, and interactive objects
## Optimized for handling many entities efficiently

signal entity_created(entity_id: String, entity: BaseEntity)
signal entity_destroyed(entity_id: String)
signal entity_selected(entity_id: String, entity: BaseEntity)

# Entity storage and management
var entities: Dictionary = {}
var entities_by_type: Dictionary = {}
var entities_by_group: Dictionary = {}

# Spatial optimization for large numbers of entities
var spatial_grid: SpatialGrid
var grid_cell_size: int = 128

# Entity pools for performance
var entity_pools: Dictionary = {}

# Entity prefabs
var entity_prefabs: Dictionary = {
	"player": preload("res://scenes/entities/Player.tscn"),
	"base": preload("res://scenes/entities/Base.tscn"),
	"resource_node": preload("res://scenes/entities/ResourceNode.tscn")
}

func _ready() -> void:
	spatial_grid = SpatialGrid.new()
	spatial_grid.initialize(grid_cell_size)
	add_child(spatial_grid)

func create_entity(entity_type: String, position: Vector2, data: Dictionary = {}) -> BaseEntity:
	if not entity_prefabs.has(entity_type):
		push_error("Entity prefab not found: " + entity_type)
		return null
	
	var entity: BaseEntity
	
	# Try to get from pool first
	if _has_pooled_entity(entity_type):
		entity = _get_pooled_entity(entity_type)
		entity.reset_entity()
	else:
		entity = entity_prefabs[entity_type].instantiate()
	
	# Generate unique ID
	var entity_id = _generate_entity_id(entity_type)
	entity.entity_id = entity_id
	entity.entity_type = entity_type
	entity.global_position = position
	
	# Initialize entity with data
	if entity.has_method("initialize"):
		entity.initialize(data)
	
	# Add to world
	get_tree().current_scene.add_child(entity)
	
	# Register entity
	_register_entity(entity)
	
	entity_created.emit(entity_id, entity)
	return entity

func destroy_entity(entity_id: String) -> void:
	var entity = get_entity(entity_id)
	if not entity:
		return
	
	# Unregister entity
	_unregister_entity(entity)
	
	# Return to pool or destroy
	if _should_pool_entity(entity):
		_return_to_pool(entity)
	else:
		entity.queue_free()
	
	entity_destroyed.emit(entity_id)

func get_entity(entity_id: String) -> BaseEntity:
	return entities.get(entity_id, null)

func get_entities_by_type(entity_type: String) -> Array[BaseEntity]:
	return entities_by_type.get(entity_type, [])

func get_entities_by_group(group_name: String) -> Array[BaseEntity]:
	return entities_by_group.get(group_name, [])

func get_entities_in_radius(center: Vector2, radius: float) -> Array[BaseEntity]:
	return spatial_grid.get_entities_in_radius(center, radius)

func get_entities_in_area(area: Rect2) -> Array[BaseEntity]:
	return spatial_grid.get_entities_in_area(area)

func select_entity(entity_id: String) -> void:
	var entity = get_entity(entity_id)
	if entity:
		entity_selected.emit(entity_id, entity)

func clear_all_entities() -> void:
	for entity_id in entities.keys():
		destroy_entity(entity_id)

func _register_entity(entity: BaseEntity) -> void:
	var entity_id = entity.entity_id
	var entity_type = entity.entity_type
	
	# Add to main registry
	entities[entity_id] = entity
	
	# Add to type registry
	if not entities_by_type.has(entity_type):
		entities_by_type[entity_type] = []
	entities_by_type[entity_type].append(entity)
	
	# Add to group registries
	for group in entity.get_groups():
		if not entities_by_group.has(group):
			entities_by_group[group] = []
		entities_by_group[group].append(entity)
	
	# Add to spatial grid
	spatial_grid.add_entity(entity)
	
	# Connect entity signals
	if entity.has_signal("position_changed"):
		entity.position_changed.connect(_on_entity_position_changed)
	if entity.has_signal("destroyed"):
		entity.destroyed.connect(_on_entity_destroyed)

func _unregister_entity(entity: BaseEntity) -> void:
	var entity_id = entity.entity_id
	var entity_type = entity.entity_type
	
	# Remove from main registry
	entities.erase(entity_id)
	
	# Remove from type registry
	if entities_by_type.has(entity_type):
		entities_by_type[entity_type].erase(entity)
	
	# Remove from group registries
	for group in entity.get_groups():
		if entities_by_group.has(group):
			entities_by_group[group].erase(entity)
	
	# Remove from spatial grid
	spatial_grid.remove_entity(entity)
	
	# Disconnect signals
	if entity.has_signal("position_changed"):
		entity.position_changed.disconnect(_on_entity_position_changed)
	if entity.has_signal("destroyed"):
		entity.destroyed.disconnect(_on_entity_destroyed)

func _generate_entity_id(entity_type: String) -> String:
	return entity_type + "_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

func _has_pooled_entity(entity_type: String) -> bool:
	return entity_pools.has(entity_type) and entity_pools[entity_type].size() > 0

func _get_pooled_entity(entity_type: String) -> BaseEntity:
	if not _has_pooled_entity(entity_type):
		return null
	return entity_pools[entity_type].pop_back()

func _return_to_pool(entity: BaseEntity) -> void:
	var entity_type = entity.entity_type
	if not entity_pools.has(entity_type):
		entity_pools[entity_type] = []
	
	entity.get_parent().remove_child(entity)
	entity_pools[entity_type].append(entity)

func _should_pool_entity(entity: BaseEntity) -> bool:
	# Pool certain types of entities for performance
	return entity.entity_type in ["projectile", "particle", "pickup"]

func _on_entity_position_changed(entity: BaseEntity, old_position: Vector2, new_position: Vector2) -> void:
	spatial_grid.update_entity_position(entity, old_position, new_position)

func _on_entity_destroyed(entity: BaseEntity) -> void:
	destroy_entity(entity.entity_id)