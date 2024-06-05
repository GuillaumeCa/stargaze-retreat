extends XRController3D
class_name XRPlayerController

@export var physical_hand: CharacterBody3D

func _physics_process(delta: float) -> void:
	if physical_hand:
		physical_hand.global_transform = global_transform
