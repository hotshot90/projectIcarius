extends Node2D

@onready var player = $Player
@onready var info_manager = $InfoManager
@onready var info_panel = $UI/InfoPanel
@onready var info_title = $UI/InfoPanel/InfoBorder/InfoContent/InfoText/Title
@onready var info_description = $UI/InfoPanel/InfoBorder/InfoContent/InfoText/Description
@onready var info_distance = $UI/InfoPanel/InfoBorder/InfoContent/InfoText/Distance

func _ready():
	# Initialize the info manager with UI references
	if info_manager:
		info_manager.initialize_ui(info_title, info_description, info_distance, info_panel)
		info_manager.set_player(player)