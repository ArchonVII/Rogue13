extends Resource

class_name Piece

enum SideColor { WHITE, BLACK }
enum PieceList { NONE, PAWN, KNIGHT, BISHOP, ROOK, QUEEN }
enum Unit { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
enum State { ALIVE, DEAD, ACTIVE, INACTIVE, FROZEN, SPECIAL, RARE, OVERWHELMED, MODIFIED }
enum CheckStatus { NONE, CHECKED, CHECKING, PINNED, PINNING }

@export var ID : String
@export var name : String
@export var color : String
@export var type : Unit
@export var texture : Texture2D

@export var ptype : int
@export var index : int
@export var row : int
@export var col : int

@export var standard_moves : Array
@export var standard_attacks : Array
@export var legal_moves : Array

@export var all_moves : Array
@export var moves_empty: Array
@export var moves_defend : Array
@export var moves_attack : Array
@export var attacked_by : Array
@export var total_moves = 0



@export var givenfirstname : String
@export var givenlastname : String
@export var country : String
@export var cflag : Texture




@export var square : String
@export var position : Vector2
@export var previous_square : String
@export var previous_position : Vector2
@export var target : Vector2
@export var state : State
@export var checkstatus : CheckStatus
@export_multiline var description : String
@export var pinned : bool
@export var pinned_to : Vector2
@export var first_move = true
@export var has_promoted = false
@export var promoted_piece : PieceList
@export var enpassant = false
@export var enpassant_position : Vector2



# textures
@export var white_pawn_texture = preload("res://Images/Pieces/wp.png")
@export var black_pawn_texture = preload("res://Images/Pieces/bp.png")
@export var white_rook_texture = preload("res://Images/Pieces/wr.png")
@export var black_rook_texture = preload("res://Images/Pieces/br.png")
@export var white_bishop_texture = preload("res://Images/Pieces/wb.png")
@export var black_bishop_texture = preload("res://Images/Pieces/bb.png")
@export var white_knight_texture = preload("res://Images/Pieces/wn.png")
@export var black_knight_texture = preload("res://Images/Pieces/bn.png")
@export var white_queen_texture = preload("res://Images/Pieces/wq.png")
@export var black_queen_texture = preload("res://Images/Pieces/bq.png")
@export var white_king_texture = preload("res://Images/Pieces/wk.png")
@export var black_king_texture = preload("res://Images/Pieces/bk.png")


func _init(piece_type : int, color: String, index: int):

	#self.piece_type = piece_type
	self.ptype = piece_type
	self.color = color
	self.index = index
	Global.occupied_index.append(index)

	if color == "white":
		Global.white_index.append(index)
	else:
		Global.black_index.append(index)

	match ptype:
		Unit.PAWN:
			self.name = "Pawn"
			if color == "white":
				texture = white_pawn_texture
				standard_moves = [Vector2(0,-1), Vector2(0,-2)]
				standard_attacks = [Vector2(1,-1), Vector2(-1,-1)]
				enpassant_position = Vector2(0,1)

				# adding binary
			else:
				texture = black_pawn_texture
				standard_moves = [Vector2(0,1), Vector2(0,2)]
				standard_attacks = [Vector2(1,1), Vector2(-1,1)]
				enpassant_position = Vector2(0,-1)

		Unit.KNIGHT:
			self.name = "Knight"
			standard_moves = [Vector2(1, 2), Vector2(1, -2), Vector2(-1, 2), Vector2(-1, -2), Vector2(2, 1), Vector2(2, -1), Vector2(-2, 1), Vector2(-2, -1)]
			if color == "white":
				texture = white_knight_texture
			else:
				texture = black_knight_texture

		Unit.BISHOP:
			self.name = "Bishop"
			standard_moves = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
			if color == "white":
				texture = white_bishop_texture
			else:
				texture = black_bishop_texture

		Unit.ROOK:
			self.name = "Rook"
			standard_moves = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
			if color == "white":
				texture = white_rook_texture
			else:
				texture = black_rook_texture

		Unit.QUEEN:
			self.name = "Queen"
			standard_moves = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
			if color == "white":
				texture = white_queen_texture
			else:
				texture = black_queen_texture

		Unit.KING:
			self.name = "King"
			standard_moves = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
			if color == "white":
				Global.white_king_index = index
				texture = white_king_texture
			else:
				texture = black_king_texture
				Global.black_king_index = index

	# Personal Data
	var nm = load("res://TestFolder/names.gd")
	var names = nm.new()
	var rng = RandomNumberGenerator.new()
	var choice = rng.randi() % 2

	if choice == 0:
		self.givenfirstname = names.get_random_name_from_file("female")
		self.givenlastname = names.get_random_name_from_file("last")
	else:
		self.givenfirstname = names.get_random_name_from_file("male")
		self.givenlastname = names.get_random_name_from_file("last")

	self.country = names.get_random_name_from_file("country")
	var gflag = names.get_flag_image(self.country)
	var cflagget = load("res://Assets/Character/Countries/" + str(gflag))
	self.cflag = cflagget
