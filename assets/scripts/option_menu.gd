extends Node2D

@export var items: Array[Control]

@onready var transitionBlock: Control = $CanvasLayer/Transition

var items_y_position: Array[float]
var time_elapsed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items_y_position.resize(len(items))
	var tween = create_tween()
	tween.tween_property(transitionBlock, "position:x", -transitionBlock.size.x, 0.25)
	for i in range(len(items)):
		var item_x_position = items[i].position.x
		items_y_position[i] = items[i].position.y
		if i % 2 == 0:
			items[i].position.x = item_x_position + 1500
		else:
			items[i].position.x = item_x_position - 1500
		tween = create_tween()
		tween.tween_property(items[i], "position:x", item_x_position, 0.75)\
		.set_delay(i * 0.18)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	time_elapsed += delta
	for i in range(len(items)):
		items[i].position.y = items_y_position[i] + sin(time_elapsed * 2 + (i * 0.8)) * 3
		pass


func _on_back_pressed() -> void:
	transitionBlock.position.x = 1600
	var tween = create_tween()
	tween.tween_property(transitionBlock, "position:x", 0, 0.25)
	await tween.finished
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
