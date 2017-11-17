extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var play_point

onready var power_pointer = get_node("power_ramp/power_pointer")
var max_power_pointer_x = 5.12
var dir = 1


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#target = get_path_to(get_parent().get_node("car/Position3D"))
	play_point = get_parent().get_node("play_point")
	set_process(true)
	pass


func _process(delta):
	set_transform( get_transform().looking_at(play_point.ball.get_translation() , Vector3(0,1,0))) 
	set_translation( get_translation().linear_interpolate(play_point.get_translation() , 0.1) )
	
	move_pointer()

func move_pointer():
	var x = play_point.power / play_point.max_power * max_power_pointer_x
	var pos = power_pointer.get_translation()
	pos.x = x
	power_pointer.set_translation( pos )
	
func set_player(ball):
	get_node("Player").set_text("Player " + str(ball.number) + "\n" + "Lap " + str(ball.lap + 1))
	


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

