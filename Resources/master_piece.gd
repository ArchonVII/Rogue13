extends Sprite2D

@export var data: Resource  # Reference to the custom ChessPiece resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If the data is set, configure the piece accordingly
	if data:
		self.texture = data.texture

	var names = "res://Docs/names.txt"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

"""
func _on_area_2d_area_entered(area: Area2D) -> void:
	#print("area2d entered for piece")
	pass # Replace with function body.


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	print("\n PIECE shape entered, no clue what these are:")
	printt(area_rid, area.get_parent(), area_shape_index, local_shape_index)
	var other_piece = area.get_parent()
	print("parent: ", other_piece.data.index)
	pass # Replace with function body.
"""
