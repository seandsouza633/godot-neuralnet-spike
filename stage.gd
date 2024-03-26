extends Node2D

const frame_rate := 60

var character_scene = preload("res://character.tscn")
var character: Node2D
@onready var cells = $Map.get_used_cells(0)

var tiles = []
var tile_scene = preload("res://Tile.tscn")
const TILE_WIDTH = 16

var model = []
var shape = [5, 5, 3]
const HALF_SHAPE = 2

const generations = 10
const attempts = 20 # number of attempts per generation

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.physics_ticks_per_second = frame_rate
	Engine.max_fps = frame_rate
	
	for y in range(shape[1]):
		tiles.append([])
		for x in range(shape[0]):
			var tile = tile_scene.instantiate()
			tile.position = $"Display Anchor".position + Vector2(x * TILE_WIDTH, y * TILE_WIDTH)
			tile.color = Color(randf(), randf(), randf())
			tiles[y].append(tile)
			get_parent().add_child.call_deferred(tile)
	
	model.resize(shape[2])
	for z in range(shape[2]):
		var arr_y = []
		arr_y.resize(shape[1])
		
		var arr_x = []
		arr_x.resize(shape[0])
		arr_x.fill(0.0)
		
		for y in range(shape[1]):
			arr_y[y] = arr_x.duplicate()
			
		model[z] = arr_y.duplicate()
	
	print(cells)
		
	var top_fitness := -999
	var top_fitness_model
	var delta = 1
	for gen in range(generations):
		for att in range(attempts):
			character = character_scene.instantiate();
			character.map = cells
			character.map_anchor = $Map.position
			character.weights = model
			for n in range(randi_range(0, 4)):
				var z = randi_range(0, shape[2] - 1)
				var y = randi_range(0, shape[1] - 1)
				var x = randi_range(0, shape[0] - 1)
				character.weights[z][y][x] += \
					(-1 if randf() < 0.5 else 1) * delta
				# character.weights[z][y][x] = clamp(character.weights[z][y][x], -1.0, 1.0)
			character.goal = $Goal
			get_parent().add_child.call_deferred(character)
			await character.close
			var fitness = round(-character.distance.x * 0.5 - character.distance.y * 0.1) + \
				(200 if character.success else 0)
			fitness = round(fitness)
			if fitness > top_fitness:
				top_fitness = fitness
				top_fitness_model = character.weights.duplicate()
			print("fitness: ", fitness)
			get_parent().remove_child(character)
			await get_tree().create_timer(0.1).timeout
		model = top_fitness_model.duplicate()
		print("fitness after gen ", gen, ": ", top_fitness)
		

func hypot(vector: Vector2):
	return sqrt(vector.x ** 2 + vector.y ** 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fitted_pos = character.translate_position_to_map(character.position, $Map.position)
	$"Position Label".text = str(fitted_pos)
	var offset_y = -HALF_SHAPE
	for row in tiles:
		var offset_x = -HALF_SHAPE
		for tile in row:
			if Vector2i(offset_x, offset_y) == Vector2i(0, 0):
				tile.color = Color(1, 0, 0)
			elif fitted_pos + Vector2i(offset_x, offset_y) in cells:
				tile.color = Color(0, 0, 1)
			else:
				tile.color = Color(1, 1, 1)
			offset_x += 1
		offset_y += 1
			
	
