extends Node


var db: SQLite = null

var stars = []
var stars_by_id = {}

# links between the stars forming the constellations
var constellationships = {}

# constellation abr => latin names
var constellation_names = {}


func _enter_tree() -> void:
	query_data()

func query_data():
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
