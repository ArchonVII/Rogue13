extends Node

var bishop_all = [ 7, 9, 14, 18, 21, 27, 28, 35, 36, 42, 45, 54, 56, 63]
var bishop_all_neg = [ -7, -9, -14, -18, -21, -27, -28, -35, -36, -42, -45, -54, -56, -63]
var square_val = .125
##var rank = (8 - floor(idx))
var piece_all_moves = []
var index = 38

func _ready():
	#print("Index: ", idx, " rank: ", "\n")
	var i = 0
	var j = 0
	#var file = float((idx - rank) / square_val)

	while index + bishop_all[i] < 65:
		var mix = index + bishop_all[i]
		piece_all_moves.append(mix)
		i += 1

	#while index - bishop_all[j] > 0:
		#var mix = index - bishop_all[j]
		#var rank_offset = rank + (j/2)
		#var file_offset = file + (j/2)
		#print("rank offset ", rank_offset, " file offset: ", file_offset, " mix ", mix)
		#if file_offset < 9 and rank_offset < 9:

			#piece_all_moves.append(mix)
		#j += 1

	#print("Rank: ", rank, " File: ", file, " Moves: ", piece_all_moves)

	take_two()

func take_two():
	print("\n")
	var rank : float
	rank = float(index/8)

	var square_val = .125
	index = 38.0
	var idx : float
	idx = (index / 8)

	var moves = []
	var test2 : int

	#
	var new_rank = 38 % 8
	print("new file ", new_rank)

	for i in range(0, bishop_all.size()):
		var test : int
		test = index + bishop_all[i]
		var posrank = test % 8
		print("pos file  ", posrank, " test: ", test)
		if test < 64:
			moves.append(test)
		else:
			break

	for j in range(0, bishop_all_neg.size()):
		var lastrank
		test2 = index + bishop_all_neg[j]

		var negfile = test2 % 8
		if negfile == 0:
			bishop_all_neg.remove_at(j + 2)


		var negrank = (fmod(float(test2)/8.0,1)/.125)

		if test2 > 0:
			if lastrank:
				if negrank - lastrank != 1:
					print("neg file ", negfile, " rank: ", negrank, " last rank: ", lastrank, " test: ", test2)
					moves.append(test2)
					lastrank = negrank






	print("TEEESTT: ", moves)


"""
take the index and subtract 8*i until the value is negative.  That number is the extent of one side of moves the bishop can encompass
					add 8*i until the value is over 64 and that is bottom

"""
