extends MultiMeshInstance3D
class_name StarField

@export var select_mesh: MeshInstance3D
@export var select_label: Label3D

@export var con_default_mat: ORMMaterial3D
@export var con_highlight_mat: ORMMaterial3D


@export var max_mag = 1.5
@export var min_mag = 7.5


signal on_next_guess(to_guess)
signal on_success

var user_lat = 48.8
var user_long = 2.1

var time = 0

# mesh of the lines between the stars of the constellations
var constellation_links = {}
# labels of the constellations
var constellation_labels = {}

var constellations_to_guess = ["Ori", "UMa", "Tau", "Dra", "Cas"]

var current_con_guess = 0

var constellations_revealed = []

var won = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	seed(0)
	
	time = Time.get_unix_time_from_system()
	
	generate_starfield()
	generate_constellations_to_guess()
	
	#rotate_y(randi_range(0, 2*PI))

func generate_starfield():
	for child in get_children():
		child.queue_free()
	
	generate_stars()
	generate_constellations()

func highlight_star(id):
	select_label.hide()
	select_mesh.hide()
	
	for star in StarDB.stars:
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
		prints("matched constellation !", con)
		constellations_revealed.append(con)
		constellation_labels[con].show()
		if current_con_guess + 1 < constellations_to_guess.size():
			current_con_guess += 1
			on_next_guess.emit(constellations_to_guess[current_con_guess])
		
		if constellations_to_guess.size() == constellations_revealed.size():
			on_success.emit()
			won = true
			

func highlight_constel(con, pos: Vector3):
	var name = StarDB.constellation_names[con]
	#select_mesh.position = pos
	#select_mesh.show()
	
	if won:
		constellation_labels[con].show()
	
	constellation_links[con].show()
	constellation_links[con].material_override = con_highlight_mat
	for c in constellation_links:
		if c != con:
			constellation_links[c].material_override = con_default_mat
	

func reset_highlight():
	select_label.hide()
	select_mesh.hide()
	
	for con in constellation_links:
		constellation_links[con].material_override = con_default_mat
		
		if con not in constellations_revealed: 
			#constellation_links[con].hide()
			
			if won:
				constellation_labels[con].hide()

func generate_stars():
	var i = 0
	var shape = SphereShape3D.new()
	shape.radius = 1
	for star in StarDB.stars:
		StarDB.stars_by_id[star["hip"]] = star
		
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
	var mat = con_default_mat
	var shape = SphereShape3D.new()
	shape.radius = 15
	

	for con in StarDB.constellationships:
		# draw lines between the stars forming the constellation
		var mesh_inst = MeshInstance3D.new()
		var m = ImmediateMesh.new()
		m.surface_begin(Mesh.PRIMITIVE_LINES, mat)
		
		var sum_pos = Vector3.ZERO
		for i in len(StarDB.constellationships[con]):
			var star_id = StarDB.constellationships[con][i]
			if star_id in StarDB.stars_by_id:
				var star = StarDB.stars_by_id[star_id]
				var p_start = get_star_pos(star)
				m.surface_add_vertex(p_start)
				sum_pos += p_start
				
		m.surface_end()
		mesh_inst.material_override = con_default_mat
		mesh_inst.mesh = m
		mesh_inst.name = "constellation_" + con
		add_child(mesh_inst)
		constellation_links[con] = mesh_inst
		mesh_inst.show()
		
		# calculate the mean position of the constellation to place labels + collision
		var con_mean_pos = sum_pos / len(StarDB.constellationships[con])
		
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
		label.text = StarDB.constellation_names[con]
		label.position = con_mean_pos
		label.hide()
		add_child(label)
		constellation_labels[con] = label

func generate_constellations_to_guess():
	var con_to_guess = []
	for con in StarDB.constellationships:
		var ok = true
		for i in len(StarDB.constellationships[con]):
			var star_id = StarDB.constellationships[con][i]
			if star_id in StarDB.stars_by_id:
				var star = StarDB.stars_by_id[star_id]
				var pos = get_star_pos(star)
				if pos.y < 5:
					ok = false
		if ok:
			prints(StarDB.constellation_names[con])
			con_to_guess.append(con)
	
	con_to_guess.shuffle()
	constellations_to_guess = con_to_guess.slice(0, 5)
	print(constellations_to_guess)

# Calculate the cartesian coord of a star based on the ra and dec. 
# The position is calculated at a fixed distance of 100m
func get_star_pos(star: Dictionary) -> Vector3:
	#var ra = -deg_to_rad(star["ra"] * 15)
	#var dec = deg_to_rad(star["dec"])
	
	var ra = star["ra"] * 15
	var dec = star["dec"]
	
	# "2024-07-18T21:28:00"
	var adj = adjust_ra_dec(ra, dec, time, user_lat, user_long)
	#prints(ra, dec, adj)
	var alt = adj.x
	var az = adj.y
	#
	return Vector3(
		cos(alt) * cos(az),
		sin(alt),
		cos(alt) * sin(az)
	) * 100
	#return Vector3(
		#cos(ra) * cos(dec),
		#sin(dec),
		#sin(ra) * cos(dec)
	#) * 100

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

## Calculate the alt + az in radians based on ra/dec and long/lat in degrees
func adjust_ra_dec(ra: float, dec: float, unix_date: int, lat: float, long: float) -> Vector2:
	var unix_time_j2000 = Time.get_unix_time_from_datetime_string("2000-01-01T00:00:00")
	var unix_time = unix_date
	
	#var julian_time = (unix_time / 86400) + 2440587.5
	#$ResultDebug.text += "\njulian time: " + str(julian_time)
	#var gmst = fmod(18.697374558+24.06570982441908 * (julian_time - 2451545.0), 24)
	#prints("gmst", gmst)
	
	
	var days = (unix_time-unix_time_j2000) / 86400.0
	
	var time_dict = Time.get_datetime_dict_from_unix_time(unix_time)
	var ut = time_dict.get("hour") + (time_dict.get("minute") / 60.0)
	
	var lst = 100.46 + (0.985647 * days) + long + (15 * ut)
	# make sure lst is in the range 0 to 360 degrees
	if lst < 0:
		lst = lst + 360
	
	var ha = lst - ra
	
	var dec_d = deg_to_rad(dec)
	var lat_d = deg_to_rad(lat)
	var ha_d = deg_to_rad(ha)
	
	
	var alt = sin(dec_d) * sin(lat_d) + cos(dec_d) * cos(lat_d) * cos(ha_d)
	alt = asin(alt)
	var az = (sin(dec_d) - (sin(alt) * sin(lat_d))) / (cos(alt) * cos(lat_d))
	az = acos(az)
	
	if sin(ha_d) >= 0:
		az = 2*PI - az
	
	return Vector2(alt, az)

