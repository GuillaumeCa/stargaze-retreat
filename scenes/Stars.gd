extends MultiMeshInstance3D
class_name StarField

@export var select_mesh: MeshInstance3D
@export var select_label: Label3D

signal on_next_guess(to_guess)
signal on_success

var db: SQLite = null

var max_mag = 1.5
var min_mag = 7.5

var stars = []
var stars_by_id = {}

# links between the stars forming the constellations
var constellationships = {}

# constellation abr => latin names
var constellation_names = {}

# mesh of the lines between the stars of the constellations
var constellation_links = {}
# labels of the constellations
var constellation_labels = {}

var constellations_to_guess = ["Ori", "UMa", "Tau", "Dra", "Cas"]

var current_con_guess = 0

var constellations_revealed = []

var won = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	
	db.path = "res://assets/stars.sqlite3"
	db.read_only = true
	db.open_db()
	
	
	db.query("SELECT hip, proper, ci, ra, dec, x, y, z, mag, c.\"name\" as \"const\" from stars s join constellations c on c.abr = s.con where mag > -1.5 order by mag LIMIT 10000")
	stars = db.query_result

	db.query("SELECT con, links from constellation_links")
	for con in db.query_result:
		constellationships[con["con"]] = con["links"].split(",")
	
	db.query("SELECT abr, name from constellations")
	for con in db.query_result:
		constellation_names[con["abr"]] = con["name"]

	generate_stars()
	generate_constellations()
	
	rotate_y(randi_range(0, 2*PI))
	constellations_to_guess.shuffle()

func highlight_star(id):
	select_label.hide()
	select_mesh.hide()
	
	for star in stars:
		if star["hip"] == str(id):
			var pos = star["body"].global_position
			select_mesh.position = pos
			select_mesh.show()
			if star["proper"]:
				select_label.text = star["proper"] + "\n" + star["const"]
				
				select_label.position = pos
				select_label.offset = Vector2(0, -30)
				select_label.show()
			return

func guess_constellation(con):
	var to_guess = constellations_to_guess[current_con_guess]
	if con == to_guess:
		constellations_revealed.append(con)
		constellation_labels[con].show()
		if current_con_guess + 1 < constellations_to_guess.size():
			current_con_guess += 1
			on_next_guess.emit(constellations_to_guess[current_con_guess])
		
		if constellations_to_guess.size() == constellations_revealed.size():
			on_success.emit()
			won = true
			

func highlight_constel(con, pos: Vector3):
	var name = constellation_names[con]
	#select_mesh.position = pos
	#select_mesh.show()
	
	if won:
		constellation_labels[con].show()
	
	constellation_links[con].show()


func reset_highlight():
	select_label.hide()
	select_mesh.hide()
	
	for con in constellation_links:
		if con not in constellations_revealed: 
			constellation_links[con].hide()
			
			if won:
				constellation_labels[con].hide()

func generate_stars():
	var i = 0
	var shape = SphereShape3D.new()
	shape.radius = 1
	for star in stars:
		stars_by_id[star["hip"]] = star
		
		var adj_mag = max(1 - ((star["mag"] + max_mag) / (max_mag + min_mag)), 0)
		
		var t = Transform3D()
		t = t.scaled(Vector3.ONE * adj_mag * 1)
		
		var pos = get_star_pos(star)
		
		t.origin = pos #Vector3(star["x"], star["z"], star["y"]) * 2
		
		multimesh.set_instance_transform(i, t)

		#if star["proper"]:
			#var body = StaticBody3D.new()
			#body.set_meta("id", star["hip"])
			#body.add_to_group("star")
			#var col_shape = CollisionShape3D.new()
			#col_shape.shape = shape
			#body.add_child(col_shape)
			#
			#body.position = pos
			#add_child(body)
			#
			#star["body"] = body

		var ci = star["ci"]
		if ci:
			var col = ci_to_rgb(star["ci"])
			multimesh.set_instance_color(i, col)
		i += 1

func generate_constellations():
	var mat = ORMMaterial3D.new()
	mat.albedo_color = Color.WHITE.darkened(0.8)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var shape = SphereShape3D.new()
	shape.radius = 10
	

	for con in constellationships:
		# draw lines between the stars forming the constellation
		var mesh_inst = MeshInstance3D.new()
		var m = ImmediateMesh.new()
		m.surface_begin(Mesh.PRIMITIVE_LINES, mat)
		
		var sum_pos = Vector3.ZERO
		for i in len(constellationships[con]):
			var start = constellationships[con][i]
			if start in stars_by_id:
				var p_start = get_star_pos(stars_by_id[start])
				m.surface_add_vertex(p_start)
				sum_pos += p_start
				
		m.surface_end()
		mesh_inst.mesh = m
		mesh_inst.name = "constellation_" + con
		add_child(mesh_inst)
		constellation_links[con] = mesh_inst
		mesh_inst.show()
		
		# calculate the mean position of the constellation to place labels + collision
		var con_mean_pos = sum_pos / len(constellationships[con])
		
		# add collision to the constellation so that it can be selected
		var body = StaticBody3D.new()
		body.set_meta("id", con)
		body.add_to_group("constel")
		var col_shape = CollisionShape3D.new()
		col_shape.shape = shape
		body.add_child(col_shape)
		body.position = con_mean_pos
		add_child(body)
		
		# generate labels to show the constellation name
		var label = Label3D.new()
		label.pixel_size = 0.05
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.double_sided = false
		label.text = constellation_names[con]
		label.position = con_mean_pos
		label.hide()
		add_child(label)
		constellation_labels[con] = label

# Calculate the cartesian coord of a star based on the ra and dec. 
# The position is calculated at a fixed distance of 100m
func get_star_pos(star: Dictionary) -> Vector3:
	var ra = -deg_to_rad(star["ra"] * 15)
	var dec = deg_to_rad(star["dec"])
	
	#var adj = adjust_ra_dec(ra, dec, "2024-07-10T21:28:00", deg_to_rad(2.1716), deg_to_rad(48.8011))
	#prints(ra, dec, adj)
	#var alt = adj.x
	#var az = adj.y
	#
	#return Vector3(
		#cos(alt) * cos(az),
		#sin(alt),
		#cos(alt) * sin(az)
	#) * 100
	return Vector3(
		cos(ra) * cos(dec),
		sin(dec),
		sin(ra) * cos(dec)
	) * 100

# compute the rgb color of a star based on its color index (ci)
func ci_to_rgb(ci_raw: float) -> Color:
	var ci = max(-0.4, min(ci_raw, 2.0))
	
	if ci < 0.0:
		return Color(
			0.31 + 0.682 * ci,
			0.25 + 0.77 * ci,
			1.0
		)
	elif ci < 0.4:
		return Color(
			0.31 + 0.91 * ci,
			0.55 + 0.69 * ci,
			1.0
		)
	elif ci < 1.6:
		return Color(
			1.0,
			0.99 - 0.16 * ci,
			0.61 - 0.44 * ci
		)
	else:
		return Color(
			1.0,
			0.71 - 0.45 * ci,
			0.61 - 0.44 * ci
		)
	
func adjust_ra_dec(ra, dec, date, long, lat) -> Vector2:
	var unix_time = Time.get_unix_time_from_datetime_string(date)
	var julian_time = (unix_time / 86400) + 2440587.5
	var gmst = fmod(18.697374558+24.06570982441908 * (julian_time - 2451545.0), 24)
	prints("gmst", gmst)
	var lst = gmst + (long/15.0)
	prints("lst", lst)
	var ha = lst - ra
	prints("ha", ha)
	
	var alt = asin(sin(dec) * sin(lat) + cos(dec) * cos(ha))
	var az = acos((sin(dec) - sin(alt) * sin(lat)) / (cos(alt) * cos(lat)))
	return Vector2(alt, az)

