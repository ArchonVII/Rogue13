extends Node


# board constants
@export var board_size = 64
@export var square_size = 150

@export var board = []

#region bit
# bit wise masks
@export var starting_board_mask = [
	11111111,
	11111111,
	00000000,
	00000000,
	00000000,
	00000000,
	11111111,
	11111111
	]
@export var starting_board_pieces = [
	53467435,
	22222222,
	00000000,
	00000000,
	00000000,
	00000000,
	11111111,
	53467435]
@export var starting_board_piece_mask = [
	11111111,
	11111111,
	00000000,
	00000000,
	00000000,
	00000000,
	11111111,
	11111111]
@export var piece_mask = [
	0b00000000,
	0b00000000,
	0b00000000,
	0b00000000,
	0b00000000,
	0b00000000,
	0b00000000,
	0b00000000]

# board data by number
@export var board_index = []
@export var occupied_index = []
@export var empty_index = []
@export var white_index = []
@export var black_index = []


@export var move_black = []
@export var move_white = []
var move_map = {"white": move_white, "black": move_black}

@export var attack_black = []
@export var attack_white = []
var attack_map = {"white": attack_white, "black": attack_black}

var defend_black = []
var defend_white = []
var defend_map = {"white": defend_white, "black": defend_black}

var white_king_index : int
var black_king_index : int
var king_index_map = {"white": white_king_index, "black": black_king_index}

var white_in_check = false
var black_in_check = false


#endregion
# assignments for moving and monitoring
@export var dragged_piece = null
@export var pickedup_square = null
@export var dropped_square = null
@export var pickedup_piece = null
@export var hovered_square = null

var selected_piece = null

# global restrictions
@export var free_movement = false
@export var free_turn = true

var square_coordinates = [
	[0, 0], [150, 0], [300, 0], [450, 0], [600, 0], [750, 0], [900, 0], [1050, 0],
	[0, 150], [150, 150], [300, 150], [450, 150], [600, 150], [750, 150], [900, 150], [1050, 150],
	[0, 300], [150, 300], [300, 300], [450, 300], [600, 300], [750, 300], [900, 300], [1050, 300],
	[0, 450], [150, 450], [300, 450], [450, 450], [600, 450], [750, 450], [900, 450], [1050, 450],
	[0, 600], [150, 600], [300, 600], [450, 600], [600, 600], [750, 600], [900, 600], [1050, 600],
	[0, 750], [150, 750], [300, 750], [450, 750], [600, 750], [750, 750], [900, 750], [1050, 750],
	[0, 900], [150, 900], [300, 900], [450, 900], [600, 900], [750, 900], [900, 900], [1050, 900],
	[0, 1050], [150, 1050], [300, 1050], [450, 1050], [600, 1050], [750, 1050], [900, 1050], [1050, 1050]]

func _ready() -> void:
	# create 0-63 index array and also add to empty index array
	for i in range(0, board_size):
		board_index.append(i)
		empty_index.append(i)





#region bit wise

# place the piece bitwise
func set_piece(row: int, col: int):
	piece_mask[row] |= (1 << ( 8- col))

# get the index of a Vector 2
func get_dex(x, y):
	var place = (8 * x) + y
	return place

func create_attack_array(piece):

	var row = piece.data.row
	var col = piece.data.col

	if piece.data.type == 0:
		if piece.data.color == "white":

			var attackrow = 0b00000000
			attackrow |= (1 << (7 - col + 1))
			attackrow |= (1 << (7 - col - 1))
			#print("attack row: ", attackrow)
			#print("attack row: ", ("%08d" % int(String.num_int64(attackrow, 2))))

func update_data():
	pass

func update_piece_mask():
	var starting = pickedup_square
	var ending = dropped_square

	var pickedup_row = Global.pickedup_square / 8  # Get the row (rank)
	var pickedup_col = Global.pickedup_square % 8  # Get the column (file)

	var dropped_row = Global.dropped_square / 8  # Get the row (rank)
	var dropped_col = Global.dropped_square % 8  # Get the column (file)

	print("pickedup square: ", pickedup_square, " - dropped square: ", dropped_square)
	print("checking update mask data, ", pickedup_row, ", ", pickedup_col, " - ", dropped_row, ", ", dropped_col)
	# Clear the pickedup_square bit in piece_mask (set it to 0)
	piece_mask[pickedup_row] &= ~(1 << (7 - pickedup_col))  # Clear the specific bit

	# Set the dropped_square bit in piece_mask (set it to 1)
	piece_mask[dropped_row] |= (1 << (7 - dropped_col))  # Set the specific bit

	# Optionally, you can print the updated piece_mask for debugging
	for row in piece_mask:
		print("%09d" % int(String.num_int64(row, 2)))  # Print binary representation of each row
#endregion
