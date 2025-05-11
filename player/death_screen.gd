class_name DeathScreen
extends ColorRect


@export var reason_label: Label
@export var press_any_button_label: Label

var continueable: bool = false


func _ready():
	visible = false


func show_death(reason: String):
	visible = true
	reason_label.text = reason
	reason_label.modulate.a = 0.0
	press_any_button_label.modulate.a = 0.0
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	tween.tween_property(reason_label, "modulate:a", 1.0, 1.0)
	tween.tween_interval(2.0)
	tween.tween_property(press_any_button_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(self, "continueable", true, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and continueable:
			continueable = false
			Transition.transition(load("res://ui/main_menu.tscn"))
