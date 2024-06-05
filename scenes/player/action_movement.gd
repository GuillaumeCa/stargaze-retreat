extends Node3D

@export_enum("grip_click", "ax_button", "by_button") var action = ""
@export var speed = 10

var player: XRPlayer

@onready var controller: XRController3D = get_parent()

var is_pressed = false

var prev_position: Vector3

var offset = Vector3.ZERO

static var movement_lock = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = owner
	
	if controller:
		controller.button_pressed.connect(_on_controller_button_pressed)
		controller.button_released.connect(_on_controller_button_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_pressed:
		movement_lock = true
		prev_position.y = global_position.y # no movement on y axis
		offset = offset.lerp(prev_position - global_position, 0.2)
		player.global_position += offset * speed
	
	prev_position = global_position

func _on_controller_button_pressed(name):
	if name == action and !movement_lock:
		movement_lock = true
		is_pressed = true

func _on_controller_button_released(name):
	if name == action:
		movement_lock = false
		is_pressed = false
