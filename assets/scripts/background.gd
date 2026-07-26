extends Control

@onready var player1: Control = $Player1
@onready var player2: Control = $Player2

var time_elapsed: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	player1.position.y = sin(time_elapsed * 2) * 3
	player2.position.y = sin(time_elapsed * 2.8) * 3
