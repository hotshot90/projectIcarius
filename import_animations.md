# Importing Steamboat Willie Animations

## After downloading the sprite pack:

### 1. Extract and Copy Files
```bash
# Extract the downloaded ZIP to a temporary location
# Then copy animation folders to:
cp -r /path/to/extracted/animations/* /home/habibitron/my-project/GAME1/sprites/steamboat_willie/
```

### 2. Expected Directory Structure
```
sprites/steamboat_willie/
├── idle/
│   ├── frame_001.png
│   ├── frame_002.png
│   └── ...
├── run/
│   ├── frame_001.png
│   ├── frame_002.png
│   └── ...
├── jump/
├── hit_attack/
├── kick_attack/
├── hurt/
├── roll/
└── die/
```

### 3. Import in Godot
1. Open Godot and load the project
2. In the FileSystem dock, navigate to `res://sprites/steamboat_willie/`
3. For each animation folder:
   - Select all PNG files in the folder
   - In the Import tab, set:
     - Import As: "Texture2D"
     - Filter: On
   - Click "Reimport"

### 4. Create Animation Frames
1. Open `res://sprites/steamboat_willie_animations.tres`
2. In the AnimationFrames editor:
   - Select "idle" animation
   - Click "Add frames from sheet" or "Add frame"
   - Add all idle frames in sequence
   - Repeat for each animation (run, jump, etc.)

### 5. Update Player Scene
1. Open `res://scenes/player.tscn`
2. Select the AnimatedSprite2D node
3. In the Inspector, set:
   - Sprite Frames: `res://sprites/steamboat_willie_animations.tres`
   - Animation: "idle"

### 6. Animation Mapping
The script currently uses:
- **"idle"** - when player is not moving
- **"run"** - when player is moving
- **Horizontal flip** - for left/right direction

You can extend this to use:
- "jump" for special movement
- "hurt" when taking damage
- "die" for game over
- "hit_attack"/"kick_attack" for combat

### 7. Test
Press F5 to run and test the animations!