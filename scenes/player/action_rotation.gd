extends Node3D

@export_enum("primary") var action = "primary"
@export var speed = 1
@export var turn_angle = 45

@onready var controller: XRController3D = get_parent()

@onready var camera

var pressed = false
var player: XRPlayer

func _ready() -> void:
	player = owner
	camera = player.get_node("XRCamera") as XRCamera3D

func _process(delta: float) -> void:
	if controller:
		var dir = controller.get_vector2(action)
		var horiz = dir.x
		
		if abs(horiz) > 0.3:
			if not pressed:
				pressed = true
				rotate_player(deg_to_rad(sign(horiz) * turn_angle))
		else:
			pressed = false


func rotate_player(rotation: float):
	var t1 := Transform3D()
	var t2 := Transform3D()
	var rot := Transform3D()

	t1.origin = -camera.position
	t2.origin = camera.position
	rot = rot.rotated(Vector3.DOWN, rotation)
	player.transform = (player.transform * t2 * rot * t1).orthonormalized()
