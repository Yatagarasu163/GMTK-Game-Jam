extends Node2D

@onready var transitionBlock: Control = $CanvasLayer/Transition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(transitionBlock, "position:x", -1600, 0.25)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	transitionBlock.position.x = 1600
	var tween = create_tween()
	tween.tween_property(transitionBlock, "position:x", 0, 0.25)
	await tween.finished
	get_tree().change_scene_to_file("res://main_menu.tscn")
