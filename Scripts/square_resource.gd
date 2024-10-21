extends Resource

class_name Square

enum SquareColor { LIGHT, DARK }
enum PieceColor { WHITE, BLACK }

# index variables
@export var index : int
@export var col : int
@export var row : int

# position variables
@export var position : Vector2

# board variables
@export var name : String
@export var rank : int
@export var file : String
@export var color : SquareColor

# state variables
@export var occupied: bool
@export var piece = null
@export var piece_color : PieceColor

# check variables
@export var check_has_king : bool
@export var has_king_white : bool
@export var has_king_black : bool
@export var check_is_king_attack_vector : bool

# may not need
@export var vision_white : Array
@export var vision_black : Array

# bit variables - could delete
@export var pmask : int
@export var move_mask : int
@export var i_index : int

var file_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']

func _init(index: int, position: Vector2):

	self.index = index
	self.position = position
	self.name = GlobalUtility.square_names[index]

	self.rank = index / 8
	self.row = index / 8
	self.col = index % 8
	self.file = file_names[self.col]
	self.position = position

	# states or global updates
	self.occupied = false





	# set vertices for arrows?
