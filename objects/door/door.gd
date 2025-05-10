class_name Door
extends Node3D


@export var static_body: StaticBody3D

var tween: Tween
var open: bool = false

func _on_static_body_3d_interacted(player: Player) -> void:
	open = not open
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(static_body, "rotation_degrees:y", -110.0 * int(open), 0.8)
