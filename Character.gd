extends CharacterBody2D


const SPEED = 200.0
const KEY_JUMP_VELOCITY = -400.0
const FRICTION = 0

const KEY_JUMP = "ui_accept"
const KEY_LEFT = "ui_left"
const KEY_RIGHT = "ui_right"

enum {
	JUMP,
	LEFT,
	RIGHT,
}

var inputs_index := 0

var goal: Node2D;

var weights;
var map;
var map_anchor: Vector2;

var frame_counter := 0
var distance : Vector2;
var success := false

# Tracks how long character has stood still
var idle_counter := 0

#Tracks how long character hasn't moved left or right
var horizontal_idle_counter := 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Debug toggle to allow direct input from a user
var enable_input := false

signal close

func _physics_process(delta):
	
	if not success:		
		if not enable_input:
			if eval_layer(weights[0]) > 0:
				jump()
			if eval_layer(weights[1]) > 0: 
				left()
			if eval_layer(weights[2]) > 0: 
				right()
		else:
			if Input.is_action_pressed("ui_accept"):
				jump()
			if Input.is_action_pressed("ui_left"):
				left()
			if Input.is_action_pressed("ui_right"):
				right()
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			
		# Add ground friction
		if is_on_floor():
			if not enable_input or \
				not (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
				velocity.x *= FRICTION
			if abs(velocity.x) < 1.0:
				velocity.x = 0.0
		
		move_and_slide()
		
		if abs(velocity.x) > 0:
			horizontal_idle_counter = 0
		if abs(velocity) > Vector2(0.0, 0.0):
			idle_counter = 0
		
		frame_counter += 1
		idle_counter += 1
		horizontal_idle_counter += 1
		if (idle_counter >= 30 or horizontal_idle_counter >= 120) and not enable_input:
			# print("timeout: idle")
			close.emit("timeout")
		elif frame_counter >= 600 and not enable_input:
			# print("timeout: lifespan")
			close.emit("timeout")
		
		distance = abs(position - goal.position)
		if distance < Vector2(5.0, 5.0):
			success = true
		

func _process(delta):
	pass
	
func _ready():
	pass

func jump():
	if is_on_floor():
		velocity.y = KEY_JUMP_VELOCITY

func left():
	velocity.x += -SPEED / 2
	velocity.x = max(-SPEED, velocity.x)
	
func right():
	velocity.x += SPEED / 2
	velocity.x = min(SPEED, velocity.x)

func eval_layer(layer) -> float:
	var total = 0.0
	var fitted_pos = translate_position_to_map(position, map_anchor)
	var fitted_pos_anchor: Vector2i = fitted_pos - Vector2i(2, 2)
	var offset_y = 0
	var target_cells = []
	for row in layer:
		var offset_x = 0
		for cell in row:
			var target_cell = fitted_pos_anchor + Vector2i(offset_x, offset_y)
			if target_cell in map:
				total += cell
				target_cells.append(target_cell)
			offset_x += 1
		offset_y += 1
	# print(str(target_cells))
	return total

func translate_position_to_map(pos, map_pos) -> Vector2i:
	var modulated_vector = Vector2i(abs(round((pos - map_pos + Vector2(16, 16)) / 32)))
	modulated_vector.y *= -1
	modulated_vector -= Vector2i(1, 1)
	return modulated_vector
