class_name Toilet
extends Node3D


func _on_interactable_interacted(player: Player) -> void:
	player.start_pissing(self)
