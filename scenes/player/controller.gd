extends XRController3D

@export var physical_hand: CharacterBody3D

func _process(delta: float) -> void:
	if physical_hand:
		physical_hand.global_transform = global_transform
