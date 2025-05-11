class_name MainMenu
extends Control


var startable: bool = false

func _ready():
	$PressAnyButton.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_property($PressAnyButton, "modulate:a", 1.0, 1.0)
	tween.tween_callback(enable_start)


func enable_start():
	startable = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if startable and event.pressed:
			startable = false
			Transition.transition(preload("res://room/room.tscn"))
