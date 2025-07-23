# scripts/world.gd
extends Node2D

@onready var background_image = $BackgroundImage
var world_bounds: Rect2

func _ready():
	add_to_group("world")
	calculate_world_bounds()

func calculate_world_bounds():
	if background_image and background_image.texture:
		var texture_size = background_image.texture.get_size()
		var sprite_scale = background_image.scale
		
		# Calculate actual world bounds based on image size
		var half_width = texture_size.x * sprite_scale.x / 2
		var half_height = texture_size.y * sprite_scale.y / 2
		
		world_bounds = Rect2(
			Vector2(-half_width, -half_height),
			Vector2(texture_size.x * sprite_scale.x, texture_size.y * sprite_scale.y)
		)
		
		print("World bounds set to: ", world_bounds)

func get_world_bounds() -> Rect2:
	return world_bounds

func is_position_in_bounds(pos: Vector2) -> bool:
	return world_bounds.has_point(pos)