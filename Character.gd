extends CharacterBody2D

var frame_counter := 0

const SPEED = 200.0
const KEY_JUMP_VELOCITY = -400.0

const KEY_JUMP = "ui_accept"
const KEY_LEFT = "ui_left"
const KEY_RIGHT = "ui_right"

const STOP = "stop:"
const STOP_JUMP = STOP + KEY_JUMP
const STOP_LEFT = STOP + KEY_LEFT
const STOP_RIGHT = STOP + KEY_RIGHT

var inputs = [
	[60, [KEY_RIGHT]],
	[72, [KEY_LEFT, STOP_RIGHT]],
	[84, [STOP_LEFT]],
	[100, [KEY_JUMP]],
	[101, [STOP_JUMP]]
]
var inputs_index := 0

var completed := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed(KEY_JUMP) and is_on_floor():
		velocity.y = KEY_JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(KEY_LEFT, KEY_RIGHT)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	

func _process(delta):	
	# Increment the frame counter.
	frame_counter += 1
	
	# Process inputs on that frame
	if inputs_index < len(inputs) and inputs[inputs_index][0] == frame_counter:
		var actions = inputs[inputs_index][1]
		assert(actions is Array)
		for action in actions:
			assert(action is String)
			if STOP in action:
				Input.action_release(action.replace(STOP, ""))
			else:
				Input.action_press(action)
			print(inputs[inputs_index][1])
		inputs_index += 1
	
	
	
	
	
