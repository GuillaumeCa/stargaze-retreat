extends Node3D


@export var start_scene: PackedScene
@export var xr_player: XRPlayer
@export var xr_config: XRConfig


var init_position: Vector3

var started = false

var xr_is_focussed = false

func _ready():
	init_position = xr_player.global_position
	
	xr_config.focus_gained.connect(_on_focus)
	xr_config.focus_lost.connect(_on_focus_lost)

func _on_focus():
	if !started:
		started = true
		xr_config.recenter()

	xr_player.on_visible()

func _on_focus_lost() -> void:
	xr_player.on_hidden()

