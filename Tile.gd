extends Node2D

var color := Color(1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello bro")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Polygon2D.color = color
