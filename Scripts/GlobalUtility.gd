extends Node


var white_square_color = "#EBECD0"
var black_square_color = "739552"

var square_color_order = [
	"white", "black", "white", "black", "white", "black", "white", "black",
	"black", "white", "black", "white", "black", "white", "black", "white",
	"white", "black", "white", "black", "white", "black", "white", "black",
	"black", "white", "black", "white", "black", "white", "black", "white",
	"white", "black", "white", "black", "white", "black", "white", "black",
	"black", "white", "black", "white", "black", "white", "black", "white",
	"white", "black", "white", "black", "white", "black", "white", "black",
	"black", "white", "black", "white", "black", "white", "black", "white"]

var square_names = [
	"A8", "B8", "C8", "D8", "E8", "F8", "G8", "H8",
	"A7", "B7", "C7", "D7", "E7", "F7", "G7", "H7",
	"A6", "B6", "C6", "D6", "E6", "F6", "G6", "H6",
	"A5", "B5", "C5", "D5", "E5", "F5", "G5", "H5",
	"A4", "B4", "C4", "D4", "E4", "F4", "G4", "H4",
	"A3", "B3", "C3", "D3", "E3", "F3", "G3", "H3",
	"A2", "B2", "C2", "D2", "E2", "F2", "G2", "H2",
	"A1", "B1", "C1", "D1", "E1", "F1", "G1", "H1"]

var dict_square_position2 = {
	"A8": Vector2(0, 0), "B8": Vector2(150, 0), "C8": Vector2(300, 0), "D8": Vector2(450, 0), "E8": Vector2(600, 0), "F8": Vector2(750, 0), "G8": Vector2(900, 0), "H8": Vector2(1050, 0),
	"A7": Vector2(0, 150), "B7": Vector2(150, 150), "C7": Vector2(300, 150), "D7": Vector2(450, 150), "E7": Vector2(600, 150), "F7": Vector2(750, 150), "G7": Vector2(900, 150), "H7": Vector2(1050, 150),
	"A6": Vector2(0, 300), "B6": Vector2(150, 300), "C6": Vector2(300, 300), "D6": Vector2(450, 300), "E6": Vector2(600, 300), "F6": Vector2(750, 300), "G6": Vector2(900, 300), "H6": Vector2(1050, 300),
	"A5": Vector2(0, 450), "B5": Vector2(150, 450), "C5": Vector2(300, 450), "D5": Vector2(450, 450), "E5": Vector2(600, 450), "F5": Vector2(750, 450), "G5": Vector2(900, 450), "H5": Vector2(1050, 450),
	"A4": Vector2(0, 600), "B4": Vector2(150, 600), "C4": Vector2(300, 600), "D4": Vector2(450, 600), "E4": Vector2(600, 600), "F4": Vector2(750, 600), "G4": Vector2(900, 600), "H4": Vector2(1050, 600),
	"A3": Vector2(0, 750), "B3": Vector2(150, 750), "C3": Vector2(300, 750), "D3": Vector2(450, 750), "E3": Vector2(600, 750), "F3": Vector2(750, 750), "G3": Vector2(900, 750), "H3": Vector2(1050, 750),
	"A2": Vector2(0, 900), "B2": Vector2(150, 900), "C2": Vector2(300, 900), "D2": Vector2(450, 900), "E2": Vector2(600, 900), "F2": Vector2(750, 900), "G2": Vector2(900, 900), "H2": Vector2(1050, 900),
	"A1": Vector2(0, 1050), "B1": Vector2(150, 1050), "C1": Vector2(300, 1050), "D1": Vector2(450, 1050), "E1": Vector2(600, 1050), "F1": Vector2(750, 1050), "G1": Vector2(900, 1050), "H1": Vector2(1050, 1050) }

var dict_square_position = {}

var rank_list = {
	"1" : ["A1", "B1", "C1", "D1", "E1", "F1", "G1", "H1"],
	"2" : ["A2", "B2", "C2", "D2", "E2", "F2", "G2", "H2"],
	"3" : ["A3", "B3", "C3", "D3", "E3", "F3", "G3", "H3"],
	"4" : ["A4", "B4", "C4", "D4", "E4", "F4", "G4", "H4"],
	"5" : ["A5", "B5", "C5", "D5", "E5", "F5", "G5", "H5"],
	"6" : ["A6", "B6", "C6", "D6", "E6", "F6", "G6", "H6"],
	"7" : ["A7", "B7", "C7", "D7", "E7", "F7", "G7", "H7"],
	"8" : ["A8", "B8", "C8", "D8", "E8", "F8", "G8", "H8"]}

var file_list = {
	"A" : ["A1","A2","A3","A4","A5","A6","A7","A8"],
	"B" : ["B1","B2","B3","B4","B5","B6","B7","B8"],
	"C" : ["C1","C2","C3","C4","C5","C6","C7","C8"],
	"D" : ["D1","D2","D3","D4","D5","D6","D7","D8"],
	"E" : ["E1","E2","E3","E4","E5","E6","E7","E8"],
	"F" : ["F1","F2","F3","F4","F5","F6","F7","F8"],
	"G" : ["G1","G2","G3","G4","G5","G6","G7","G8"],
	"H" : ["H1","H2","H3","H4","H5","H6","H7","H8"]}

var board_state = {}

func _ready():
	initialize_dict_squares()
	initialize_board_state()

func get_value_from_key(dict, value):
	for key in dict.keys():
		if dict[key] == value:
			return key
	return null

func initialize_dict_squares():
	var sw = Global.square_size
	for i in range(0, square_names.size()):
		var name = square_names[i]
		var row = i / 8  # Calculate the row (0 to 7)
		var col = i % 8  # Calculate the column (0 to 7)
		var position = Vector2(col * sw, row * sw)
		dict_square_position[name] = position

func initialize_board_state():

	for name in square_names:
		board_state[name] = {
			"piece": null,
			"location": dict_square_position[name],
			"attacked_by" : [],
			"defended_by" : []
		}
