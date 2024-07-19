extends Node2D
class_name ConstellationViewer

const CIRCLE_05 = preload("res://assets/textures/circle_05.png")

@onready var line_2d: Line2D = $Line2D

func update_constellation(con: String):
	var points_by_star_id = {}
	var line_points = []
	for i in len(StarDB.constellationships[con]):
		var id = StarDB.constellationships[con][i]
		if id in StarDB.stars_by_id:
			var star = StarDB.stars_by_id[id]
			var ra = deg_to_rad(star["ra"] * 15)
			var dec = deg_to_rad(star["dec"])
			points_by_star_id[id] = Vector2(ra, dec)
			line_points.append(Vector2(ra, dec))
	
	var points = points_by_star_id.values()
	
	#points = center_points(points)
	var center = get_center(points)
	
	var center_xy = to_cartesian(center)
	
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()
	
	for p in points:
		var xy = transform_pos(p, center_xy)
		spawn_sprite(xy)
	
	line_2d.points = []
	for p in line_points:
		var xy = transform_pos(p, center_xy)
		line_2d.add_point(xy)



func transform_pos(point: Vector2, offset: Vector2):
	var xy = to_cartesian(point) - offset
	return (xy * 500) + Vector2(256, 256)

func get_center(points: Array) -> Vector2:
	var sum = Vector2.ZERO
	for p in points:
		sum += p
	var mean = sum / len(points)
	return mean

func to_cartesian(polar: Vector2) -> Vector2:
	return Vector2(
		cos(polar.y) * cos(polar.x),
		cos(polar.y) * sin(polar.x)
	)

func spawn_sprite(pos: Vector2):
	var sprite = Sprite2D.new()
	sprite.texture = CIRCLE_05
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = mat
	sprite.scale = Vector2.ONE * 0.05
	sprite.position = pos
	
	add_child(sprite)
