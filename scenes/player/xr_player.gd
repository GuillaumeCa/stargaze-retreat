extends Node3D
class_name XRPlayer

@export var left_controller: XRController3D
@export var right_controller: XRController3D

static var camera_position: Vector3

func _process(delta):
	camera_position = $XRCamera.global_position
