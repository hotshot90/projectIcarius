# scripts/world.gd
extends Node2D

@onready var isometric_grid = $IsometricGrid
var world_bounds: Rect2

func _ready():
	add_to_group("world")
	calculate_world_bounds()

func calculate_world_bounds():
	# Calculate world bounds based on grid size
	var grid_width = 400 * 64 / 2.0  # GRID_WIDTH * TILE_WIDTH / 2
	var grid_height = 300 * 32 / 2.0  # GRID_HEIGHT * TILE_HEIGHT / 2
	
	world_bounds = Rect2(
		Vector2(-grid_width, -grid_height),
		Vector2(grid_width * 2, grid_height * 2)
	)
	
	print("World bounds set to: ", world_bounds)

func get_world_bounds() -> Rect2:
	return world_bounds

func is_position_in_bounds(pos: Vector2) -> bool:
	return world_bounds.has_point(pos)

func get_grid() -> Node2D:
	return isometric_grid
