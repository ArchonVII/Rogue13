extends Node2D

@onready var board = $"../Board"
@onready var sound_move_self = $"../Sound/move-self"
@onready var sound_capture = $"../Sound/capture"
@onready var sound_click = $"../Sound/click"
@onready var overlay = $"../Overlay"
@onready var tooltip_node = $"../Tooltips"
@onready var main = $".."

@onready var pixel_shader = preload('res://Shaders/pixelate4.tres')
@onready var vibrate_shader = preload("res://Shaders/invis.tres")
@onready var tool_tip = preload("res://Scenes/tooltip.tscn")

var piece_scene = load("res://Scenes/Master_Piece.tscn")
var dragged_piece = null
var is_dragging = null
var dragged_piece_move_list = null
var dragged_piece_origin_coordinate = null
var dragged_piece_moves_checked = null

signal mask_update
signal attempted_move(piece, square)
signal piece_index_label(piece)
signal square_index_label(square)
signal piece_placed(piece, square)
signal set_target_square(position)


signal show_overlay(piece, moves)
signal clear_overlay
signal check_overlay(color, moves)

signal display_empty_moves(piece, moves)
signal display_attack_moves(piece, moves)
signal display_defended_squares(piece, moves)

signal king_check(color)

signal create_tooltip(tooltip, piece, square)

signal update_turn

var piece_hovered

#tooltip stuff
var tooltip_active = false
var tooltip_piece = null
@onready var tt_name = $N/M/V/Name

func _ready():
	pass


func _create_tooltip(piece):
	tooltip_piece = piece
	tooltip_active = true
	var tooltip = tool_tip.instantiate()
	tooltip.position = piece.data.position
	var hsquare = Global.hovered_square


	tooltip.get_node("N/M/V/Name").set_text(piece.data.givenfirstname + piece.data.givenlastname)
	tooltip.get_node("N/M/V/Ind/Index").set_text(str(piece.data.index))
	tooltip.get_node("N/M/V/Mov/Moves").set_text(str(piece.data.moves_empty))
	tooltip.get_node("N/M/V/Att/Attacks").set_text(str(piece.data.moves_attack))

	#var tname = tt_name
	#tname.text = piece.data.givenfirstname

	overlay.add_child(tooltip)


#region movement
func _process(delta):

	if is_dragging and dragged_piece:
		# HACK could mess it up
		if !dragged_piece_move_list and !dragged_piece_moves_checked:

			if Global.free_movement == false:
				dragged_piece_origin_coordinate = dragged_piece.position
				#print("dragged piece position / origin coordinate ", dragged_piece_origin_coordinate, " - ", dragged_piece.position)

			else:
				dragged_piece_origin_coordinate = dragged_piece.position

			dragged_piece_moves_checked = true

		var offset = Global.square_size * 0.5
		var globalpos =get_global_mouse_position() * 1.75


		# HACK changed mouse position
		dragged_piece.position = get_global_mouse_position() - Vector2(offset, offset)

		var area2d = dragged_piece.get_node("Area2D")
		var overlapping_areas = area2d.get_overlapping_areas()

		for area in overlapping_areas:
			if area.is_in_group("squares"):  # Check if the area is a chess square
				print("Piece is over a square")
			if area.is_in_group("pieces"):
				print("Piece is over a piece")



func _on_piece_clicked(viewport, event, shape_idx, piece):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:					# if the piece is clicked
		Global.selected_piece = piece # for effect usage

		if Global.free_turn == true or (Global.free_turn == false and piece.data.color == Global.turn_color_is):
			var return_square = Global.pickedup_square
			if event.pressed and not is_dragging:			# and you're not currently dragging a piece
				is_dragging = true							# Start dragging
				dragged_piece = piece 						# set global
				#check_legal_moves(dragged_piece) 			# get the pieces legal moves
				emit_signal("piece_index_label", piece)
				find_moves(dragged_piece)
				# BISHOP TEST
				if dragged_piece.data.ptype == 2:
					get_bishop_moves(piece)

				if dragged_piece.data.ptype == 3:
					var empty = []
					get_rook_moves(piece, empty)

				if dragged_piece.data.ptype == 1:
					get_knight_moves(piece)

				if dragged_piece.data.ptype == 0:
					get_pawn_moves(piece)

				if dragged_piece.data.ptype == 4:
					get_bishop_moves(piece)

				if dragged_piece.data.ptype == 5:
					get_king_moves(piece)

			elif not event.pressed and is_dragging:			# if the mouse is let go after dragging
				is_dragging = false							# Stop dragging
				var target_square= Global.hovered_square

				if Global.free_movement:
					index_snap_to(dragged_piece, target_square, "move")

				elif piece.data.moves_empty.has(target_square.data.index):
					index_snap_to(dragged_piece, target_square, "move")
					if piece.data.moves_attack.has(target_square.data.index):
						index_snap_to(dragged_piece, target_square, "capture")
						# PIECE CAPTURED
				else:
					print("target_square ", target_square, " return square ", return_square)
					index_snap_to(dragged_piece, return_square, "return")
					dragged_piece = null
					reset_dragged_piece(piece)
					emit_signal("clear_overlay")


				#index_snap_to(dragged_piece, target_square)
				dragged_piece = null

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				if !tooltip_active:
					_create_tooltip(piece)
				if tooltip_active:
					for tip in tooltip_node.get_children():
						tip.queue_free()
					_create_tooltip(piece)

func find_moves(piece):

	if piece.data.ptype == 2:
			get_bishop_moves(piece)

	if piece.data.ptype == 3:
		var empty = []
		get_rook_moves(piece, empty)

	if piece.data.ptype == 1:
		get_knight_moves(piece)

	if piece.data.ptype == 0:
		get_pawn_moves(piece)

	if piece.data.ptype == 4:
		get_bishop_moves(piece)

	if piece.data.ptype == 5:
		get_king_moves(piece)




func index_snap_to(piece, square, movetype):

	var check_check = will_my_king_be_in_check(piece)
	print("check check: ", check_check, " piece thinks it is on ", piece.data.index)
	if !check_check:
		piece.position = square.position
	else:
		print("Move would place king in check")
		return

	print("piece total moves: ", piece.data.total_moves)
	# sound
	play_sound("move_self")

	# world update
	reset_dragged_piece(piece)

	if movetype != "return":
		emit_signal("piece_placed", piece, square)
		emit_signal("update_turn")
		update_moves(piece)
	else:

		emit_signal("clear_overlay")

func will_my_king_be_in_check(piece):

	#grab enemy color
	var enemy_color
	if piece.data.color == "white":
		enemy_color = "black"
		will_their_king_be_in_check(piece, "white", "black")
	else:
		enemy_color = "white"
		will_their_king_be_in_check(piece, "black", "white")

	# get restricted squares for the king
	var kingcheck = overlay.king_check(piece.data.color, enemy_color)
	#print("WILLMYKING: kingcheck: ", kingcheck)
	if kingcheck.has(piece.data.index):
		return true
	else:
		return false

func will_their_king_be_in_check(piece, color, enemy):
	pass

func _on_piece_hovered(piece):
	piece_hovered = piece

func _on_piece_unhovered(piece):
	if piece == tooltip_piece:
		for child in tooltip_node.get_children():
			child.queue_free()


#endregion

# FIND ALL POSSIBLE MOVES FOR PIECE, REMOVE BLOCKERS, SEND TO OVERLAY
#region piece moves

func get_bishop_moves(piece):

	var moves = []
	var moves_NE = []
	var moves_SE = []
	var moves_NW = []
	var moves_SW = []
	var rank = piece.data.row
	var file = piece.data.col
	var index = piece.data.index

	# loop variables
	var left_flag = true
	var right_flag = true
	var s = 1
	var s2 = 1
	var _move

	# look below the piece
	for i in range((rank), 8):
		if ((file) - (1 * s)) > -1:
			_move = (index + (Movement.SE * s))
			if _move > -1 and _move < 64:
				moves_SE.append(_move)

		if ((file) + (1 * s)) < 8:
			_move = (index + (Movement.SW * s))
			if _move > -1 and _move < 64:
				moves_SW.append(_move)
		s += 1

	# look above the piece
	for i in range((rank), 0, -1):
		if (file - (1 * s2)) > -1:
			_move = (index + (Movement.NW * s2))
			if _move > -1 and _move < 64:
				moves_NW.append(_move)
		if (file + (1 * s2)) < 8:
			_move = (index + (Movement.NE * s2))
			if _move > -1 and _move < 64:
				moves_NE.append(_move)
		s2 += 1

	moves.append(moves_NW)
	moves.append(moves_NE)
	moves.append(moves_SE)
	moves.append(moves_SW)

	if piece.data.ptype == 4:
		get_rook_moves(piece, moves)

	slide_blockers(piece, moves)
	return moves


func slide_blockers(piece, moves):
	var _attacks = []
	var _friends = []
	var _empty = []
	var _final_moves = []
	var _legal_moves = []

	for i in moves:
		for move in i:
			if Global.occupied_index.has(move):

				if piece.data.color == "white":
					if Global.black_index.has(move):
						_attacks.append(move)
						break
					else:
						_friends.append(move)
						break

				elif piece.data.color == "black":
					if Global.white_index.has(move):
						_attacks.append(move)
						break
					else:
						_friends.append(move)
						break
			else:
				_empty.append(move)

	# update global piece moves
	piece.data.moves_empty = _empty
	piece.data.moves_attack = _attacks
	piece.data.moves_defend = _friends

	emit_signal("display_empty_moves", piece, _empty)
	emit_signal("display_attack_moves", piece, _attacks)
	emit_signal("display_defended_squares", piece, _friends)

func pawn_blockers(piece, moves):
	var _attacks = []
	var _friends = []
	var _empty = []
	var _final_moves = []
	var _legal_moves = []

	for i in moves[0]:
		if Global.occupied_index.has(i):
			_empty.append(i)

	for move in moves[1]:
		if Global.occupied_index.has(move):
			if piece.data.color == "white":
				if Global.black_index.has(move):
					_attacks.append(move)
				else:
					_friends.append(move)
			else:
				if Global.white_index.has(move):
					_attacks.append(move)
				else:
					_friends.append(move)

func get_rook_moves(piece, qmoves):
	var moves = []
	var moves_N = []
	var moves_E = []
	var moves_W = []
	var moves_S = []
	var rank = piece.data.row
	var file = piece.data.col
	var index = piece.data.index

	var s = 1
	var s2 = 1
	var _move

	for i in range(1, (rank+1)):
		_move = index + (Movement.N * i)
		if _move > -1 and _move < 64:
			moves_N.append(_move)

	for i in range((rank-1), 8):
		_move = (index + (Movement.S * s))
		if _move > -1 and _move < 64:
			moves_S.append(_move)
		s += 1

	for i in range(file, 7):
		_move = index + s2
		if _move > -1 and _move < 64:
			moves_E.append(_move)
		s2 += 1

	for i in range(0, file):
		_move = index - (i + 1)
		if _move > -1 and _move < 64:
			moves_W.append(_move)


	if piece.data.ptype == 4:
		qmoves.append(moves_N)
		qmoves.append(moves_S)
		qmoves.append(moves_E)
		qmoves.append(moves_W)
		slide_blockers(piece, qmoves)
		return qmoves
	else:
		moves.append(moves_N)
		moves.append(moves_S)
		moves.append(moves_E)
		moves.append(moves_W)
		slide_blockers(piece, moves)
		return moves

func get_knight_moves(piece):
	var bob_seger = [-17, -15, -10, -6, 6, 10, 15, 17]
	var moves = []
	var _attacks = []
	var _empty = []
	var _friends = []
	var index = piece.data.index

	for i in bob_seger:
		var _move =  index + i
		if _move > 0 and _move < 64:
			var column_diff = abs(_move % 8 - index % 8)
			var row_diff = abs(_move / 8 - index / 8)
			if column_diff <= 2 and row_diff <=2:
				moves.append(_move)

	for move in moves:
		if Global.occupied_index.has(move):
			if piece.data.color == "white":
				if Global.black_index.has(move):
					_attacks.append(move)
				else:
					_friends.append(move)
			else:
				if Global.white_index.has(move):
					_attacks.append(move)
				else:
					_friends.append(move)
		else:
			_empty.append(move)

	piece.data.moves_empty = _empty
	piece.data.moves_attack = _attacks
	piece.data.moves_defend = _friends

	emit_signal("display_empty_moves", piece, _empty)
	emit_signal("display_attack_moves", piece, _attacks)
	emit_signal("display_defended_squares", piece, _friends)
	return moves

func get_pawn_moves(piece):
	var pawn_moves = [-8, -16]
	var pawn_attacks = [-7, -9]
	var _move
	var _moves = []
	var _attacks = []
	var _friends = []
	var moves = []
	var index = piece.data.index

	# ADD EN PASSANT ATTACK
	if piece.data.color == "white":
		var move1 = piece.data.index + Movement.N
		if !Global.occupied_index.has(move1):
			_moves.append(move1)
		if piece.data.total_moves == 0:
			var move2 = piece.data.index + Movement.NN
			if !Global.occupied_index.has(move2):
				_moves.append(move2)

		var a = piece.data.index + Movement.NW
		var a2 = piece.data.index + Movement.NE

		if is_within_movsquare(index, a):
			if Global.occupied_index.has(a):
				if Global.black_index.has(a):
					_attacks.append(a)
				else:
					_friends.append(a)

		if is_within_movsquare(index, a2):
			if Global.occupied_index.has(a2):
				if Global.black_index.has(a2):
					_attacks.append(a2)
				else:
					_friends.append(a2)

	elif piece.data.color == "black":
		var move1 = piece.data.index + Movement.S
		if !Global.occupied_index.has(move1):
			_moves.append(move1)
		if piece.data.total_moves == 0:
			var move2 = piece.data.index + Movement.SS
			if !Global.occupied_index.has(move2):
				_moves.append(piece.data.index + Movement.SS)

		var a = piece.data.index + Movement.SW
		var a2 = piece.data.index + Movement.SE
		if is_within_movsquare(index, a):
			if Global.white_index.has(a):
				_attacks.append(a)
			elif Global.black_index.has(a):
				_friends.append(a)
		if is_within_movsquare(index, a2):
			if Global.white_index.has(a2):
				_attacks.append(a2)
			elif Global.black_index.has(a2):
				_friends.append(a2)

	moves.append(_moves)
	moves.append(_attacks)
	moves.append(_friends)

	piece.data.moves_empty = _moves
	piece.data.moves_attack = _attacks
	piece.data.moves_defend = _friends

	emit_signal("display_empty_moves", piece, _moves)
	emit_signal("display_attack_moves", piece, _attacks)
	emit_signal("display_defended_squares", piece, _friends)
	pawn_blockers(piece, moves)
	return moves

func is_within_movsquare(index, move):
	#print("checking ", index, " - ", move)
	var column_diff = abs(move % 8 - index % 8)
	if column_diff <= 1:
		#print('true')
		return true
	else: return false

func get_king_moves(piece):
	var _move
	var _moves = Movement.king
	var moves = []
	var _attacks = []
	var _empty = []
	var _friends = []
	var index = piece.data.index

	# find all possible moves
	for move in _moves:
		if piece.data.index + move > -1 and piece.data.index + move < 64:
			_move = piece.data.index + move
			var column_diff = abs(_move % 8 - index % 8)
			var row_diff = abs(_move / 8 - index / 8)
			if column_diff <= 1 and row_diff <= 1:
				moves.append(_move)

	# define the moves
	for move in moves:
		if Global.occupied_index.has(move):
			if piece.data.color == "white":
				if Global.black_index.has(move):
					_attacks.append(move)
				else:
					_friends.append(move)
			else:
				if Global.white_index.has(move):
					_attacks.append(move)
				else:
					_friends.append(move)
		else:
			_empty.append(move)

	# look for checks

	for i in _empty:
		if piece.data.color == "white":
			if Global.move_black.has(i):
				#print("global move black: ", Global.move_black)
				#print("found a square I can not move to: ", i)
				_empty.erase(i)
		elif piece.data.color == "black":
			if Global.move_white.has(i):
				_empty.erase(i)

	for i in _attacks:
		if piece.data.color == "white":
			if Global.defend_black.has(i):
				_attacks.erase(i)
		elif piece.data.color == "black":
			if Global.defend_white.has(i):
				_attacks.erase(i)


	emit_signal("display_empty_moves", piece, _empty)
	emit_signal("display_attack_moves", piece, _attacks)
	emit_signal("display_defended_squares", piece, _friends)

	piece.data.moves_empty = _empty
	piece.data.moves_attack = _attacks
	piece.data.moves_defend = _friends








	return moves

func find_blockers(piece, moves):
	var _attacks = []
	var _friends = []
	var _empty = []
	var _final_moves = []
	var _legal_moves = []

	# TODO FIX KNIGHT LOGIC at the top of the screen
	if piece.data.ptype == 1:
		for move in moves:
			if Global.occupied_index.find(move) > -1:
				if piece.data.color == "white":
					if Global.black_index.find(move) > -1:
						_attacks.append(move)
					#else:
						#_friends.append(move)
				else:
					if Global.white_index.find(move) > -1:
						_attacks.append(move)
					#else:
						#_friends.append(move)
			else:
				_empty.append(move)

	if piece.data.ptype == 2 or 3 or 4:
		for i in moves:
			for move in i:
				if Global.occupied_index.find(move) > -1:
					if piece.data.color == "white":
						if Global.black_index.find(move) > -1:
							_attacks.append(move)
							break
						else:
							#_friends.append(move)
							break
					else:
						if Global.white_index.find(move) > -1:
							_attacks.append(move)
							break
						else:
							#_friends.append(move)
							break
				else:
					_empty.append(move)

	# PAWN - TODO I think something is wrong here
	if piece.data.ptype == 0:
		for i in moves[0]:
			if Global.occupied_index.find(i) == -1:
				_empty.append(i)
		for move in moves[1]:
			if Global.occupied_index.find(move) > -1:
				if piece.data.color == "white":
					if Global.black_index.find(move) > -1:
						_attacks.append(move)
					#else:
						#_friends.append(move)
				else:
					if Global.white_index.find(move) > -1:
						_attacks.append(move)
					#else:
						#_friends.append(move)
	var threats = []

	if piece.data.ptype == 5:
		for move in moves:
			if Global.occupied_index.find(move) > -1:
				if piece.data.color == "white":
					#threats = find_my_checks("white")
					if Global.black_index.find(move) > -1:
						#print("found in black index: ", move)
						_attacks.append(move)
					else:
						_friends.append(move)
				else:
					#threats = find_my_checks("black")
					if Global.white_index.find(move) > -1:
						_attacks.append(move)
					else:
						_friends.append(move)
			else:
				#if !threats.has(move):
					_empty.append(move)

	_final_moves.append(_empty)
	_final_moves.append(_attacks)
	_final_moves.append(_friends)

	piece.data.legal_moves = _final_moves

	#show overlays if player is moving a piece
	if dragged_piece:
		emit_signal("show_overlay", piece, _final_moves)
	else:
		return _final_moves



func update_moves(piece):

	match piece.data.ptype:
		0:
			get_pawn_moves(piece)
		1:
			get_knight_moves(piece)
		2:
			get_bishop_moves(piece)
		3:
			get_rook_moves(piece, [])
		4:
			get_bishop_moves(piece)
		5:
			get_king_moves(piece)
			if piece.data.color == "white":
				Global.white_king_index = piece.data.index
			else:
				Global.black_king_index = piece.data.index

	for child in overlay.get_children():
		overlay.remove_child(child)


func find_my_checks(color):

	"""if color == "white":
		if Movement.black_moves.size() > 1:
			if Movement.black_moves_turn == Movement.last_black_move_check:
				emit_signal("check_overlay", color, Movement.black_moves)
				return
			else:
				Movement.black_moves = []"""


	var members = []
	var threat_moves = []
	if color == "white":
		members = get_tree().get_nodes_in_group("black")
	else:
		members = get_tree().get_nodes_in_group("white")

	var unique_moves = movement_bus(members)

	for arr in unique_moves:
		for i in range(0, arr.size()):
			for j in range(0, arr[i].size()):
				if !threat_moves.has(arr[i][j]):
					threat_moves.append(arr[i][j])

	# remove defense moves
	"""for i in threat_moves:
		if color == "white":
			if Global.black_index.has(i):
				threat_moves.erase(i)
		else:
			if Global.white_index.has(i):
				threat_moves.erase(i)"""

	emit_signal("check_overlay", color, threat_moves)
	#print(threat_moves)
	Movement.black_moves = threat_moves

#endregion

#region utility



func reset_dragged_piece(piece):
	dragged_piece_move_list = null
	dragged_piece_origin_coordinate = null
	dragged_piece_moves_checked = null
	dragged_piece = null


# help for grabbing all moves
func movement_bus(members):
	var all_moves = []
	var flat = []
	var unique_moves = []
	for member in members:

		match member.data.ptype:
			0:
				var _pawns = get_pawn_moves(member)
				var pawns = find_blockers(member, _pawns)
				all_moves.append(pawns)
			1:
				var _knights = get_knight_moves(member)
				var knights = find_blockers(member, _knights)
				all_moves.append(knights)
			2:
				var _bishops = get_bishop_moves(member)
				var bishops = find_blockers(member, _bishops)
				all_moves.append(bishops)
			3:
				var _rooks = get_rook_moves(member, [])
				var rooks = find_blockers(member, _rooks)
				all_moves.append(rooks)
			4:
				var _queens = get_bishop_moves(member)
				var queens = find_blockers(member, _queens)
				all_moves.append(queens)
			5:
				var _king = get_king_moves(member)
				var king = find_blockers(member, _king)
				all_moves.append(king)


	#flat = all_moves.flatten()
	#unique_moves = flat.unique()
	return all_moves















func snap_to_square(piece, square):
	#print("snap to square")
	piece.position = square
	reset_dragged_piece(piece)

func snap_to_nearest_square(piece):
	#print("before: ", piece.data.index)
	var nearest_data = find_nearest_square(piece)
	var _position = nearest_data[0]
	var _square_name = nearest_data[1]


	if _square_name != "":
		#FIXME needs better
		piece.position = _position

		## If the piece is placed in a different square
		if piece.position != dragged_piece_origin_coordinate:		#ALERT old code, rewrite with instances

			#print("before error: ", piece, "  ", piece.data.index, " - ", Global.pickedup_square, " - ", " dropped square: ", Global.dropped_square)
			Global.pickedup_square = piece.data.index
			piece.data.index = Global.dropped_square
			#print("after: ", piece.data.index)
			Global.update_piece_mask()


			## flag en passant if applicable
			if piece.data.type == 0:
				if piece.data.total_moves == 0:
					var distance_moved = abs(dragged_piece_origin_coordinate.y - piece.position.y)
					if distance_moved == Global.board_size * 2:
						piece.data.enpassant = true
						print("FLAG - vulnerable to en passant = true \n")
						piece.data.total_moves += 1
				elif piece.data.total_moves > 0:
					piece.data.enpassant = false
					print("FLAG - vulnerable to en passant = false \n")

			#HACK make sure this works as intended
			piece.data.total_moves += 1

			# UPDATE BOARD STATE


	play_sound("move_self")
	reset_dragged_piece(piece)
	emit_signal("mask_update")

#region starting board
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

	#print("Finshed mask: ", Global.piece_mask)

	#print("second try \n")


	#Movement.black_moves = $Pieces.find_my_checks("white")
	#Movement.white_moves = $Pieces.find_my_checks("black")
	Movement.last_black_move_check = 0.0
	Movement.last_white_move_check = 0.0

	#print("After board setupt, global moves: \n", Global.move_black, "\n", Global.move_white)
#endregion

func play_sound(type: String):
	match type:

		"move_self": sound_move_self.play()
		"capture": sound_capture.play()
		"click": sound_click.play()

func find_nearest_square(piece):
	var piece_position = piece.position
	var nearest_square_name = ""
	var nearest_distance = INF
	var nearest_position = Vector2()

	for square_name in GlobalUtility.dict_square_position.keys():
		var square_position = GlobalUtility.dict_square_position[square_name]
		var distance = piece_position.distance_to(square_position)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_square_name = square_name
			nearest_position = square_position

	emit_signal("set_target_square", nearest_position)
	return [nearest_position, nearest_square_name]

#endregion

func get_piece_moves(piece, position):
	pass

#region bit
func check_legal_moves(piece):

	var _index = piece.data.index

	Global.create_attack_array(piece)

	if piece.data.ptype == 0:
		if piece.data.color == "white":

			# grab it's index data
			var _row = piece.data.row
			var _col = piece.data.col
			var searchrow = piece.data.row - 1
#endregion

#region creation
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

	var piece_resource = load("res://Scripts/piece_resource.gd")
	var _piece = piece_resource.new(unit, color, transpose)
	_piece.position = pos
	_piece.row = i_rank
	_piece.col = i_file
	_piece.square = str(GlobalUtility.get_value_from_key(GlobalUtility.dict_square_position, pos))

	var piece_instance = piece_scene.instantiate()
	piece_instance.data = _piece
	piece_instance.position = pos
	add_child(piece_instance)

	piece_instance.add_to_group("pieces")
	if color == "white":
		piece_instance.add_to_group("white")
	else:
		piece_instance.add_to_group("black")

	var area2d = piece_instance.get_node("Area2D")
	if area2d:
		area2d.connect("input_event", Callable(self, "_on_piece_clicked").bind(piece_instance))
		area2d.connect("mouse_entered", Callable(self, "_on_piece_hovered").bind(piece_instance))
		area2d.connect("mouse_exited", Callable(self, "_on_piece_unhovered").bind(piece_instance))

	#piece_instance.connect("area_entered", Callable(self, "_on_area_entered").bind(piece_instance))
	#piece_instance.connect("area_exited", Callable(self, "_on_area_exited").bind(piece_instance))

	#ADD INDEX

func _on_area_entered(area):
	print("entered ", area)

#endregion


func get_bishop_moves_old(piece):
	var moves = []
	var rank = piece.data.row
	var file = piece.data.col
	var index = piece.data.index
	var bishop_moves = [ 7, 9, 14, 18, 21, 27, 28, 35, 36, 42, 45, 54, 56, 63]

	for move in bishop_moves:
		var next_index = index + move
		if is_valid_move(index, next_index):
			moves.append(next_index)

		next_index = index - move
		if is_valid_move(index, next_index):
			moves.append(next_index)

	emit_signal("show_overlay", piece, moves)
	#print("bishop 1 moves: ", moves)
	return moves

func is_valid_move(start_index: int, target_index: int) -> bool:

	if target_index < 0 or target_index > 63:
		return false

	var start_rank = start_index / 8
	var start_file = start_index % 8
	var target_rank = target_index / 8
	var target_file = target_index % 8

	return abs(start_rank - target_rank) == abs(start_file - target_file)

func _on_button_toggled(toggled_on: bool):
	var members = get_tree().get_nodes_in_group("black")
	Global.move_black = []
	Global.attack_black = []
	Global.defend_black = []
	for member in members:
		update_moves(member)
	#TEST redo for just the squares around the king
	if toggled_on:
		emit_signal("king_check", "white", "black")
	else:
		emit_signal("clear_overlay")

func _on_button_2_toggled(toggled_on: bool):
	var members = get_tree().get_nodes_in_group("white")
	Global.move_white = []
	Global.attack_white = []
	Global.defend_white = []
	for member in members:
		update_moves(member)
	#TEST redo for just the squares around the king
	if toggled_on:
		emit_signal("king_check", "black", "white")
	else:
		emit_signal("clear_overlay")

func _on_pixelate_toggled(toggled_on: bool):
	if toggled_on:
		for child in get_children():
			child.material = pixel_shader
	else:
		for child in get_children():
			child.material = null

	pass # Replace with function body.

func _on_vibrate_pressed():
	var _piece = Global.selected_piece

	#print(_piece)
	if _piece != null:
		for child in _piece.get_children():
			if child is ColorRect:
				#print("found colorrect")
				child.visible = true
				child.custom_minimum_size = Vector2(150, 150)
				child.MOUSE_FILTER_IGNORE
				child.material = vibrate_shader
