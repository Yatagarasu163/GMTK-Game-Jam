extends CanvasLayer

@onready var transitionBlock: Control = $Transition
@onready var clock = $Panel/Clock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transitionBlock.show()
	var tween = create_tween()
	tween.tween_property(transitionBlock, "position:x", -transitionBlock.size.x, 0.25)
	
	var round_manager = get_tree().get_first_node_in_group("round_manager");
	if round_manager:
		round_manager.time_updated.connect(update_timer);
		
func update_timer(seconds_left: int):
	clock.text = str(seconds_left)

	
