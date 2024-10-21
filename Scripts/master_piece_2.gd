extends Sprite2D

@export var data: Resource  # Reference to the custom ChessPiece resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# If the data is set, configure the piece accordingly
	if data:
		# Assuming data has a 'texture' property
		self.texture = data.texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
