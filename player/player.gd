class_name Player
extends CharacterBody3D

signal channel_forward
signal channel_back
signal tv_on
signal tv_off


enum State {
	WALKING,
	PISSING,
	SITTING,
	BUSY,
	DYING
}


@export var camera: Camera3D
@export var interact_raycast: RayCast3D
@export var interact_label: Label
@export var switch_channel_label: Label
@export var pissing_particles: GPUParticles3D
@export var blood_overlay: BloodOverlay
@export var animation_player: AnimationPlayer
@export var death_screen: DeathScreen

@export var thirst_label: Label
@export var hunger_label: Label
@export var piss_label: Label
@export var stop_pissing_label: Label

@export var piss_sound_player: AudioStreamPlayer3D
@export var standup_sound_player: AudioStreamPlayer
@export var insanity_sound_player: AudioStreamPlayer
@export var sit_sound_player: AudioStreamPlayer3D

@export var speed: float = 1.6

var hunger: float = 0.0
var thirst: float = 0.0
var sanity: float = 1.0
var entertainment: float = 0.5
var piss: float = 0.0
var time_multiplier: float = 1.0

var insanity_rate: float = 0.03
var thirst_rate: float = 0.02
var hunger_rate: float = 0.008
var entertainment_rate: float = 0.2
var piss_rate: float = 0.0035

var time_alive: float = 0.0


var state: State = State.WALKING

var camera_fov_tween: Tween
var sitting_tween: Tween


func _ready():
	stop_pissing_label.visible = false
	pissing_particles.emitting = false
	interact_label.visible = false
	switch_channel_label.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var tween = create_tween().set_parallel()
	tween.tween_interval(4.0)
	tween.chain()
	tween.tween_property(piss_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(hunger_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(thirst_label, "modulate:a", 0.0, 0.5)


func _process(delta):
	if state != State.DYING:
		time_alive += delta


func _physics_process(delta):
	match state:
		State.WALKING: _process_walking(delta)
		State.SITTING: _process_sitting(delta)
		State.BUSY: _process_busy(delta)
		State.PISSING: _process_pissing(delta)


func _process_walking(delta):
	var move_vector: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_back", "move_forward"
	)
	velocity = -basis.z * move_vector.y + basis.x * move_vector.x
	velocity *= speed * (sanity*0.5+0.5) 
	_process_needs(delta)
	check_interactables()
	move_and_slide() 


func _process_sitting(delta):
	_process_needs(delta)
	check_interactables()
	if Input.is_action_just_pressed("interact"):
		stand_up()
	elif Input.is_action_just_pressed("channel_forward"):
		channel_forward.emit()
	elif Input.is_action_just_pressed("channel_back"):
		channel_back.emit()


func _process_busy(delta):
	_process_needs(delta)


func _process_pissing(delta):
	_process_needs(delta)
	piss -= delta*piss_rate*6.0*time_multiplier
	if piss <= 0:
		piss = 0
		stop_pissing()
	if Input.is_action_just_pressed("interact"):
		stop_pissing.call_deferred()
	check_interactables()


func _process_needs(delta):
	time_multiplier += delta*0.015
	thirst += thirst_rate*delta*time_multiplier
	if thirst >= 1.0:
		die("You died from thirst.")
		return
	thirst = clamp(thirst, 0.0, 1.0)
	hunger += hunger_rate*delta*time_multiplier
	if hunger >= 1.0:
		die("You died from hunger.")
		return
	hunger = clamp(hunger, 0.0, 1.0)
	entertainment -= entertainment_rate*delta*time_multiplier
	entertainment = clamp(entertainment, 0.0, 1.0)
	piss += piss_rate*delta*time_multiplier
	if piss >= 1.0:
		die("Your bladder exploded.")
		return
	piss = clamp(piss, 0.0, 1.0)
	if state == State.WALKING:
		sanity -= (2.0 - entertainment)*insanity_rate*delta*time_multiplier
	elif state == State.SITTING:
		sanity += 5*insanity_rate*delta
	if sanity <= 0:
		die("You died from a dopamine shortage.")
		return
	sanity = clamp(sanity, 0.0, 1.0)
	blood_overlay.strength = 1.0-sanity
	


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if state == State.WALKING:
			rotation.y -= event.relative.x / 100.0
			camera.rotation.x -= event.relative.y / 100.0
			camera.rotation_degrees.x = clamp(
				camera.rotation_degrees.x, -80, 80
			)


func die(reason: String):
	if state == State.PISSING:
		stop_pissing()
	var tween = create_tween()
	collision_layer = 0
	if state == State.SITTING:
		tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "rotation_degrees:x", 60.0, 0.5)
	else:
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "rotation_degrees:x", 80.0, 0.5)
		tween.tween_property(camera, "global_position", camera.global_position-global_basis.z*0.4 + Vector3(0,-1.7,0), 0.5)
	state = State.DYING
	await tween.finished
	death_screen.show_death(reason, time_alive)


func check_interactables():
	if state != State.WALKING:
		interact_label.visible = false
		return
	var collider: Interactable = interact_raycast.get_collider() as Interactable
	if collider:
		interact_label.visible = true
		if Input.is_action_just_pressed("interact"):
			collider.on_interact(self)
	else:
		interact_label.visible = false


func sit(armchair: Armchair):
	set_camera_fov(40.0)
	interact_label.visible = false
	sit_sound_player.play()
	standup_sound_player.stop()
	await get_tree().physics_frame
	await get_tree().physics_frame
	collision_layer = 0
	await get_tree().physics_frame
	await get_tree().physics_frame
	tv_on.emit()
	sit_tween_position(armchair.global_position - Vector3(0,0.5,0), 0) 
	state = State.SITTING
	global_rotation.y = armchair.global_rotation.y + PI
	camera.global_rotation.x = 0.0
	switch_channel_label.visible = true


func stand_up():
	set_camera_fov(75)
	standup_sound_player.play(0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	#tv_off.emit()
	sit_tween_position(global_position - global_basis.z*0.5 + Vector3(0,0.5,0), 1)
	state = State.WALKING
	switch_channel_label.visible = false


func set_camera_fov(fov: float):
	if camera_fov_tween and camera_fov_tween.is_running():
		camera_fov_tween.kill()
	camera_fov_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	camera_fov_tween.tween_property(camera, "fov", fov, 0.5)


func sit_tween_position(new_position: Vector3, layer: int):
	if sitting_tween and sitting_tween.is_running():
		sitting_tween.kill()
	sitting_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	sitting_tween.tween_property(self, "global_position", new_position, 0.5)
	sitting_tween.tween_property(self, "collision_layer", layer, 0.0)


func start_pissing(toilet: Toilet):
	stop_pissing_label.visible = true
	interact_label.visible = false
	sit_tween_position(toilet.global_position - toilet.global_basis.x*0.6, 1)
	state = State.PISSING
	pissing_particles.emitting = true
	global_rotation.y = toilet.global_rotation.y - PI/2.0
	camera.rotation.x = -0.7
	await get_tree().create_timer(0.5).timeout
	piss_sound_player.play(0.0)


func stop_pissing():
	stop_pissing_label.visible = false
	state = State.WALKING
	pissing_particles.emitting = false
	await get_tree().create_timer(0.5).timeout
	piss_sound_player.stop()

	
func eat():
	animation_player.play(&"eat")
	state = State.BUSY
	var tween = create_tween()
	tween.tween_interval(0.2)
	tween.tween_property(self, "hunger", 0.0, 0.7)
	await animation_player.animation_finished
	state = State.WALKING


func drink():
	animation_player.play(&"drink")
	state = State.BUSY
	var tween = create_tween()
	tween.tween_interval(0.2)
	tween.tween_property(self, "thirst", 0.0, 0.7)
	await animation_player.animation_finished
	state = State.WALKING
