extends Node

var main_node

var dragged_piece = null
var is_dragging = null
var dragged_piece_move_list = null
var dragged_piece_origin_coordinate = null
var dragged_piece_moves_checked = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_main_node(node):
	main_node = node

func _process(delta):
	if main_node == null:
		main_node = $Pieces
	if main_node:
		print("main node is true")
		if is_dragging and dragged_piece:
			# HACK could mess it up
			if !dragged_piece_move_list and !dragged_piece_moves_checked:

				if Global.free_movement == false:
					#dragged_piece_move_list = get_moves(dragged_piece)
					dragged_piece_origin_coordinate = dragged_piece.position

					# ADD OTHER MOVES
					"""if dragged_piece_move_list.size() > 0:
						for i in dragged_piece_move_list:

							# TODO - shade difference for colored squares or just alphas

							#var move_test = evaluate_moves(i, dragged_piece.color)
							var move_hl = TextureRect.new()

							#if move_test == "empty":
								## en passant check
								#if dragged_piece.type == "pawn" and i[0] != dragged_piece.position.x:
									#move_hl.texture = HL_white_enemy
								#else:
									#move_hl.texture = HL_white_green



								(dragged_piece.legal_moves).append(i)
							elif move_test == "friend":
								move_hl.texture = HL_white_friend
							elif move_test == "enemy":
								move_hl.texture = HL_white_enemy
								(dragged_piece.legal_moves).append(i)

							var current_alpha = move_hl.modulate
							current_alpha.a = 0.75
							move_hl.modulate = current_alpha
							move_hl.position = i
							overlay.add_child(move_hl)"""

				dragged_piece_moves_checked = true

		var offset = Global.Gsquare_width * 0.5
		var globalpos = main_node.get_global_mouse_position() * 1.75
		# HACK changed mouse position
		dragged_piece.position = (main_node.get_global_mouse_position() * 2) - Vector2(offset, offset)


func _on_piece_clicked(_viewport, event, _shape_idx, piece):

	print("main node ", main_node)
	if event is InputEventMouseButton:
		if event.pressed and not is_dragging:

			# Start dragging
			is_dragging = true
			dragged_piece = piece
		elif not event.pressed and is_dragging:

			# Stop dragging
			is_dragging = false


			check_legal_moves(dragged_piece)

			# check if piece is allowed to move
			if Global.free_movement:
				snap_to_nearest_square(dragged_piece)
			else:
				#if check_legal_moves(dragged_piece):
				snap_to_nearest_square(dragged_piece)

				#else:
					#snap_to_square(dragged_piece, dragged_piece_origin_coordinate)

			dragged_piece = null


func check_legal_moves(piece):

	print(piece, "\n", piece.data.index)





#region utility

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

func snap_to_square(piece, square):
	piece.position = square
	reset_dragged_piece(piece)
	#for i in overlay.get_children():
		#overlay.remove_child(i)

func snap_to_nearest_square(piece):
	var nearest_position = find_nearest_square(piece)


func reset_dragged_piece(piece):
	dragged_piece_move_list = null
	dragged_piece_origin_coordinate = null
	dragged_piece_moves_checked = null
	piece.legal_moves = []
	dragged_piece.legal_moves = []
	dragged_piece = null
#endregion

#region hovered
func _on_piece_hovered(piece):
	print("Piece hovered ", piece, " - ", piece.data.square)


func _on_piece_unhovered(piece):
	pass
#endregion
