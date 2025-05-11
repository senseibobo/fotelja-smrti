class_name Sink
extends Node3D


func _on_static_body_3d_interacted(player: Player) -> void:
	player.drink()
