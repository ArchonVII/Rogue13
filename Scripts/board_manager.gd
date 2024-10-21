extends Node

"""
Board Manager creates the squares and monitors actions performed on the squares
"""

var debug_board = false
var board_coordinates = [] # holds array of square locations based on size
var debug_coordinates = [] # debug mirror board

var square_scene = load("res://Scenes/Master_Square.tscn")

signal sig_square_piece_clicked
signal square_index_label(square)

func _ready() -> void:
	create_square()

#region Mouse responses
func _on_square_clicked(viewport, event, shape_idx, square):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
		#print("square input 1 test: square click")
		pass

	# share that this is the origin square for a potential piece movement as the piece is being dragged by the user
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print("square input 2 test: square click to start dragging piece")
		Global.pickedup_square = square

	# share that this is the square a piece was placed on
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released:
		#if Global.dragged_piece != null:
			#print("square input 3 test: square click after dropping a dragged piece")
		#else:
			#print("square input 3 test: square click after")
		Global.dropped_square = square.data.index

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		#print("square input 4 test: square right click")
		pass

func _on_square_hovered(square):
	emit_signal("square_index_label", square)

func _on_area_entered(area):
	var parent_piece = area.get_parent()
	#if parent_piece.is_in_group("pieces"):  # Assuming pieces are in a "chess_pieces" group
		#print("Piece entered the square!")

func _on_area_exited(area):
	pass
	#if area.is_in_group("pieces"):
		#print("Piece exited the square!")

func _input(event):
	pass

func mouse_exited(square):
	pass

func create_square():

	var _square_coordinates = []
	var x = 0
	while x < 8:
		for y in range(0, 8):
			var loc = Vector2((y) * Global.square_size, (x) * Global.square_size)
			_square_coordinates.append(loc)
		x += 1

	for i in range(0, Global.board_size):
		var square_resource = load("res://Scripts/square_resource.gd")
		var position = Vector2(_square_coordinates[i])
		var _square = square_resource.new(i, position)

		var square_instance = square_scene.instantiate()
		square_instance.data = _square
		square_instance.position = position

		var colorrect = ColorRect.new()
		colorrect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		colorrect.set_custom_minimum_size(Vector2(Global.square_size/2,Global.square_size/2))

		if GlobalUtility.square_color_order[i] == "white":
			colorrect.color = Color(GlobalUtility.white_square_color)
			square_instance.data.color = 0
		elif GlobalUtility.square_color_order[i] == "black":
			colorrect.color = Color(GlobalUtility.black_square_color)
			square_instance.data.color = 1

		square_instance.add_child(colorrect)
		var lab = Label.new()
		lab.text = str(i)
		square_instance.add_child(lab)

		var area2d = square_instance.get_node("Area2D")
		for j in square_instance.get_children():
			if j is Area2D:
				j.connect("input_event", Callable(self, "_on_square_clicked").bind(square_instance))
				j.connect("mouse_entered", Callable(self, "_on_square_hovered").bind(square_instance))
				j.connect("mouse_exited", Callable(self, "_on_piece_unhovered").bind(square_instance))

				j.connect("area_entered", Callable(self, "_on_area_entered").bind(square_instance))
				j.connect("area_exited", Callable(self, "_on_area_exited").bind(square_instance))

		square_instance.add_to_group("squares")
		add_child(square_instance)
