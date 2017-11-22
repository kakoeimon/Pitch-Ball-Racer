extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var play_point

onready var power_pointer = get_node("power_ramp/power_pointer")
var max_power_pointer_x = 512
var dir = 1
var colors = [Color(1.0, 1.0, 0.0), Color(0.0, 0.0, 1.0), Color(1.0, 0.0, 0.0), Color(0.5, 0.0, 1.0), Color(1.0, 0.5, 0.0), Color(0.0, 1.0, 0.0), Color(0.5, 0.25, 0.0), Color(0.0, 0.0, 0.0)]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	pass

func set_play_point(p):
	play_point = p
	get_node("Camera_Sight").get_shape(0).set_length(play_point.ball.separation_length - 0.5)

func _process(delta):
	set_transform( get_transform().looking_at(play_point.ball.get_translation() , Vector3(0,1,0))) 
	set_translation( get_translation().linear_interpolate(play_point.get_translation() , 0.1) )
	
	move_pointer()

func move_pointer():
	var x = play_point.power / play_point.max_power * max_power_pointer_x
	var pos = power_pointer.get_pos()
	pos.x = x
	power_pointer.set_pos( pos )
	
func set_player(ball):
	get_node("Menu/Player").set_text("Player " + str(ball.number) + "\n" + "Lap " + str(ball.lap + 1))
	get_node("Menu").get_material().set_shader_param("Color", colors[ball.number - 1])


func _on_Menu_pressed():
	get_parent().get_parent().add_child(preload("res://menus/Main_Menu.tscn").instance())
	get_parent().queue_free()
	pass # replace with function body


func _on_Restart_button_up():
	var root = get_parent().get_parent()
	get_parent().queue_free()
	var main_menu = preload("res://menus/Main_Menu.tscn").instance()
	root.add_child(main_menu)
	main_menu.number_of_players = get_parent().number_of_players
	main_menu.map_number = get_parent().map_number
	main_menu.laps = get_parent().laps
	main_menu.start_map()



func _on_Camera_Sight_body_enter( body ):
	var mesh = body.get_node("mesh")
	var material = mesh.set_material_override(preload("res://models/map_parts_material_add.tres"))
	print(material)
	pass # replace with function body


func _on_Camera_Sight_body_exit( body ):
	var mesh = body.get_node("mesh")
	var material = mesh.set_material_override(preload("res://models/map_parts_material.tres"))
	pass # replace with function body
