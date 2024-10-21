extends Node

var piece_scene = load("res://Scenes/Master_Piece.tscn")
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	pass # Replace with function body.


func create_piece(type: String, color: String, pos: Vector2):

	# type: the name of the piece
	# color: the name of the color
	# pos: Vector2 of board location

	# establish location
	var i_rank = (pos.y / Global.square_size)
	var i_file = (pos.x / Global.square_size)

	# establish piece index location
	var piece_index = (8 * (i_rank) + i_file )
	var _index = Global.get_dex(i_rank, i_file)		# TEST shouldn't I already have this?
	var transpose = _index

	# grab enum type number
	var unit
	match type:
		"pawn":
			unit = 0
		"knight":#
			unit = 1
		"bishop":
			unit = 2
		"rook":
			unit = 3
		"queen":
			unit = 4
		"king":
			unit = 5

	# load the resource for the piece
	var piece_resource = load("res://Scripts/piece_resource.gd")
	var _piece = piece_resource.new(unit, color, transpose)

	# add the basic location data
	_piece.position = pos																				# Vector2 position
	_piece.row = i_rank																					# index rank
	_piece.col = i_file																					# index file
	_piece.square = str(GlobalUtility.get_value_from_key(GlobalUtility.dict_square_position, pos))		# square name

	# create piece scene and assign resource to piece
	var piece_instance = piece_scene.instantiate()
	piece_instance.data = _piece
	piece_instance.position = pos

	# add to groups and update world
	add_child(piece_instance)
	piece_instance.add_to_group("pieces")
	piece_instance.add_to_group(str(color))
	Global.white_index.append(piece_index)
	Global.empty_index.remove(piece_index)

	# connect to signals
	var area2d = piece_instance.get_node("Area2D")
	if area2d:
		area2d.connect("input_event", Callable(self, "_on_piece_clicked").bind(piece_instance))
		area2d.connect("mouse_entered", Callable(self, "_on_piece_hovered").bind(piece_instance))
		area2d.connect("mouse_exited", Callable(self, "_on_piece_unhovered").bind(piece_instance))

func set_starting_board():
	var back_line = [
		"rook", "knight", "bishop", "queen", "king",
		"bishop", "knight", "rook"]

	for i in range(0, 8):
		var _piece = back_line[i]
		var pos = GlobalUtility.dict_square_position[GlobalUtility.dict_square_position.keys()[i]]
		create_piece(_piece, "black", pos)

	# WHITE
	var white_back_squares = GlobalUtility.rank_list["1"]
	for i in range(0, 8):
		var square = white_back_squares[i]
		var pos = GlobalUtility.dict_square_position[str(square)]
		var _piece = back_line[i]
		create_piece(_piece, "white", pos)

	# PAWNS
	var black_pawns = GlobalUtility.rank_list["7"]
	var white_pawns = GlobalUtility.rank_list["2"]

	for i in range(0,8):
		var bpos = GlobalUtility.dict_square_position[str(black_pawns[i])]
		var wpos = GlobalUtility.dict_square_position[str(white_pawns[i])]
		create_piece("pawn", "black", GlobalUtility.dict_square_position[str(black_pawns[i])])
		create_piece("pawn", "white", GlobalUtility.dict_square_position[str(white_pawns[i])])


	for row in Global.piece_mask:
		if row == 0:
			print("%08d" % String.num_int64(row, 2))
		else:
			print( String.num_int64(row, 2))
