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
@export var speed: float = 2.5


var state: State = State.WALKING


func _ready():
	pissing_particles.emitting = false
	interact_label.visible = false
	switch_channel_label.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	match state:
		State.WALKING:
			_process_walking(delta)
		State.SITTING:
			_process_sitting(delta)
		State.BUSY:
			_process_busy(delta)


func _process_walking(delta):
	var move_vector: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_back", "move_forward"
		)
	velocity = - basis.z * move_vector.y + basis.x * move_vector.x
	velocity *= speed
	check_interactables()
	move_and_slide() 


func _process_sitting(delta):
	if Input.is_action_just_pressed("interact"):
		stand_up()
	elif Input.is_action_just_pressed("channel_forward"):
		channel_forward.emit()
	elif Input.is_action_just_pressed("channel_back"):
		channel_back.emit()


func _process_busy(delta):
	pass


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if state == State.WALKING:
			rotation.y -= event.relative.x / 100.0
			camera.rotation.x -= event.relative.y / 100.0


func check_interactables():
	var collider: Interactable = interact_raycast.get_collider() as Interactable
	if collider:
		interact_label.visible = true
		if Input.is_action_just_pressed("interact"):
			collider.on_interact(self)
	else:
		interact_label.visible = false


func sit(armchair: Armchair):
	collision_layer = 0
	tv_on.emit()
	global_position = armchair.global_position 
	global_position.y -= 0.5
	state = State.SITTING
	global_rotation.y = armchair.global_rotation.y + PI
	camera.global_rotation.x = 0.0
	switch_channel_label.visible = true


func stand_up():
	collision_layer = 1
	tv_off.emit()
	global_position -= global_basis.z*0.5
	global_position.y += 0.5
	state = State.WALKING
	switch_channel_label.visible = false


func start_pissing(toilet: Toilet):
	global_position = toilet.global_position - toilet.global_basis.x*0.6
	state = State.BUSY
	pissing_particles.emitting = true
	global_rotation.y = toilet.global_rotation.y - PI/2.0
	camera.rotation.x = -0.7
	await get_tree().create_timer(10.0).timeout
	pissing_particles.emitting = false
	state = State.WALKING
	
	
