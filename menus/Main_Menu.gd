extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var number_of_players = 0
var map_number = 0
var laps


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_maps()
	pass


func get_maps():
	var t = "res://maps/map_"
	for i in range(1,4):
		var map_file = t + str(i) + ".tscn"
		var map = load(map_file).instance()
		map.set_script(null)
		var map_button = preload("res://menus/map_button.tscn").instance()
		map_button.get_node("Viewport").add_child(map)
		get_node("map_selector/ScrollContainer/HBoxContainer").add_child(map_button)
		map_button.connect("pressed", self, "map_selected", [i])


func map_selected(num):
	map_number = num
	get_node("map_selector").hide()
	get_node("Laps").show()

func start_map():
	var map = load("res://maps/map_" + str(map_number) + ".tscn").instance()
	map.number_of_players = number_of_players
	map.laps = laps
	map.map_number = map_number
	queue_free()
	get_parent().add_child(map)
	pass

func _on_Start_pressed():
	get_node("Start").hide()
	get_node("Players").show()
	get_node("Back").show()
	get_node("Quit").hide()
	pass # replace with function body


func _on_Quit_pressed():
	get_tree().quit()
	pass # replace with function body

func select_stage():
	get_node("Players").hide()
	get_node("map_selector").show()
	pass

func _on_1_pressed():
	number_of_players = 1
	select_stage()
	pass # replace with function body


func _on_2_pressed():
	number_of_players = 2
	select_stage()
	pass # replace with function body


func _on_3_pressed():
	number_of_players = 3
	select_stage()
	pass # replace with function body


func _on_4_pressed():
	number_of_players = 4
	select_stage()
	pass # replace with function body


func _on_5_pressed():
	number_of_players = 5
	select_stage()
	pass # replace with function body


func _on_6_pressed():
	number_of_players = 6
	select_stage()
	pass # replace with function body
	

func _on_7_pressed():
	number_of_players = 7
	select_stage()
	pass # replace with function body


func _on_8_pressed():
	number_of_players = 8
	select_stage()
	pass # replace with function body


func _on_Back_pressed():
	var map_selector = get_node("map_selector")
	var start = get_node("Start")
	var players = get_node("Players")
	var Laps = get_node("Laps")
	var back = get_node("Back")
	var quit = get_node("Quit")
	
	if map_selector.is_visible():
		map_selector.hide()
		players.show()
	elif players.is_visible():
		players.hide()
		start.show()
		quit.show()
		back.hide()
	elif Laps.is_visible():
		Laps.hide()
		map_selector.show()
	pass # replace with function body



func _on_Lap_1_button_up():
	laps = 1
	start_map()
	pass # replace with function body


func _on_Lap_2_button_up():
	laps = 2
	start_map()
	pass # replace with function body


func _on_Lap_3_button_up():
	laps = 3
	start_map()
	pass # replace with function body


func _on_Lap_4_button_up():
	laps = 4
	start_map()
	pass # replace with function body


func _on_Lap_5_button_up():
	laps = 5
	start_map()
	pass # replace with function body


func _on_Lap_6_button_up():
	laps = 6
	start_map()
	pass # replace with function body


func _on_Lap_7_button_up():
	laps = 7
	start_map()
	pass # replace with function body


func _on_Lap_8_button_up():
	laps = 8
	start_map()
	pass # replace with function body


func _on_Lap_9_button_up():
	laps = 9
	start_map()
	pass # replace with function body


func _on_Lap_10_button_up():
	laps = 10
	start_map()
	pass # replace with function body
