extends CanvasLayer

@onready var transitionBlock: Control = $Transition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transitionBlock.show()
	var tween = create_tween()
	tween.tween_property(transitionBlock, "position:x", -transitionBlock.size.x, 0.25)
