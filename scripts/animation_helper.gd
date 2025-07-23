# Helper script for setting up Steamboat Willie animations
# This can be run in Godot's script editor to help setup animations

extends EditorScript

func _run():
	print("Steamboat Willie Animation Helper")
	print("=================================")
	
	# Animation frame counts for reference
	var animations = {
		"idle": {"frames": 19, "speed": 8.0, "loop": true},
		"run": {"frames": 13, "speed": 12.0, "loop": true},
		"jump": {"frames": 17, "speed": 10.0, "loop": false},
		"hit": {"frames": 12, "speed": 15.0, "loop": false},
		"kick": {"frames": 14, "speed": 15.0, "loop": false},
		"hurt": {"frames": 6, "speed": 10.0, "loop": false},
		"roll": {"frames": 12, "speed": 12.0, "loop": false},
		"die": {"frames": 13, "speed": 8.0, "loop": false}
	}
	
	print("\nAnimation Configuration:")
	for anim_name in animations:
		var anim = animations[anim_name]
		print("- %s: %d frames, %.1f FPS, Loop: %s" % [
			anim_name.capitalize(), 
			anim["frames"], 
			anim["speed"], 
			"Yes" if anim["loop"] else "No"
		])
	
	print("\nSprite Folders Available:")
	var base_path = "res://sprites/Steamboat Willie Mouse File Pack Full/"
	var folders = ["Die", "Hit", "Hurt", "Idle", "Jump", "Kick", "Roll", "Run"]
	
	for folder in folders:
		print("- %s%s/" % [base_path, folder])
	
	print("\nTo complete setup:")
	print("1. Open res://sprites/steamboat_willie_simple.tres")
	print("2. For each animation, add frames from corresponding folder")
	print("3. Set speed and loop settings as shown above")
	print("4. Save and test in game!")