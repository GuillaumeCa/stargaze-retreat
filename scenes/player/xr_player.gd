extends Node3D
class_name XRPlayer

@export var left_controller: XRPlayerController
@export var right_controller: XRPlayerController

static var camera_position: Vector3

func _process(delta):
	camera_position = $XRCamera.global_position

func on_visible():
	left_controller.physical_hand.show()
	right_controller.physical_hand.show()
	
func on_hidden():
	left_controller.physical_hand.hide()
	right_controller.physical_hand.hide()
