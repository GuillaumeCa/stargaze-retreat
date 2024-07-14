extends Node3D


@export var start_scene: PackedScene
@export var xr_player: XRPlayer
@export var xr_config: XRConfig

@export var starfield: StarField


var shooting_star_scene = preload("res://scenes/shootingstar.tscn")

var init_position: Vector3

var started = false

var xr_is_focussed = false

var selected

var intro = true

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

func _on_right_controller_button_pressed(name: String) -> void:
	if name == "trigger_click":
		if intro:
			xr_player.right_controller.trigger_haptic_pulse("haptic", 50, 0.5, 0.1, 0)
			intro = false
			$Start.hide()
			
			var to_guess = starfield.constellations_to_guess[0]
			var const_name = starfield.constellation_names[to_guess]
			xr_player.constellation_display.set_constellation(to_guess, const_name)
			return
		
		
		if selected and selected.is_in_group("constel"):
			print("select", selected)
			xr_player.right_controller.trigger_haptic_pulse("haptic", 50, 0.5, 0.1, 0)
			starfield.guess_constellation(selected.get_meta("id"))

func _on_xr_player_on_pointer_collide(collider: Node3D) -> void:
	if intro:
		return
	
	if collider.is_in_group("star"):
		selected = collider
		starfield.highlight_star(int(selected.get_meta("id")))
	elif collider.is_in_group("constel"):
		selected = collider
		starfield.highlight_constel(selected.get_meta("id"), collider.global_position)
	else:
		starfield.reset_highlight()


func _on_left_controller_input_vector_2_changed(name: String, value: Vector2) -> void:
	if name == "primary":
		pass
		#starfield.rotate_x(value.y * 0.02)
		#starfield.rotate_y(-value.x * 0.02)


func _on_xr_player_on_pointer_exit_collider(collider: Variant) -> void:
	selected = null
	starfield.reset_highlight()


func _on_stars_on_next_guess(to_guess: Variant) -> void:
	var name = starfield.constellation_names[to_guess]
	xr_player.left_controller.trigger_haptic_pulse("haptic", 50, 0.5, 0.1, 0)
	xr_player.left_controller.trigger_haptic_pulse("haptic", 50, 0.5, 0.1, 0.5)
	xr_player.constellation_display.set_constellation(to_guess, name)


func _on_stars_on_success() -> void:
	xr_player.left_controller.trigger_haptic_pulse("haptic", 80, 1, 0.2, 0)
	xr_player.left_controller.trigger_haptic_pulse("haptic", 80, 1, 1, 1)
	xr_player.constellation_display.set_success()





func _on_timer_timeout() -> void:
	var scn = shooting_star_scene.instantiate() as RigidBody3D
	scn.position = Vector3(0, 50, -7)
	add_child(scn)
	scn.apply_impulse(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * 70)
