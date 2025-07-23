class_name SpatialGrid
extends Node

## Spatial partitioning system for efficient entity queries
## Optimized for handling hundreds of entities

var cell_size: int = 128
var grid: Dictionary = {}
var entity_to_cell: Dictionary = {}

func initialize(grid_cell_size: int) -> void:
	cell_size = grid_cell_size

func add_entity(entity: BaseEntity) -> void:
	var cell_coord = _world_to_grid(entity.global_position)
	var cell_key = _coord_to_key(cell_coord)
	
	if not grid.has(cell_key):
		grid[cell_key] = []
	
	grid[cell_key].append(entity)
	entity_to_cell[entity] = cell_key

func remove_entity(entity: BaseEntity) -> void:
	if not entity_to_cell.has(entity):
		return
	
	var cell_key = entity_to_cell[entity]
	if grid.has(cell_key):
		grid[cell_key].erase(entity)
		if grid[cell_key].is_empty():
			grid.erase(cell_key)
	
	entity_to_cell.erase(entity)

func update_entity_position(entity: BaseEntity, old_position: Vector2, new_position: Vector2) -> void:
	var old_cell = _world_to_grid(old_position)
	var new_cell = _world_to_grid(new_position)
	
	if old_cell == new_cell:
		return  # Entity didn't change cells
	
	# Remove from old cell
	var old_key = _coord_to_key(old_cell)
	if grid.has(old_key):
		grid[old_key].erase(entity)
		if grid[old_key].is_empty():
			grid.erase(old_key)
	
	# Add to new cell
	var new_key = _coord_to_key(new_cell)
	if not grid.has(new_key):
		grid[new_key] = []
	
	grid[new_key].append(entity)
	entity_to_cell[entity] = new_key

func get_entities_in_radius(center: Vector2, radius: float) -> Array[BaseEntity]:
	var entities: Array[BaseEntity] = []
	var cells_to_check = _get_cells_in_radius(center, radius)
	
	for cell_key in cells_to_check:
		if grid.has(cell_key):
			for entity in grid[cell_key]:
				if center.distance_to(entity.global_position) <= radius:
					entities.append(entity)
	
	return entities

func get_entities_in_area(area: Rect2) -> Array[BaseEntity]:
	var entities: Array[BaseEntity] = []
	var cells_to_check = _get_cells_in_area(area)
	
	for cell_key in cells_to_check:
		if grid.has(cell_key):
			for entity in grid[cell_key]:
				if area.has_point(entity.global_position):
					entities.append(entity)
	
	return entities

func _world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(world_pos.x / cell_size),
		int(world_pos.y / cell_size)
	)

func _coord_to_key(coord: Vector2i) -> String:
	return str(coord.x) + "," + str(coord.y)

func _get_cells_in_radius(center: Vector2, radius: float) -> Array[String]:
	var cells: Array[String] = []
	var center_cell = _world_to_grid(center)
	var cell_radius = int(ceil(radius / cell_size))
	
	for x in range(center_cell.x - cell_radius, center_cell.x + cell_radius + 1):
		for y in range(center_cell.y - cell_radius, center_cell.y + cell_radius + 1):
			cells.append(_coord_to_key(Vector2i(x, y)))
	
	return cells

func _get_cells_in_area(area: Rect2) -> Array[String]:
	var cells: Array[String] = []
	var min_cell = _world_to_grid(area.position)
	var max_cell = _world_to_grid(area.position + area.size)
	
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			cells.append(_coord_to_key(Vector2i(x, y)))
	
	return cells