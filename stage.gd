extends Node2D

const frame_rate := 60

var character_scene = preload("res://character.tscn")
var character: Node2D
@onready var cells = $Map.get_used_cells(0)

var vision = []
var weight_tiles = [[]]
var tile_scene = preload("res://Tile.tscn")
const TILE_WIDTH = 16

var model = []
var current_model = []
const SHAPE_RADIUS = 2
var shape = [SHAPE_RADIUS * 2 + 1, SHAPE_RADIUS * 2 + 1, 3]

const generations = 32
const attempts = 100 # number of attempts per generation
var fitness_over_time = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.physics_ticks_per_second = frame_rate
	Engine.max_fps = frame_rate
	
	# Generate display for sight of character
	for y in range(shape[1]):
		vision.append([])
		for x in range(shape[0]):
			var tile = tile_scene.instantiate()
			tile.position = $"Display Sight Anchor".position + Vector2(x * TILE_WIDTH, y * TILE_WIDTH)
			vision[y].append(tile)
			get_parent().add_child.call_deferred(tile)
	
	# Shape model
	model.resize(shape[2])
	for z in range(shape[2]):
		var arr_y = []
		arr_y.resize(shape[1])
		
		var arr_x = []
		arr_x.resize(shape[0])
		arr_x.fill(0.0)
		
		for y in range(shape[1]):
			arr_y[y] = arr_x.duplicate(true)
			
		model[z] = arr_y.duplicate(true)
	
	# Generate displays for weight layers
	for z in range(len(model)):
		weight_tiles.append([])
		for y in range(len(model[z])):
			weight_tiles[z].append([])
			for x in range(len(model[z][y])):
				var tile = tile_scene.instantiate()
				tile.position = $"Display Weights Anchor".position + Vector2(
					x * TILE_WIDTH, 
					y * TILE_WIDTH + z * (shape[0] + 2) * TILE_WIDTH
					)
				weight_tiles[z][y].append(tile)
				get_parent().add_child.call_deferred(tile)
				
	print(cells)
		
	var top_fitness := -999
	var top_fitness_model
	var delta = 1
	for gen in range(generations):
		for att in range(attempts):
			character = character_scene.instantiate();
			character.map = cells
			character.map_anchor = $Map.position
			character.weights = model.duplicate(true)
			for n in range(randi_range(1, 5)):
				var z = randi_range(0, shape[2] - 1)
				var y = randi_range(0, shape[1] - 1)
				var x = randi_range(0, shape[0] - 1)
				character.weights[z][y][x] += \
					(-1 if randf() < 0.4 else 1) * delta
				# character.weights[z][y][x] = clamp(character.weights[z][y][x], -1.0, 1.0)
			current_model = character.weights.duplicate(true)
			character.goal = $Goal
			get_parent().add_child.call_deferred(character)
			await character.close
			var fitness = round(-character.distance.x * 0.5 - character.distance.y * 0.1) + \
				(200 if character.success else 0) + 300
			fitness = round(fitness)
			if fitness > top_fitness:
				top_fitness = fitness
				top_fitness_model = character.weights.duplicate(true)
			print("fitness: ", fitness)
			get_parent().remove_child(character)
			await get_tree().create_timer(0.05).timeout
		model = top_fitness_model.duplicate(true)
		print("fitness after gen ", gen, ": ", top_fitness)
		fitness_over_time.append(top_fitness)
		

func hypot(vector: Vector2):
	return sqrt(vector.x ** 2 + vector.y ** 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fitted_pos = character.translate_position_to_map(character.position, $Map.position)
	$"Position Label".text = str(fitted_pos)

	for y in range(0, shape[1]):
		for x in range(0, shape[1]):
			var tile = vision[y][x]
			if Vector2i(x, y) == Vector2i(SHAPE_RADIUS, SHAPE_RADIUS):
				tile.color = Color(1, 0, 0)
			elif fitted_pos + Vector2i(x, y) - Vector2i(SHAPE_RADIUS, SHAPE_RADIUS) in cells:
				tile.color = Color(0, 0, 1)
			else:
				tile.color = Color(1, 1, 1)
	
	for z in range(0, shape[2]):
		for y in range(-SHAPE_RADIUS, SHAPE_RADIUS + 1):
			for x in range(-SHAPE_RADIUS, SHAPE_RADIUS + 1):
				var tile = weight_tiles[z][y][x]
				var val = current_model[z][y][x]
				if val < 0:
					tile.color = Color(clamp(abs(val / 8), 0.0, 1.0), 0.0, 0.0)
				else:
					tile.color = Color(0.0, clamp(abs(val / 8), 0.0, 1.0), 0.0)

	
