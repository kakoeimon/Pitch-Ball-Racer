extends RigidBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var number = 0
var play_point_translation = Vector3()
var previous_translation = Vector3()
var previous_play_point_translation = Vector3()
var separation_length = 10.0
var throws = 0

var lap = 0
var changed_lap = false
var previous_lap = 0
var road_part_num = 0
var road_part_travel = 0 #This is the axis value to be checked for priority

var finnished = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	play_point_translation = previous_play_point_translation
	previous_translation = get_translation()
