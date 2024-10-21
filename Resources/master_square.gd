extends Sprite2D

@export var data: Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#if square_data:


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

"""
func _on_area_2d_area_entered(area: Area2D):
	print("square: something entered me ", area)
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	pass # Replace with function body.


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	var square = area.get_parent()
	print("\n area shape entered, no clue what these are:")
	printt(area_rid, square.data.index, area_shape_index, local_shape_index)
	pass # Replace with function body.


func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
"""
