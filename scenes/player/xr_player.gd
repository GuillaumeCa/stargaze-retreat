extends Node3D
class_name XRPlayer

signal on_pointer_collide(collider)
signal on_pointer_exit_collider(collider)

@export var left_controller: XRPlayerController
@export var right_controller: XRPlayerController
@onready var ray_cast: RayCast3D = $XRCamera/RayCast3D
@onready var constellation_display: ConstellationDisplay = $LeftPhysicalHand/ConstellationDisplay



static var camera_position: Vector3


var prev_collider

func _process(delta):
	camera_position = $XRCamera.global_position
	
	if ray_cast.is_colliding():
		prev_collider = ray_cast.get_collider()
		on_pointer_collide.emit(prev_collider)
	else:
		if prev_collider:
			on_pointer_exit_collider.emit(prev_collider)
			prev_collider = null
	

func on_visible():
	left_controller.physical_hand.show()
	right_controller.physical_hand.show()
	
func on_hidden():
	left_controller.physical_hand.hide()
	right_controller.physical_hand.hide()
