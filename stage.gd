extends Node2D

var frame_rate := 60

var character = preload("res://character.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.physics_ticks_per_second = frame_rate
	Engine.max_fps = frame_rate
	for n in range(5):
		add_child(character.instantiate())
		await get_tree().create_timer(3).timeout 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
