# Steamboat Willie Animation Setup Guide

## The sprites are ready! Here's how to configure them in Godot:

### 1. Open Godot and Load Project
```bash
# If Godot is installed, you can open the project directly:
cd /home/habibitron/my-project/GAME1
godot project.godot
```

### 2. Import Animation Frames

#### Step A: Open the SpriteFrames Resource
1. In Godot's FileSystem dock, navigate to `res://sprites/`
2. Double-click `steamboat_willie_simple.tres`
3. This opens the SpriteFrames editor at the bottom

#### Step B: Configure Each Animation

**For IDLE Animation:**
1. Select "idle" in the animation list
2. Click "Add frames from sheet" or the folder icon
3. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Idle/`
4. Select all Idle frames (Idle 00.png through Idle 18.png) - use Ctrl+A
5. Click "Open" - all 19 frames will be added
6. Set Speed to 8.0 FPS

**For RUN Animation:**
1. Select "run" in the animation list  
2. Click "Add frames from sheet"
3. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Run/`
4. Select all Run frames (Run 00.png through Run 12.png)
5. Click "Open" - all 13 frames will be added
6. Set Speed to 12.0 FPS

**For JUMP Animation:**
1. Select "jump" in the animation list
2. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Jump/`
3. Select all Jump frames (Jump 00.png through Jump 16.png)
4. Add them and set Speed to 10.0 FPS

**For HIT Animation:**
1. Select "hit" in the animation list
2. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Hit/`
3. Select all Hit frames (Hit 00.png through Hit 11.png)
4. Add them and set Speed to 15.0 FPS

**For KICK Animation:**
1. Select "kick" in the animation list
2. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Kick/`
3. Select all Kick frames (Kick 00.png through Kick 13.png)
4. Add them and set Speed to 15.0 FPS

**For HURT Animation:**
1. Select "hurt" in the animation list
2. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Hurt/`
3. Select all Hurt frames (Hurt 00.png through Hurt 05.png)
4. Add them and set Speed to 10.0 FPS

**For ROLL Animation:**
1. Select "roll" in the animation list
2. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Roll/`
3. Select all Roll frames (Roll 00.png through Roll 11.png)
4. Add them and set Speed to 12.0 FPS

**For DIE Animation:**
1. Select "die" in the animation list
2. Navigate to `res://sprites/Steamboat Willie Mouse File Pack Full/Die/`
3. Select all Die frames (Die 00.png through Die 12.png)
4. Add them and set Speed to 8.0 FPS

### 3. Save and Test
1. Save the SpriteFrames resource (Ctrl+S)
2. Open `res://scenes/player.tscn`
3. Select the AnimatedSprite2D node
4. In Inspector, verify:
   - Sprite Frames: `res://sprites/steamboat_willie_simple.tres`
   - Animation: "idle"
5. Press F5 to run the game and test!

### 4. Current Animation System
The player script currently uses:
- **"idle"** - when not moving (19 frames)
- **"run"** - when moving (13 frames) 
- **Horizontal flip** - for left/right direction

### 5. Available for Future Features
You now have these animations ready:
- **"jump"** - 17 frames
- **"hit"** - 12 frames  
- **"kick"** - 14 frames
- **"hurt"** - 6 frames
- **"roll"** - 12 frames
- **"die"** - 13 frames

### 6. Animation Frame Counts
- Idle: 19 frames (Idle 00-18)
- Run: 13 frames (Run 00-12)
- Jump: 17 frames (Jump 00-16)
- Hit: 12 frames (Hit 00-11)
- Kick: 14 frames (Kick 00-13)
- Hurt: 6 frames (Hurt 00-05)
- Roll: 12 frames (Roll 00-11)
- Die: 13 frames (Die 00-12)

### 7. Tips
- Use "Loop" enabled for idle, run animations
- Use "Loop" disabled for action animations (jump, hit, kick, hurt, roll, die)
- Adjust FPS speeds to match desired animation feel
- The character will automatically face left/right based on movement direction

## You're all set! Your Steamboat Willie character is ready to animate! 🎮