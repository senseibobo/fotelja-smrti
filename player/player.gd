class_name Player
extends CharacterBody3D

signal channel_forward
signal channel_back
signal tv_on
signal tv_off


enum State {
	WALKING,
	SITTING,
	BUSY,
}


@export var camera: Camera3D
@export var interact_raycast: RayCast3D
@export var interact_label: Label
@export var switch_channel_label: Label
@export var pissing_particles: GPUParticles3D
@export var blood_overlay: BloodOverlay
@export var animation_player: AnimationPlayer
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


var state: State = State.WALKING


func _ready():
	pissing_particles.emitting = false
	interact_label.visible = false
	switch_channel_label.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	match state:
		State.WALKING: _process_walking(delta)
		State.SITTING: _process_sitting(delta)
		State.BUSY: _process_busy(delta)


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
	if Input.is_action_just_pressed("interact"):
		stand_up()
	elif Input.is_action_just_pressed("channel_forward"):
		channel_forward.emit()
	elif Input.is_action_just_pressed("channel_back"):
		channel_back.emit()


func _process_busy(delta):
	_process_needs(delta)


func _process_needs(delta):
	time_multiplier += delta*0.015
	thirst += thirst_rate*delta*time_multiplier
	thirst = clamp(thirst, 0.0, 1.0)
	hunger += hunger_rate*delta*time_multiplier
	hunger = clamp(hunger, 0.0, 1.0)
	entertainment -= entertainment_rate*delta*time_multiplier
	entertainment = clamp(entertainment, 0.0, 1.0)
	piss += piss_rate*delta*time_multiplier
	piss = clamp(piss, 0.0, 1.0)
	if state == State.WALKING:
		sanity -= (2.0 - entertainment)*insanity_rate*delta*time_multiplier
	elif state == State.SITTING:
		sanity += 5*insanity_rate*delta
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


func check_interactables():
	var collider: Interactable = interact_raycast.get_collider() as Interactable
	if collider:
		interact_label.visible = true
		if Input.is_action_just_pressed("interact"):
			collider.on_interact(self)
	else:
		interact_label.visible = false


func sit(armchair: Armchair):
	await get_tree().physics_frame
	await get_tree().physics_frame
	collision_layer = 0
	await get_tree().physics_frame
	await get_tree().physics_frame
	tv_on.emit()
	global_position = armchair.global_position 
	global_position.y -= 0.5
	state = State.SITTING
	global_rotation.y = armchair.global_rotation.y + PI
	camera.global_rotation.x = 0.0
	switch_channel_label.visible = true


func stand_up():
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	tv_off.emit()
	global_position -= global_basis.z*0.5
	global_position.y += 0.5
	state = State.WALKING
	switch_channel_label.visible = false
	collision_layer = 1


func start_pissing(toilet: Toilet):
	global_position = toilet.global_position - toilet.global_basis.x*0.6
	state = State.BUSY
	pissing_particles.emitting = true
	global_rotation.y = toilet.global_rotation.y - PI/2.0
	camera.rotation.x = -0.7
	var tween = create_tween()
	tween.tween_property(self, "piss", 0.0, 10.0)
	
	await get_tree().create_timer(10.0).timeout
	pissing_particles.emitting = false
	state = State.WALKING
	
	
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
