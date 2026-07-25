extends Node2D

@export var buttons: Array[Button]
@export var x_position: float = 864

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# check each for even
	# set position
	# set tween to set the buttons in
	for i in range(len(buttons)):
		if i % 2 == 0:
			buttons[i].position.x = x_position + 1500
		else:
			buttons[i].position.x = x_position - 1500
		var tween = create_tween()
		tween.tween_property(buttons[i], "position:x", x_position, 0.75)\
		.set_delay(i * 0.18)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	#for i in range(cards.size()):
		#var new_position := Vector2(start_x + i * card_width, y - cards[i].card_current_y_offset)
		#
		#var tween = create_tween()
		#tween.tween_property(cards[i], "position", new_position, 5.0 / deal_speed)\
		#.set_delay(i * card_delay).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
