extends Resource

class_name Square

enum SquareColor { LIGHT, DARK }
enum PieceColor { WHITE, BLACK }

@export var name : String
@export var position : Vector2
@export var rank : int
@export var file : String
@export var color : SquareColor


@export var piece = null
@export var piece_color : PieceColor
@export var vision_white : Array
@export var vision_black : Array

@export var king_white : bool
@export var king_black : bool


@export var index : int
@export var occupied: bool
@export var pmask : int
@export var move_mask : int
@export var col : int
@export var row : int
@export var i_index : int

var file_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']

func _init(index: int, position: Vector2):
	self.index = index
	self.position = position
	self.name = name
	self.occupied = false
	self.name = GlobalUtility.square_names[index]
	self.position = position

	self.rank = index / 8
	self.row = index / 8
	self.col = index % 8
	self.file = file_names[self.col]
