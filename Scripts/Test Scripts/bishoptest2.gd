extends Node



var bishop_all = [ 7, 9, 14, 18, 21, 27, 28, 35, 36, 42, 45, 54, 56, 63]
var square_val = .125
var rank
var file
# test parameters
var index = 37
var origin
var moves = []

func _ready():

	#start_move(index)
	get_bishop_moves(index)

func start_move(index):

	var piece = get_rank_file(index)
	var move

	for i in range(0, bishop_all.size()):
		move = index + bishop_all[i]
		if move < 64 :
			moves.append(move)
		else:
			break

	for i in range(0, bishop_all.size()):
		print("i ", i , " bishop all value ", bishop_all[i])
		move = index - bishop_all[i]

		var filetest = move % 8
		if move > 0:
			if (move - 2) % 8 != 0:
				print("\n added move: ", move)
				moves.append(move)

	print(moves)


func get_rank_file(index):
	file = (fmod(float(index)/8.0,1)/.125)
	rank = float(index/8)
	return [file, rank]

func test2():

	var piece = get_rank_file(index)
	var move
	for i in range(0, bishop_all.size()):
		move = index + bishop_all[i]
		if move < 64 :
			moves.append(move)
		else:
			break

	for i in range(0, bishop_all.size()):
		print("i ", i , " bishop all value ", bishop_all[i])
		move = index - bishop_all[i]

		if move > 0:
			var factor : float
			factor = index + (8 - piece[0])
			var movedata = get_rank_file(move)
			var check : int
			check = factor - (movedata[0] * 8.0)
			print("move: ", " checK ", check)
			print(check % 8)
			#if check % 8 == 0:
				#print("invalid move ", move)
			#else:
			moves.append(move)

	print(moves)

func test3():

	var piece = get_rank_file(index)
	var move
	var negstop

	for i in range(0, bishop_all.size()):
		move = index + bishop_all[i]
		if move < 64 :
			moves.append(move)
		else:
			negstop = i - 1
			break

	print("NEGSTOP: ", negstop )

	for i in range(0, bishop_all.size()):
		print("i ", i , " bishop all value ", bishop_all[i])
		move = index - bishop_all[i]

		if move > 0:
			if i != negstop:
				var factor : float
				factor = index + (8 - piece[0])
				var movedata = get_rank_file(move)
				var check : int
				check = factor - (movedata[0] * 8.0)
				print("move: ", " checK ", check)
				print(check % 8)
				#if check % 8 == 0:
					#print("invalid move ", move)
				#else:
				moves.append(move)

	print(moves)

"""func test4():

	rank = index / 8
	file = index % 8
	print(file, rank)

	var temp_index = index

	while true:
		var next_index = temp_index + bishop_all
		var next_rank = next_index / 8
		var next_file = next_index % 8

		if next_index < 0 or next_index > 63:
			break

		if abs(next_rank - rank) != abs(next_file - file):
			break

		moves.append(next_index)
		temp_index = next_index

	print(moves)"""


func get_bishop_moves(index: int):

	rank = index / 8
	file = index % 8
	var bishop_moves = [ 7, 9, 14, 18, 21, 27, 28, 35, 36, 42, 45, 54, 56, 63]

	for move in bishop_moves:

		var next_index = index + move
		if is_valid_move(index, next_index):
			moves.append(next_index)

		next_index = index - move
		if is_valid_move(index, next_index):
			moves.append(next_index)

	print(moves)
	return moves

func is_valid_move(start_index: int, target_index: int) -> bool:

	if target_index < 0 or target_index > 63:
		return false

	var start_rank = start_index / 8
	var start_file = start_index % 8
	var target_rank = target_index / 8
	var target_file = target_index % 8

	return abs(start_rank - target_rank) == abs(start_file - target_file) #and abs(start_file - target_file) <= 7
