extends Node

@onready var highlight = preload("res://Images/Squares/WhiteSquare-Green.png")
@onready var enemy = preload("res://Images/Squares/WhiteSquare-Enemy.png")
@onready var friend = preload("res://Images/Squares/WhiteSquare-Friend.png")
@onready var last_move = preload("res://Images/Squares/Current_Move.png")
@onready var greenbox = preload("res://Images/Squares/Working/Light-GreenHighlight.png")

#animations
@onready var fire = preload("res://SquareMods/Square_Fire.tscn")

var pieces = load('res://Scenes/pieces.tscn')
var link_polygon : Polygon2D
var link_polygon_head : Polygon2D
#@onready var green = preload()

var move_colors = [highlight, enemy, friend, last_move]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	$"../Pieces".connect("show_overlay", Callable(self, "display_moves"))
	$"../Pieces".connect("clear_overlay", Callable(self, "clear_overlay"))
	$"../Pieces".connect("check_overlay", Callable(self, "check_overlay"))
	$"../Pieces".connect("display_attack_moves", Callable(self, "display_attack_moves"))
	$"../Pieces".connect("display_empty_moves", Callable(self, "display_empty_moves"))
	$"../Pieces".connect("display_defended_squares", Callable(self, "display_defended_squares"))
	$"../Pieces".connect("king_check", Callable(self, "king_check"))


	#test

	pass # Replace with function body.

func display_moves(piece, moves):
	#print("in display moves ", piece.data.ptype, " - ", moves)

	var _green = TextureRect.new()
	_green.texture = highlight

	#var _colorrect = ColorRect.new()

	if moves[0] != null and moves[0].size() > 0:
		for i in moves[0]:
			#print("in moves[0] looking at ", i)
			var _position = Vector2(Global.square_coordinates[i][0], Global.square_coordinates[i][1])
			var _overlay = create_overlay_rect("green", _position)
			#print("position: ", _position)
			_overlay.position = _position
			add_child(_overlay)

	if moves[1] != null:
		for i in moves[1]:
			var _position = Vector2(Global.square_coordinates[i][0], Global.square_coordinates[i][1])
			var _overlay = create_overlay_rect("red", _position)
			#print("position: ", _position)
			_overlay.position = _position
			add_child(_overlay)


func display_empty_moves(piece, moves):
	var piece_color

	if piece is String:
		piece_color = piece
	else:
		piece_color = piece.data.color

	for i in moves:
		var _position = Vector2(Global.square_coordinates[i][0], Global.square_coordinates[i][1])
		var _overlay = create_overlay_rect("green", _position)
		_overlay.position = _position
		add_child(_overlay)



	if piece_color == "white" and !piece.data.ptype == 0:
		for move in moves:
			if !Global.move_white.has(move):
				Global.move_white.append(move)
	elif piece_color == "black" and !piece.data.ptype == 0:
		for move in moves:
			if !Global.move_black.has(move):
				Global.move_black.append(move)

func display_attack_moves(piece, moves):
	var piece_color

	if piece is String:
		piece_color = piece
	else:
		piece_color = piece.data.color

	#print("the moves the attack overlay gets ", piece.data.index, "  ", moves)
	for i in moves:
		var _position = Vector2(Global.square_coordinates[i][0], Global.square_coordinates[i][1])
		var _overlay = create_overlay_rect("red", _position)
		_overlay.position = _position
		add_child(_overlay)

		draw_arrow(piece, _position, "red")


	if piece_color == "white":
		for move in moves:
			if !Global.attack_white.has(move):
				Global.attack_white.append(move)
	elif piece_color == "black":
		for move in moves:
			if !Global.attack_black.has(move):
				Global.attack_black.append(move)

func display_defended_squares(piece, moves):
	var _position
	var piece_color
	if piece is String:
		piece_color = piece
	else:
		piece_color = piece.data.color

	for i in moves:
		_position = Vector2(Global.square_coordinates[i][0], Global.square_coordinates[i][1])
		var _overlay = create_overlay_rect("blue", _position)
		_overlay.position = _position
		add_child(_overlay)
		draw_arrow(piece, _position, "blue")

	if piece_color == "white":
		for move in moves:
			if !Global.defend_white.has(move):
				Global.defend_white.append(move)
	elif piece_color == "black":
		for move in moves:
			if !Global.defend_black.has(move):
				Global.defend_black.append(move)

func clear_overlay():
	for o in self.get_children():
		remove_child(o)

# TODO elimiante pawn moves as non-options
func king_check(color, enemy):
	var nearby = []
	var key = "%s_king_index" % color
	var move_key = "move_%s" % enemy
	var attack_key = "attack_%s" % enemy
	var king = Global.get(key)
	var danger_moves = Global.get(move_key)
	var attack_moves = Global.get(attack_key)
	var vuln_squares = Global.move_map[color]
	var restricted_squares = []

	#print("checking the ", color, " king.  At index ", king)
	#print("king index: ", king, " - ", Global.white_king_index)
	#print("Danger moves for black: ", danger_moves)
	for move in Movement.king:
		var square = king + move
		#print("square to evaluate for future check: ", square)
		if square > -1 or square < 64:
			if danger_moves.has(square):
				restricted_squares.append(square);

	if attack_moves.has(king):
		print("KING IS IN CHECK")




	#print("King check white: ", restricted_squares)

	return restricted_squares
	# add some fire


	for i in restricted_squares:
		var _position = Vector2(Global.square_coordinates[i][0], Global.square_coordinates[i][1])
		var addfire = fire.instantiate()
		addfire.position = _position
		add_child(addfire)

func create_overlay_rect(color, position):
	var _texturerect = TextureRect.new()
	_texturerect.size = Vector2(150, 150)

	if color == "green":
		_texturerect.texture = highlight
		#_texturerect.texture = greenbox

	elif color == "red":
		_texturerect.texture = enemy

	elif color == "blue":
		_texturerect.texture = friend

	var _alpha = _texturerect.modulate
	_alpha.a = .50
	_texturerect.modulate = _alpha
	return _texturerect

func check_overlay(color, moves):

	for i in moves:
		var _position = Vector2(Global.square_coordinates[i][0], Global.square_coordinates[i][1])
		var _overlay = create_overlay_rect("red", _position)
		_overlay.position = _position
		add_child(_overlay)

func update_board():
	var board = $Board


func draw_arrow(piece1, piece2, color):
	var _pos_b
	var offset_b = Vector2(75, 75)
	var offset_a = Vector2(75, 75)
	var arrowhead_length = 40

	link_polygon = Polygon2D.new()
	link_polygon_head = Polygon2D.new()

	#ALERT fix this
	if piece2 != null:
		var _pos_a = Vector2(Global.square_coordinates[piece1.data.index][0], Global.square_coordinates[piece1.data.index][1]) + offset_a
		if piece2 is Vector2:
			#_pos_b = piece2 + offset
			_pos_b = piece2 + offset_b
		else:
			_pos_b = Vector2(Global.square_coordinates[piece2.data.index][0], Global.square_coordinates[piece2.data.index][1]) + offset_b

		var link_width = 30
		var direction = (_pos_a - _pos_b).normalized()

		var perpendicular = Vector2(-direction.y, direction.x) * (link_width / 2)
		var vertices = [
		_pos_a + perpendicular,  # Top-left corner
		_pos_a - perpendicular,  # Bottom-left corner
		_pos_b - perpendicular,  # Bottom-right corner
		_pos_b + perpendicular,  # Top-right corner
		]

		link_polygon.polygon = vertices

		if color == "orange":
			link_polygon.color = Color.ORANGE
		elif color == "blue":
			link_polygon.color = Color.CORNFLOWER_BLUE
		elif color == "red":
			link_polygon.color = Color.LIGHT_CORAL

	 # --- TRIANGLE ARROWHEAD CALCULATION ---
	# Calculate the arrowhead (triangle) at the end
		var arrow_tip = _pos_b + direction * arrowhead_length  # The tip of the arrow
		var arrow_base_left = _pos_b + perpendicular * 2  # Left base of the arrowhead
		var arrow_base_right = _pos_b - perpendicular * 2  # Right base of the arrowhead

	# Set the polygon's vertices for the arrowhead (triangle)
		link_polygon_head.polygon = [arrow_base_left, arrow_tip, arrow_base_right]
	#add_child(link_polygon_head)
		add_child(link_polygon)


func _on_button_3_pressed():
	clear_overlay()
