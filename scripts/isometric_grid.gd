extends Node2D

# Grid settings
const GRID_WIDTH = 400
const GRID_HEIGHT = 300
const TILE_WIDTH = 64
const TILE_HEIGHT = 32

# Performance settings
const CHUNK_SIZE = 32  # Draw tiles in chunks for better performance
const MAX_VISIBLE_DISTANCE = 800  # Maximum distance from camera to draw tiles
const REDRAW_THRESHOLD = 200  # Minimum camera movement before redraw (was TILE_WIDTH=64)

# Terrain colors
const GRASS_COLORS = [
	Color(0.4, 0.7, 0.3),  # Light green
	Color(0.3, 0.6, 0.2),  # Medium green
	Color(0.2, 0.5, 0.1),  # Dark green
]

const DESERT_COLORS = [
	Color(0.8, 0.7, 0.4),  # Light sandy brown
	Color(0.7, 0.6, 0.3),  # Medium sandy brown
	Color(0.6, 0.5, 0.2),  # Dark sandy brown
]

# Noise for terrain generation
var noise: FastNoiseLite
var camera_node: Camera2D
var last_camera_position: Vector2
var terrain_cache: Dictionary = {}  # Cache terrain values
var should_redraw: bool = true

func _ready():
	setup_noise()
	# Find camera for viewport culling with proper null checking
	await get_tree().process_frame  # Wait for scene to be fully loaded
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		camera_node = player_node.get_node("Camera2D")
	set_process(true)
	should_redraw = true

func _process(_delta):
	# Only redraw if camera moved significantly (performance optimization)
	if camera_node:
		var current_camera_pos = camera_node.global_position
		if should_redraw or last_camera_position.distance_to(current_camera_pos) > REDRAW_THRESHOLD:
			last_camera_position = current_camera_pos
			should_redraw = false
			# Skip redraw if framerate is low to prevent spiral
			if Engine.get_frames_per_second() > 30:
				queue_redraw()

func setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.05  # Lower frequency for better performance
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

func get_terrain_value(x: int, y: int) -> float:
	# Use cache to avoid recalculating noise
	var key = Vector2i(x, y)
	if key in terrain_cache:
		return terrain_cache[key]
	
	var noise_value = noise.get_noise_2d(x, y)
	var terrain_type = (noise_value + 1.0) / 2.0
	terrain_cache[key] = terrain_type
	return terrain_type

func _draw():
	draw_visible_grid()

func draw_visible_grid():
	var start_x = -GRID_WIDTH * TILE_WIDTH / 4.0
	var start_y = -GRID_HEIGHT * TILE_HEIGHT / 2.0
	
	# Draw a reasonable area around the player/camera
	var center_x = GRID_WIDTH / 2.0
	var center_y = GRID_HEIGHT / 2.0
	var draw_radius = 30  # Draw 30 tiles in each direction from center (reduced for performance)
	
	# If we have a camera, calculate the area around it
	if camera_node:
		var camera_world_pos = camera_node.global_position
		var grid_pos = world_to_grid(camera_world_pos)
		center_x = clamp(grid_pos.x, draw_radius, GRID_WIDTH - draw_radius)
		center_y = clamp(grid_pos.y, draw_radius, GRID_HEIGHT - draw_radius)
	
	var min_x = max(0, center_x - draw_radius)
	var max_x = min(GRID_WIDTH, center_x + draw_radius)
	var min_y = max(0, center_y - draw_radius)
	var max_y = min(GRID_HEIGHT, center_y + draw_radius)
	
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			var iso_pos = cartesian_to_isometric(x, y)
			iso_pos.x += start_x
			iso_pos.y += start_y
			
			# Get terrain color (cached)
			var terrain_value = get_terrain_value(x, y)
			var tile_color = get_terrain_color(terrain_value)
			
			# Draw tile
			draw_isometric_tile(iso_pos, tile_color)

func get_visible_grid_bounds(visible_rect: Rect2, start_x: float, start_y: float) -> Rect2i:
	# Convert visible screen area to approximate grid bounds
	var min_grid_x = int((visible_rect.position.x - start_x) / TILE_WIDTH * 2) - 10
	var max_grid_x = int((visible_rect.end.x - start_x) / TILE_WIDTH * 2) + 10
	var min_grid_y = int((visible_rect.position.y - start_y) / TILE_HEIGHT * 2) - 10
	var max_grid_y = int((visible_rect.end.y - start_y) / TILE_HEIGHT * 2) + 10
	
	return Rect2i(
		min_grid_x,
		min_grid_y,
		max_grid_x - min_grid_x,
		max_grid_y - min_grid_y
	)

func cartesian_to_isometric(cart_x: int, cart_y: int) -> Vector2:
	var iso_x = (cart_x - cart_y) * (TILE_WIDTH / 2.0)
	var iso_y = (cart_x + cart_y) * (TILE_HEIGHT / 2.0)
	return Vector2(iso_x, iso_y)

func get_terrain_color(terrain_value: float) -> Color:
	if terrain_value < 0.4:
		# Desert terrain
		var color_index = int(terrain_value * DESERT_COLORS.size() / 0.4)
		color_index = clamp(color_index, 0, DESERT_COLORS.size() - 1)
		return DESERT_COLORS[color_index]
	else:
		# Grass terrain
		var grass_value = (terrain_value - 0.4) / 0.6
		var color_index = int(grass_value * GRASS_COLORS.size())
		color_index = clamp(color_index, 0, GRASS_COLORS.size() - 1)
		return GRASS_COLORS[color_index]

func draw_isometric_tile(tile_position: Vector2, color: Color):
	var points = PackedVector2Array()
	
	# Diamond shape points for isometric tile
	points.append(Vector2(tile_position.x, tile_position.y - TILE_HEIGHT / 2.0))  # Top
	points.append(Vector2(tile_position.x + TILE_WIDTH / 2.0, tile_position.y))   # Right
	points.append(Vector2(tile_position.x, tile_position.y + TILE_HEIGHT / 2.0))  # Bottom
	points.append(Vector2(tile_position.x - TILE_WIDTH / 2.0, tile_position.y))   # Left
	
	# Fill the diamond
	draw_colored_polygon(points, color)

# Get grid coordinates from world position
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var start_x = -GRID_WIDTH * TILE_WIDTH / 4.0
	var start_y = -GRID_HEIGHT * TILE_HEIGHT / 2.0
	
	var local_pos = world_pos - Vector2(start_x, start_y)
	
	# Convert from isometric back to cartesian
	var cart_x = (local_pos.x / (TILE_WIDTH / 2.0) + local_pos.y / (TILE_HEIGHT / 2.0)) / 2.0
	var cart_y = (local_pos.y / (TILE_HEIGHT / 2.0) - local_pos.x / (TILE_WIDTH / 2.0)) / 2.0
	
	return Vector2i(int(cart_x), int(cart_y))

# Get world position from grid coordinates
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var start_x = -GRID_WIDTH * TILE_WIDTH / 4.0
	var start_y = -GRID_HEIGHT * TILE_HEIGHT / 2.0
	
	var iso_pos = cartesian_to_isometric(grid_pos.x, grid_pos.y)
	return Vector2(iso_pos.x + start_x, iso_pos.y + start_y)

# Check if grid position is valid
func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT
