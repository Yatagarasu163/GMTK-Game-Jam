extends CanvasLayer

@onready var transitionBlock: Control = $Transition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(transitionBlock, "position:x", -1600, 0.25)
