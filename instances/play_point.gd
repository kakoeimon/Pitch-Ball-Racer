extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var ball
var camera
var mouse_speed = Vector2()
var mouse_input_speed = Vector2()
var mouse_sensitivity = 0.01

var mouse_down = false
var mouse_released = false

var max_power = 50.0
var power = 0.0
var power_dir = 1
var power_step = 0.5

var ball_moving = false
var ball_shooted = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	set_process_input(true)
	set_fixed_process(false)
	set_process(true)
	
	pass


func _input(e):
	if e.type == InputEvent.MOUSE_MOTION:
		mouse_input_speed = e.relative_pos
		
	if not ball_moving:
		if e.type == InputEvent.MOUSE_BUTTON:
			if e.pressed:
				mouse_down = true
			else:
				mouse_down = false
				mouse_released = true
				

#Process is for positioning the ball before the first throw
func _process(delta):
	var parent = get_parent()
	var b_tr = ball.get_translation()
	var pos = ball.play_point_translation
	var start_dir = parent.road_parts[0][1]
	var start_pos = parent.road_parts[0][0] * parent.get_cell_size()
	set_translation( b_tr + pos )
	if (mouse_speed - mouse_input_speed).length_squared() > 0.00000001:
		mouse_speed = mouse_input_speed
		pos.y += mouse_speed.y * mouse_sensitivity
		if pos.y < ball.get_translation().y:
			pos.y = ball.get_translation().y
			pos = pos.normalized() * ball.separation_length
		#pos = pos.rotated(Vector3(0,1,0), mouse_speed.x * mouse_sensitivity * 0.1)
		if start_dir == parent.PLUS_X:
			var b_pos = ball.get_translation()
			b_pos.z += mouse_speed.x * mouse_sensitivity
			b_pos.z = clamp(b_pos.z , start_pos.z - 1.5, start_pos.z + 1.5)
			ball.set_translation(b_pos)
		elif start_dir == parent.MINUS_X:
			var b_pos = ball.get_translation()
			b_pos.z -= mouse_speed.x * mouse_sensitivity
			b_pos.z = clamp(b_pos.z , start_pos.z - 1.5, start_pos.z + 1.5)
			ball.set_translation(b_pos)
		elif start_dir == parent.PLUS_Z:
			var b_pos = ball.get_translation()
			b_pos.x -= mouse_speed.x * mouse_sensitivity
			b_pos.x = clamp(b_pos.x , start_pos.x - 1.5, start_pos.x + 1.5)
			ball.set_translation(b_pos)
		elif start_dir == parent.MINUS_Z:
			var b_pos = ball.get_translation()
			b_pos.x += mouse_speed.x * mouse_sensitivity
			b_pos.x = clamp(b_pos.x , start_pos.x - 1.5, start_pos.x + 1.5)
			ball.set_translation(b_pos)
		
	set_translation( ball.get_translation() + pos )
	ball.play_point_translation = pos
	
	if mouse_released:
		mouse_down = false
		mouse_released = false
		set_process(false)
		set_fixed_process(true)
		ball.throws = 0
		get_parent().play_camera.get_node("Menu/set").hide()
		get_parent().play_camera.get_node("power_ramp").show()
		get_parent().play_camera.get_node("Menu/shoot").show()
	


#fixed Process is for throwing the ball
func _fixed_process(delta):
	var pos = ball.previous_play_point_translation
	if (mouse_speed - mouse_input_speed).length_squared() > 0.00000001:
		mouse_speed = mouse_input_speed
		pos.y += mouse_speed.y * mouse_sensitivity
		if pos.y < ball.get_translation().y:
			pos.y = ball.get_translation().y
		pos = pos.rotated(Vector3(0,1,0), mouse_speed.x * mouse_sensitivity * 0.1)
		pos = pos.normalized() * ball.separation_length
	
	set_translation( ball.get_translation() + pos )
	ball.previous_play_point_translation = pos
	
	#if ball.get_linear_velocity().length_squared() < 0.001 and ball_moving:
	if ball.is_sleeping() and ball_moving:
		ball_moving = false
		power = 0.0
		#Change player here
		get_parent().next_player()
		
	
	if mouse_down and not ball_moving:
		power += power_step * power_dir
		if power > max_power:
			power = max_power
			power_dir = -1
		elif power < 0.0:
			power = 0.0
			power_dir = 1
			
	if mouse_released:
		var hit_pos = pos
		ball.previous_translation = ball.get_translation()
		hit_pos.y = 0#ball.get_translation().y
		ball.apply_impulse(Vector3(), hit_pos.normalized() * power * -1)
		ball_moving = true
		ball.throws +=1
	mouse_released = false
	