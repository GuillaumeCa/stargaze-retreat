extends Node3D
class_name ConstellationDisplay


var constellations = {
	"Ori": preload("res://assets/textures/constellation_icons/orion.svg"),
	"UMa": preload("res://assets/textures/constellation_icons/ursa_major.svg"),
	"Cas": preload("res://assets/textures/constellation_icons/cassiopea.svg"),
	"Dra": preload("res://assets/textures/constellation_icons/draco.svg"),
	"Tau": preload("res://assets/textures/constellation_icons/taurus.svg")
}

func set_constellation(abr: String, name: String):
	$Hint.play()
	$ConstellationIcon.texture = constellations[abr]
	$Text.text = "Find " + name + "\nConstellation"

func set_success():
	$Text.text = "Congratulations !"
