class_name InfoPanel
extends Control

## Clean info panel for displaying entity information
## Minimal design with space for future features

@onready var title_label: Label = $Panel/VBox/Title
@onready var description_label: Label = $Panel/VBox/Description
@onready var distance_label: Label = $Panel/VBox/Distance

var current_entity: BaseEntity
var player_node: Node2D
var max_distance: float = 200.0

func _ready() -> void:
	visible = false
	player_node = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if current_entity and player_node and is_instance_valid(current_entity):
		_update_distance()
		
		# Hide if too far away
		var distance = player_node.global_position.distance_to(current_entity.global_position)
		if distance > max_distance:
			hide_info()

func initialize(data: Dictionary) -> void:
	if data.has("title"):
		set_title(data["title"])
	if data.has("description"):
		set_description(data["description"])
	if data.has("entity"):
		set_entity_info(data["entity"])
	
	show_info()

func set_entity_info(entity: BaseEntity) -> void:
	current_entity = entity
	if entity:
		set_title(entity.display_name)
		set_description(entity.description)

func set_title(text: String) -> void:
	if title_label:
		title_label.text = text

func set_description(text: String) -> void:
	if description_label:
		description_label.text = text

func show_info() -> void:
	visible = true

func hide_info() -> void:
	visible = false
	current_entity = null

func apply_theme(theme_data: Dictionary) -> void:
	var colors = theme_data.get("colors", {})
	var fonts = theme_data.get("font_sizes", {})
	
	# Apply panel styling
	var panel = $Panel
	if panel and colors.has("secondary_bg"):
		var style = StyleBoxFlat.new()
		style.bg_color = colors["secondary_bg"]
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = colors.get("border", Color.WHITE)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		panel.add_theme_stylebox_override("panel", style)
	
	# Apply text styling
	if title_label:
		if colors.has("text_accent"):
			title_label.add_theme_color_override("font_color", colors["text_accent"])
		if fonts.has("medium"):
			title_label.add_theme_font_size_override("font_size", fonts["medium"])
	
	if description_label:
		if colors.has("text_primary"):
			description_label.add_theme_color_override("font_color", colors["text_primary"])
		if fonts.has("normal"):
			description_label.add_theme_font_size_override("font_size", fonts["normal"])
	
	if distance_label:
		if colors.has("text_secondary"):
			distance_label.add_theme_color_override("font_color", colors["text_secondary"])
		if fonts.has("small"):
			distance_label.add_theme_font_size_override("font_size", fonts["small"])

func _update_distance() -> void:
	if not current_entity or not player_node or not distance_label:
		return
	
	var distance = player_node.global_position.distance_to(current_entity.global_position)
	distance_label.text = "Distance: %.1f units" % distance