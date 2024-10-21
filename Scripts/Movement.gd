extends Node


var NE = -7
var NW = -9
var SE = 7
var SW = 9
var N = -8
var S = 8
var NN = -16
var SS = 16

var knight = [-17, -15, -10, -6, 6, 10, 15, 17]
var king = [-9, -8, -7, -1, 1, 7, 8, 9]

var turn : float
var white_moves_turn : float
var black_moves_turn : float

var last_black_move_check : float
var last_white_move_check : float

var white_moves = []
var black_moves = []

func _init():
	white_moves_turn = 0.0
	black_moves_turn = 0.0
	turn = 0.0

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
