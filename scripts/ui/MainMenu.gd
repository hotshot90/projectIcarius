class_name MainMenu
extends Control

## Main menu UI component with proper theming support
## Handles navigation to game and options

func _ready() -> void:
	# Focus first button for keyboard navigation
	var start_button = $CenterContainer/MenuPanel/VBoxContainer/ButtonContainer/StartButton
	if start_button:
		start_button.grab_focus()

func apply_theme(theme_data: Dictionary) -> void:
	var colors = theme_data.get("colors", {})
	var fonts = theme_data.get("font_sizes", {})
	
	# Apply background color
	var background = $Background
	if background and colors.has("primary_bg"):
		background.color = colors["primary_bg"]
	
	# Apply panel styling
	var panel = $CenterContainer/MenuPanel
	if panel and colors.has("secondary_bg"):
		var style = StyleBoxFlat.new()
		style.bg_color = colors["secondary_bg"]
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = colors.get("border", Color.WHITE)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		panel.add_theme_stylebox_override("panel", style)
	
	# Apply text colors and fonts
	_apply_label_theme($CenterContainer/MenuPanel/VBoxContainer/TitleContainer/Title, colors, fonts, "title", "text_primary")
	_apply_label_theme($CenterContainer/MenuPanel/VBoxContainer/TitleContainer/Subtitle, colors, fonts, "medium", "text_secondary")
	
	# Apply button themes
	_apply_button_theme($CenterContainer/MenuPanel/VBoxContainer/ButtonContainer/StartButton, colors, fonts, "success")
	_apply_button_theme($CenterContainer/MenuPanel/VBoxContainer/ButtonContainer/OptionsButton, colors, fonts, "text_primary")
	_apply_button_theme($CenterContainer/MenuPanel/VBoxContainer/ButtonContainer/QuitButton, colors, fonts, "danger")

func _apply_label_theme(label: Label, colors: Dictionary, fonts: Dictionary, font_key: String, color_key: String) -> void:
	if not label:
		return
	
	if colors.has(color_key):
		label.add_theme_color_override("font_color", colors[color_key])
	
	if fonts.has(font_key):
		label.add_theme_font_size_override("font_size", fonts[font_key])

func _apply_button_theme(button: Button, colors: Dictionary, fonts: Dictionary, color_key: String) -> void:
	if not button:
		return
	
	if colors.has(color_key):
		button.add_theme_color_override("font_color", colors[color_key])
	
	if fonts.has("medium"):
		button.add_theme_font_size_override("font_size", fonts["medium"])

func _on_start_pressed() -> void:
	var scene_manager = get_node("/root/SceneManager") as SceneManager
	if scene_manager:
		scene_manager.change_scene("game")

func _on_options_pressed() -> void:
	print("Options not implemented yet")

func _on_quit_pressed() -> void:
	get_tree().quit()