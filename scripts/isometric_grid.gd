extends Node2D

# Grid settings
const GRID_WIDTH = 40
const GRID_HEIGHT = 30
const TILE_WIDTH = 64
const TILE_HEIGHT = 32

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
var terrain_grid: Array[Array] = []

func _ready():
	setup_noise()
	generate_terrain()
	queue_redraw()

func setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

func generate_terrain():
	terrain_grid.clear()
	terrain_grid.resize(GRID_HEIGHT)
	
	for y in range(GRID_HEIGHT):
		terrain_grid[y] = []
		terrain_grid[y].resize(GRID_WIDTH)
		
		for x in range(GRID_WIDTH):
			var noise_value = noise.get_noise_2d(x, y)
			# Convert noise from -1,1 to 0,1 range
			var terrain_type = (noise_value + 1.0) / 2.0
			terrain_grid[y][x] = terrain_type

func _draw():
	draw_isometric_grid()

func draw_isometric_grid():
	var start_x = -GRID_WIDTH * TILE_WIDTH / 4
	var start_y = -GRID_HEIGHT * TILE_HEIGHT / 2
	
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var iso_pos = cartesian_to_isometric(x, y)
			iso_pos.x += start_x
			iso_pos.y += start_y
			
			# Get terrain color based on noise value
			var terrain_value = terrain_grid[y][x]
			var tile_color = get_terrain_color(terrain_value)
			
			# Draw diamond-shaped tile
			draw_isometric_tile(iso_pos, tile_color)
			
			# Draw grid lines (optional, for debugging)
			draw_tile_outline(iso_pos)

func cartesian_to_isometric(cart_x: int, cart_y: int) -> Vector2:
	var iso_x = (cart_x - cart_y) * (TILE_WIDTH / 2)
	var iso_y = (cart_x + cart_y) * (TILE_HEIGHT / 2)
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

func draw_isometric_tile(position: Vector2, color: Color):
	var points = PackedVector2Array()
	
	# Diamond shape points for isometric tile
	points.append(Vector2(position.x, position.y - TILE_HEIGHT / 2))  # Top
	points.append(Vector2(position.x + TILE_WIDTH / 2, position.y))   # Right
	points.append(Vector2(position.x, position.y + TILE_HEIGHT / 2))  # Bottom
	points.append(Vector2(position.x - TILE_WIDTH / 2, position.y))   # Left
	
	# Fill the diamond
	draw_colored_polygon(points, color)

func draw_tile_outline(position: Vector2):
	var outline_color = Color(0.2, 0.2, 0.2, 0.3)  # Semi-transparent dark gray
	var points = PackedVector2Array()
	
	points.append(Vector2(position.x, position.y - TILE_HEIGHT / 2))  # Top
	points.append(Vector2(position.x + TILE_WIDTH / 2, position.y))   # Right
	points.append(Vector2(position.x, position.y + TILE_HEIGHT / 2))  # Bottom
	points.append(Vector2(position.x - TILE_WIDTH / 2, position.y))   # Left
	points.append(Vector2(position.x, position.y - TILE_HEIGHT / 2))  # Back to top
	
	# Draw outline
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], outline_color, 1.0)

# Get grid coordinates from world position
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var start_x = -GRID_WIDTH * TILE_WIDTH / 4
	var start_y = -GRID_HEIGHT * TILE_HEIGHT / 2
	
	var local_pos = world_pos - Vector2(start_x, start_y)
	
	# Convert from isometric back to cartesian
	var cart_x = (local_pos.x / (TILE_WIDTH / 2) + local_pos.y / (TILE_HEIGHT / 2)) / 2
	var cart_y = (local_pos.y / (TILE_HEIGHT / 2) - local_pos.x / (TILE_WIDTH / 2)) / 2
	
	return Vector2i(int(cart_x), int(cart_y))

# Get world position from grid coordinates
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var start_x = -GRID_WIDTH * TILE_WIDTH / 4
	var start_y = -GRID_HEIGHT * TILE_HEIGHT / 2
	
	var iso_pos = cartesian_to_isometric(grid_pos.x, grid_pos.y)
	return Vector2(iso_pos.x + start_x, iso_pos.y + start_y)

# Check if grid position is valid
func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT