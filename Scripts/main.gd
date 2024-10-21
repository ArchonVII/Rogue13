extends Node2D

@onready var labels = $Control
@onready var label2 = $VBoxContainer
@onready var overlay = $Overlay
@onready var pieces = $Pieces

var label_nodes = []

signal update_moves

func _ready():
	$Pieces.set_starting_board()

	$Pieces.connect("piece_index_label", Callable(self, "_update_Pindex"))
	$Board.connect("square_index_label", Callable(self, "_update_Sindex"))
	$Pieces.connect("set_target_square", Callable(self, "_set_target_square"))
	$Pieces.connect("piece_placed", Callable(self, "_piece_placed"))
	$Pieces.connect("update_turn", Callable(self, "_update_turn"))

	# Initalize starting moves
	for child in pieces.get_children():

		match child.data.ptype:
			0:
				pieces.get_pawn_moves(child)
			1:
				pieces.get_knight_moves(child)
			2:
				pieces.get_bishop_moves(child)
			3:
				pieces.get_rook_moves(child, [])
			4:
				pieces.get_bishop_moves(child)
			5:
				pieces.get_king_moves(child)
				if child.data.color == "white":
					Global.white_king_index = child.data.index
				else:
					Global.black_king_index = child.data.index

	# clear overlay
	for child in overlay.get_children():
		overlay.remove_child(child)


func _update_Pindex(piece):
	$Index_Piece.text = "Piece Index: " + str(piece.data.index)
	Global.pickedup_piece = piece

func _update_Sindex(square):
	$Index_Square.text = "Square Index: " + str(square.data.index)
	Global.hovered_square = square

func _piece_placed(piece, square):

	var new_index = square.data.index
	var old_index = piece.data.index

	# update occupied and empty array
	Global.occupied_index.erase(old_index)
	Global.occupied_index.append(new_index)
	Global.empty_index.erase(new_index)
	Global.empty_index.append(old_index)

	# update piece array
	if piece.data.color == "white":
		#print("updating ", piece.data.ptype, " from and to ", old_index, " - ", new_index)
		Global.white_index.erase(old_index)
		Global.white_index.append(new_index)
		#print("Global.white_index ", Global.white_index, "\n")
	if piece.data.color == "black":
		#print("updating ", piece.data.ptype, " from and to ", old_index, " - ", new_index)
		Global.black_index.erase(old_index)
		Global.black_index.append(new_index)
		#print("Global.black_index ", Global.black_index, "\n")

	# update piece data
	piece.data.index = new_index
	piece.data.row = new_index / 8
	piece.data.col = new_index % 8
	piece.data.legal_moves = []

	var movecheck = Global.pickedup_square
	if piece.data.index != movecheck.data.index:
		piece.data.total_moves += 1

	emit_signal("update_moves", piece)

	# update square data
	square.data.piece = piece

	# update turn
	if piece.data.color == "white":
		Movement.white_moves_turn += 0.5
	else:
		Movement.black_moves_turn += 0.5

func _update_turn():
	if Global.turn_color_is == "white":
		Global.turn_color_is = "black"
		$Turn.text = "Black"
	else:
		Global.turn_color_is = "white"
		$Turn.text = "White"

#region bitmask
func create_mask_labels():
	#print("creating mask labels")

	var label_container = VBoxContainer.new()
	label_container.size_flags_vertical = $Control.SIZE_EXPAND_FILL
	label_container.size_flags_horizontal = $Control.SIZE_EXPAND_FILL
	$Control.scale = Vector2(2.25, .75)
	$Control.add_child(label_container)

	"""var l2 = VBoxContainer.new()
	l2.size_flags_vertical = $VBoxContainer.SIZE_EXPAND_FILL
	l2.size_flags_horizontal = $VBoxContainer.SIZE_EXPAND_FILL
	$VBoxContainer.add_child(l2)"""



	for i in range(Global.piece_mask.size()):
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		#label.fit_content_height = true  # Ensures the label height fits its content
		label_nodes.append(label)
		label_container.add_child(label)
		update_label(i)  # Update the label text and color

func update_label(row_index: int):
	var row_value = Global.piece_mask[row_index] & 0xFF  # Ensure it's an 8-bit value
	#var binary_str = String.num_int64(row_value, 2)#.left(-1)
	var binary_str = (("%08d" % int(String.num_int64(row_value, 2))))
	# Construct BBCode string for binary representation
	var colored_text = ""
	for char in binary_str:
		var space = ""
		if char == "1":
			colored_text += "[color=green]" + char + "[/color]"
		else:
			colored_text += "[color=red]" + char + "[/color]"

	#colored_text += "[size=4]_[/size]"

	# Set the bbcode_text to the RichTextLabel
	var label = label_nodes[row_index]
	#print("index: ", row_index, " colored text: ", colored_text)

	label.bbcode_text = colored_text
	# Use RichTextLabel or BBCode in the Label node

func second():

	for row in Global.piece_mask:
		var binary_str = (("%08d" % int(String.num_int64(row, 2))))
		var spaced_str = ""
		for bit in binary_str:
			spaced_str += bit + "    "
			#print("spaced ", spaced_str)

		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true
		label.bbcode_text = spaced_str
		label2.add_child(label)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _mask_update():
#endregion
