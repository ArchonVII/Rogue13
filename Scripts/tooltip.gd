extends Popup

var origin = ""
var square
var piece
var valid = false

# Called when the node enters the scene tree for the first time.
func _ready():

	#$"../Pieces".connect("create_tooltip", Callable(self, "_create_tooltip"))
	if origin == "piece":
		valid = true

	if origin == "square":
		valid = true

	if valid:
		pass


func _create_tooltip(tip, piece, square):
	print("in tooltip")
	get_node("N/M/V/Name").set_text(piece.data.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
