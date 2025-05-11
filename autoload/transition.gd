extends CanvasLayer



var tween: Tween


func _ready():
	$ColorRect.color.a = 0.0


func transition(to_scene: PackedScene):
	$ColorRect.color.a = 0.0
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property($ColorRect, "color:a", 1.0, 0.5)
	tween.tween_callback(get_tree().change_scene_to_packed.bind(to_scene))
	tween.tween_property($ColorRect, "color:a", 0.0, 0.5)
	
	
