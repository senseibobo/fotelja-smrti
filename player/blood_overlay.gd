class_name BloodOverlay
extends ColorRect


@export var strength: float = 0.0:
	set(value):
		strength = value
		material.set("shader_parameter/strength", strength)
	get:
		return strength
