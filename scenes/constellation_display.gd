extends Node3D
class_name ConstellationDisplay

@export var constellation_viewer: ConstellationViewer

var constellations = {
	"Ori": preload("res://assets/textures/constellation_icons/orion.svg"),
	"UMa": preload("res://assets/textures/constellation_icons/ursa_major.svg"),
	"Cas": preload("res://assets/textures/constellation_icons/cassiopea.svg"),
	"Dra": preload("res://assets/textures/constellation_icons/draco.svg"),
	"Tau": preload("res://assets/textures/constellation_icons/taurus.svg")
}

func set_constellation(abr: String, name: String): 
	print("set constell", abr)
	$ConstellationSprite3D.show()
	$Text.show()
	
	constellation_viewer.update_constellation(abr)
	$Hint.play()
	#$ConstellationIcon.texture = constellations[abr]
	$Text.text = "Find " + name + "\nConstellation"

func set_success():
	$Text.text = "Congratulations !"
