extends GridMap

const ROAD_PART_START = 0
const ROAD_PART_ROAD = 1
const ROAD_PART_TURN_LEFT = 2
const ROAD_PART_TURN_RIGHT = 3
const ROAD_PART_RAMP_UP_2 = 4
const ROAD_PART_RAMP_UP_1 = 5
const ROAD_PART_RAMP_DOWN_2 = 6
const ROAD_PART_RAMP_DOWN_1 = 7


const PLUS_X = 10
const MINUS_X = 0
const PLUS_Z = 16
const MINUS_Z = 22

const TURN_LEFT_PLUS_X = 16
const TURN_LEFT_MINUS_X = 22
const TURN_LEFT_PLUS_Z = 0
const TURN_LEFT_MINUS_Z = 10

const TURN_RIGHT_PLUS_X = 22
const TURN_RIGHT_MINUS_X = 16
const TURN_RIGHT_PLUS_Z = 10
const TURN_RIGHT_MINUS_Z = 0

var cell_step = 6 #This is the length of the road part

var laps = 1
var map_number = 0

var play_point = preload("res://instances/play_point.tscn").instance()
var play_camera = preload("res://instances/play_camera.tscn").instance()
var number_of_players = 2
var players = []
var play_order = []
var play_turn = 0
var finnishers = 0
var win_order = []

var road_parts = []
var road_areas = []


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	get_road()
	create_road_areas()
	set_ball()
	add_child(play_point)
	play_camera.set_play_point(play_point)
	add_child(play_camera)
	
	set_area_out()
	


func get_starting_cell(max_cell = 10):
	for x in range(-max_cell, max_cell):
		for y in range(-max_cell, max_cell):
			for z in range(-max_cell, max_cell):
				if get_cell_item(x,y,z) == ROAD_PART_START: #if you change the mesh library of the grid this may change, it is based on the position of the object in the outliner of blender
					return [Vector3(x,y,z) , get_cell_item_orientation(x,y,z) , ROAD_PART_START]


func get_road():
	var a = get_starting_cell() #a is the active cell for searching of the next
	road_parts = [] # reset the array to be sure not expanding it
	road_parts.append( a ) # add the staring cell
	
	
	var next = get_next_part( a )
	road_parts.append(next)
	for i in range(100):
		next = get_next_part(next)
		if next[2] == ROAD_PART_START:
			return
		road_parts.append(next)
	

func get_next_part(a):
	var x = 0
	var y = 0
	var z = 0
	if a[2] == ROAD_PART_ROAD or a[2] == ROAD_PART_START or a[2] == ROAD_PART_RAMP_DOWN_1 or a[2] == ROAD_PART_RAMP_DOWN_2 or a[2] == ROAD_PART_RAMP_UP_1 or a[2] == ROAD_PART_RAMP_UP_2:
		x = a[0].x
		y =  a[0].y
		z = a[0].z
		if a[1] == PLUS_X:
			x += cell_step
		elif a[1] == MINUS_X:
			x -= cell_step
		elif a[1] == PLUS_Z:
			z += cell_step
		elif a[1] == MINUS_Z:
			z -= cell_step
			
		if a[2] == ROAD_PART_RAMP_DOWN_1:
			y -=1
		elif a[2] == ROAD_PART_RAMP_DOWN_2:
			y -=2
		elif a[2] == ROAD_PART_RAMP_UP_1:
			y +=1
		elif a[2] == ROAD_PART_RAMP_UP_2:
			y +=2
		return next_part_array(x,y,z)

	if a[2] == ROAD_PART_TURN_LEFT:
		if a[1] == TURN_LEFT_PLUS_X:
			return next_part_array(a[0].x + cell_step, a[0].y, a[0].z)
		if a[1] == TURN_LEFT_MINUS_X:
			return next_part_array(a[0].x - cell_step, a[0].y, a[0].z)
		if a[1] == TURN_LEFT_PLUS_Z:
			return next_part_array(a[0].x , a[0].y, a[0].z + cell_step)
		if a[1] == TURN_LEFT_MINUS_Z:
			return next_part_array(a[0].x , a[0].y, a[0].z - cell_step)
			
	if a[2] == ROAD_PART_TURN_RIGHT:
		if a[1] == TURN_RIGHT_PLUS_X:
			return next_part_array(a[0].x + cell_step, a[0].y, a[0].z)
		if a[1] == TURN_RIGHT_MINUS_X:
			return next_part_array(a[0].x - cell_step , a[0].y, a[0].z)
		if a[1] == TURN_RIGHT_PLUS_Z:
			return next_part_array(a[0].x , a[0].y, a[0].z + cell_step)
		if a[1] == TURN_RIGHT_MINUS_Z:
			return next_part_array(a[0].x , a[0].y, a[0].z - cell_step)

func next_part_array(x , y, z):
	return [Vector3( x, y, z)  , get_cell_item_orientation(x, y, z) , get_cell_item( x, y, z ) ]


func create_road_areas():
	var area_pkg = preload("res://instances/road_part_area.tscn")
	var area_turn_pkg = preload("res://instances/road_part_turn_area.tscn")
	var area_ramp_pkg = preload("res://instances/road_part_ramp_area.tscn")
	road_areas = []
	var cell_size = get_cell_size()
	var pos
	

	for r in road_parts:
		var area
		pos = r[0] * cell_size
		pos.y += 2.5

		if r[2] == ROAD_PART_START:
			area = area_pkg.instance()
			area.connect("body_enter", self, "_on_Area_Start_enter")
			area.connect("body_exit", self, "_on_Area_Start_exit")
		elif r[2] == ROAD_PART_ROAD:
			area = area_pkg.instance()
		elif r[2] == ROAD_PART_TURN_LEFT or r[2] == ROAD_PART_TURN_RIGHT: ## the turn number
			area = area_turn_pkg.instance()
		elif r[2] == ROAD_PART_RAMP_UP_1 or r[2] == ROAD_PART_RAMP_UP_2:
			pos.y +=1
			area = area_ramp_pkg.instance()
		elif r[2] == ROAD_PART_RAMP_DOWN_1 or r[2] == ROAD_PART_RAMP_DOWN_2:
			pos.y -=1
			area = area_ramp_pkg.instance()
		area.set_translation(pos)
		if r[1] == PLUS_Z or r[1] == MINUS_Z:
			area.rotate_y(PI/2)
		add_child(area)
		road_areas.append(area)
		
func set_ball_starting_position(ball):
	var pos = road_parts[0][0] * get_cell_size()
	var dist = 2.0
	pos.y += 2
	
	if road_parts[0][1] == PLUS_X:
		pos.x -=dist
		ball.previous_play_point_translation = Vector3(-1,0.3,0).normalized() * ball.separation_length
	elif road_parts[0][1] == MINUS_X:
		pos.x +=dist
		ball.previous_play_point_translation = Vector3(1,0.3,0).normalized() * ball.separation_length
	elif road_parts[0][1] == PLUS_Z:
		pos.z -=dist
		ball.previous_play_point_translation = Vector3(0,0.3,-1).normalized() * ball.separation_length
	elif road_parts[0][1] == MINUS_Z:
		pos.z +=dist
		ball.previous_play_point_translation = Vector3(0,0.3,1).normalized() * ball.separation_length
	ball.set_translation( pos )


func set_ball():
	var ball = preload("res://instances/ball.tscn").instance()
	var material = preload("res://textures/ball_material.tres").duplicate()
	var texture = load("res://textures/ball_" + str(players.size() + 1) + ".tex")
	print(players.size())
	material.set_texture(0, texture)
	ball.get_node("ball_model/Sphere").set_material_override(material)
	set_ball_starting_position(ball)
	add_child(ball)
	players.append(ball)
	play_point.ball = ball
	ball.number = players.size()
	play_camera.set_player(play_point.ball)
	play_camera.get_node("Menu/set").show()
	play_camera.get_node("Menu/shoot").hide()
	play_camera.get_node("power_ramp").hide()
	
func next_player():
	if players.size() < number_of_players:
		set_ball()
		play_point.set_fixed_process(false)
		play_point.set_process(true)
	else:
		if play_order.size() == 0:
			set_order()
		if play_order.size() == 0: #check again cause play_order changed from set_order
			race_finnished()
		else:
			play_point.ball = play_order[0]
			play_order.pop_front()
			#play_point.ball.previous_translation = play_point.ball.get_translation()
			play_point.ball.changed_lap = false
			play_camera.set_player(play_point.ball)
			
			




func get_ball_stats_for_order():
	for i in range(road_areas.size()):
		var area_colliders = road_areas[i].get_overlapping_areas()
		for area in area_colliders:
			var b = area.get_parent()
			b.road_part_num = i
			if road_parts[i][2] == ROAD_PART_ROAD or road_parts[i][2] == ROAD_PART_START or road_parts[2] == ROAD_PART_RAMP_DOWN_1 or road_parts[2] == ROAD_PART_RAMP_DOWN_2 or road_parts[2] == ROAD_PART_RAMP_UP_1 or road_parts[2] == ROAD_PART_RAMP_UP_2:
				if road_parts[i][1] == PLUS_X:
					b.road_part_travel = b.get_translation().x
				elif road_parts[i][1] == MINUS_X:
					b.road_part_travel = -b.get_translation().x
				elif road_parts[i][1] == PLUS_Z:
					b.road_part_travel = b.get_translation().z
				elif road_parts[i][1] == MINUS_Z:
					b.road_part_travel = -b.get_translation().z
			elif road_parts[i][2] == ROAD_PART_TURN_LEFT:
				if road_parts[i][1] == TURN_LEFT_PLUS_X:
					b.road_part_travel = b.get_translation().x
				elif road_parts[i][1] == TURN_LEFT_MINUS_X:
					b.road_part_travel = -b.get_translation().x
				elif road_parts[i][1] == TURN_LEFT_PLUS_Z:
					b.road_part_travel = b.get_translation().z
				elif road_parts[i][1] == TURN_LEFT_MINUS_Z:
					b.road_part_travel = -b.get_translation().z
			elif road_parts[i][2] == ROAD_PART_TURN_RIGHT:
				if road_parts[i][1] == TURN_RIGHT_PLUS_X:
					b.road_part_travel = b.get_translation().x
				elif road_parts[i][1] == TURN_RIGHT_MINUS_X:
					b.road_part_travel = -b.get_translation().x
				elif road_parts[i][1] == TURN_RIGHT_PLUS_Z:
					b.road_part_travel = b.get_translation().z
				elif road_parts[i][1] == TURN_RIGHT_MINUS_Z:
					b.road_part_travel = -b.get_translation().z
					
					
func set_order():
	var ordered = false
	get_ball_stats_for_order()
	#play_order.append(players[0])
	
	for i in range(0, players.size()):
		ordered = false
		if players[i].finnished > 0:
			continue
		else:
			if play_order.size() == 0:
				play_order.append(players[i])
				continue
		for j in range(play_order.size()):
			if players[i].lap > play_order[j].lap:
				play_order.insert(j, players[i])
				ordered = true
				break
			elif players[i].road_part_num > play_order[j].road_part_num:
				play_order.insert(j, players[i])
				ordered = true
				break
			elif players[i].road_part_num == play_order[j].road_part_num:
				if players[i].road_part_travel > play_order[j].road_part_travel:
					play_order.insert(j, players[i])
					ordered = true
					break
		if not ordered:
			play_order.append(players[i])
			


func set_area_out():
	var area = get_node("Area_Bounds")
	var max_x = -1000
	var min_x = 1000
	var max_y = -1000
	var min_y = 1000
	var max_z = -1000
	var min_z = 1000
	var e_x = 0
	var e_y = 0
	var e_z = 0
	
	
	#GET max values
	for r in road_parts:
		if r[0].x > max_x:
			max_x = r[0].x
		if r[0].x < min_x:
			min_x = r[0].x
		if r[0].y > max_y:
			max_y = r[0].y
		if r[0].y < min_y:
			min_y = r[0].y
		if r[0].z > max_z:
			max_z = r[0].z
		if r[0].z < min_z:
			min_z = r[0].z
			
	max_x += cell_step / 2
	min_x -= cell_step / 2
	max_y += cell_step
	#min_y -= cell_step
	max_z += cell_step / 2
	min_z -= cell_step / 2
	e_x = (max_x - min_x) / 2
	e_y = (max_y - min_y) / 2
	e_z = (max_z - min_z) / 2
	
	var shape = area.get_shape(0)
	shape.set_extents( Vector3(e_x , e_y, e_z) )
	var tr = Transform()
	tr.origin = Vector3(min_x + e_x, min_y + e_y, min_z + e_z)
	area.set_shape_transform(0, tr)
	area.connect("body_exit", self, "_on_Area_Bounds_body_exit")


func _on_Area_Bounds_body_exit( body ):
	body.set_linear_velocity(Vector3())
	body.set_angular_velocity(Vector3())
	body.set_translation( body.previous_translation )
	if body.changed_lap:
		if body.lap == laps:
			set_ball_starting_position(body)
			body.previous_translation = body.get_translation()
		else:
			body.lap = body.previous_lap
	pass # replace with function body
	
func _on_Area_Start_enter(body):
	get_ball_stats_for_order()
	if body.road_part_num == road_parts.size()-1:
		body.previous_lap = body.lap
		body.changed_lap = true
		body.lap +=1
		if body == play_point.ball:
			play_camera.set_player(body)
		if body.lap == laps:
			finnishers +=1
			body.finnished = finnishers
			win_order.append(body)
		
	
func _on_Area_Start_exit(body):
	get_ball_stats_for_order()
	if body.road_part_num == road_parts.size()-1:
		body.previous_lap = body.lap
		body.changed_lap = true
		body.lap -=1
		if body == play_point.ball:
			play_camera.set_player(body)

func race_finnished():
	play_camera.get_node("power_ramp").hide()
	play_camera.get_node("Menu/Player").hide()
	play_camera.get_node("Menu/shoot").hide()
	play_point.set_fixed_process(false)
	#play_camera.set_process(false)
	
	var t = "RACE FINNISHED\n"
	for i in range(win_order.size()):
		t += str(i + 1) + ": Player " + str(win_order[i].number) + "\n"
	play_camera.get_node("win_order").set_text(t)
	play_camera.get_node("win_order").show()
	play_point.ball = win_order[0]
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)