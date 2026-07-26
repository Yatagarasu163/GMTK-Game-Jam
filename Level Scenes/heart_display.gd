extends Control
class_name HeartDisplay

@export var heart_list: Array[AnimatedSprite2D]

func Take_Heart(hearts: int):
	heart_list[hearts-1].play("Lives")
